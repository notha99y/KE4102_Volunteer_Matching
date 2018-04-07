
;;;======================================================
;;;   VWO Recommender System
;;;
;;;   This system reccomends a VWO
;;;   to a potential volunteer. 
;;;     
;;;   VWO = Voluntary Welfare Organisation 
;;;     
;;;
;;;     
;;;======================================================

(defmodule MAIN (export ?ALL))

;;*****************
;;* INITIAL STATE *
;;*****************

(deftemplate MAIN::attribute
   (slot name)
   (slot value)
   (slot certainty (default 100.0)))

(defrule MAIN::start
  (declare (salience 10000))
  =>
  (set-fact-duplication TRUE)
  (focus CHOOSE-QUALITIES VWOs))

(defrule MAIN::combine-certainties ""
  (declare (salience 100)
           (auto-focus TRUE))
  ?rem1 <- (attribute (name ?rel) (value ?val) (certainty ?per1))
  ?rem2 <- (attribute (name ?rel) (value ?val) (certainty ?per2))
  (test (neq ?rem1 ?rem2))
  =>
  (retract ?rem1)
  (modify ?rem2 (certainty (/ (- (* 100 (+ ?per1 ?per2)) (* ?per1 ?per2)) 100))))
  
 
;;******************
;; The RULES module
;;******************

(defmodule RULES (import MAIN ?ALL) (export ?ALL))

(deftemplate RULES::rule
  (slot certainty (default 100.0))
  (multislot if)
  (multislot then))

(defrule RULES::throw-away-ands-in-antecedent
  ?f <- (rule (if and $?rest))
  =>
  (modify ?f (if ?rest)))

(defrule RULES::throw-away-ands-in-consequent
  ?f <- (rule (then and $?rest))
  =>
  (modify ?f (then ?rest)))

(defrule RULES::remove-is-condition-when-satisfied
  ?f <- (rule (certainty ?c1) 
              (if ?attribute is ?value $?rest))
  (attribute (name ?attribute) 
             (value ?value) 
             (certainty ?c2))
  =>
  (modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

(defrule RULES::remove-is-not-condition-when-satisfied
  ?f <- (rule (certainty ?c1) 
              (if ?attribute is-not ?value $?rest))
  (attribute (name ?attribute) (value ~?value) (certainty ?c2))
  =>
  (modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

(defrule RULES::perform-rule-consequent-with-certainty
  ?f <- (rule (certainty ?c1) 
              (if) 
              (then ?attribute is ?value with certainty ?c2 $?rest))
  =>
  (modify ?f (then ?rest))
  (assert (attribute (name ?attribute) 
                     (value ?value)
                     (certainty (/ (* ?c1 ?c2) 100)))))

(defrule RULES::perform-rule-consequent-without-certainty
  ?f <- (rule (certainty ?c1)
              (if)
              (then ?attribute is ?value $?rest))
  (test (or (eq (length$ ?rest) 0)
            (neq (nth$ 1 ?rest) with)))
  =>
  (modify ?f (then ?rest))
  (assert (attribute (name ?attribute) (value ?value) (certainty ?c1))))

;;*******************************
;;* CHOOSE VWO ATTRIBUTES RULES *
;;*******************************

(defmodule CHOOSE-QUALITIES (import RULES ?ALL)
                            (import MAIN ?ALL))

(defrule CHOOSE-QUALITIES::startit => (focus RULES))

(deffacts the-vwo-rules

  ; Rules for picking the best day of week
  ; Rules based on preferred day of week

  (rule (if preferred-dow is monday)
        (then b-dow is weekday with certainty 60 and
		      b-dow is anyday with certainty 80))

  (rule (if preferred-dow is tuesday)
        (then b-dow is weekday with certainty 60 and
		      b-dow is anyday with certainty 80))

  (rule (if preferred-dow is wednesday)
        (then b-dow is weekday with certainty 60 and
		      b-dow is anyday with certainty 80))

  (rule (if preferred-dow is thursday)
        (then b-dow is weekday with certainty 60 and
		      b-dow is anyday with certainty 80))

  (rule (if preferred-dow is friday)
        (then b-dow is weekday with certainty 60 and
		      b-dow is anyday with certainty 80))

  (rule (if preferred-dow is saturday)
        (then b-dow is weekend with certainty 95 and
		      b-dow is anyday with certainty 80))

  (rule (if preferred-dow is sunday)
        (then b-dow is weekend with certainty 95 and
		      b-dow is anyday with certainty 80))

  (rule (if preferred-dow is weekday)
        (then b-dow is weekday and
		      b-dow is anyday with certainty 80))

  (rule (if preferred-dow is weekend)
        (then b-dow is weekend and
		      b-dow is anyday with certainty 80))
		  		
;  (rule (if preferred-dow is anyday)
;        (then b-dow is anyday with certainty 80 and
;		      b-dow is weekday with certainty 80 and
;			  b-dow is weekend with certainty 80))

  (rule (if preferred-dow is anyday)
        (then b-dow is anyday with certainty 80 and
		      b-dow is weekday with certainty 60 and
			  b-dow is weekend with certainty 40))

;swapping from above
;  (rule (if preferred-dow is unknown)
;        (then b-dow is anyday with certainty 60 and
;		      b-dow is weekday with certainty 70 and
;			  b-	 is weekend with certainty 80))

  ; Rules for picking the best area
  ; Rules based on preferred area

  (rule (if preferred-area is north)
        (then best-area is north and
		      best-area is northeast with certainty 70))

  (rule (if preferred-area is northeast)
        (then best-area is northeast and
		      best-area is east with certainty 80
		      best-area is north with certainty 80))

  (rule (if preferred-area is east)
        (then best-area is east and
		      best-area is northeast with certainty 70))

  (rule (if preferred-area is west)
        (then best-area is west))

  (rule (if preferred-area is south)
        (then best-area is south))

  (rule (if preferred-area is overseas)
        (then best-area is overseas))

  (rule (if preferred-area is central)
        (then best-area is central and
		      best-area is north with certainty 70
			  best-area is south with certainty 70))

;  (rule (if best-area is east and
;            preferred-area is north)
;        (then best-area is northeast))

  (rule (if preferred-area is unknown)
        (then best-area is islandwide and
			  best-area is north with certainty 50 and
              best-area is northeast with certainty 50 and
              best-area is south with certainty 50 and
              best-area is central with certainty 50 and
              best-area is west with certainty 50 and
              best-area is east with certainty 50))

  ; Rules for picking the best duration
  ; Rules based on preferred duration

  (rule (if preferred-duration is lessthan8)
        (then best-duration is lessthan8 and
		      best-duration is wholeday with certainty -80 and
			  best-duration is am with certainty 80 and
			  best-duration is pm with certainty 80 and
			  best-duration is flexible with certainty 90))

  (rule (if preferred-duration is am)
        (then best-duration is am with certainty 90 and
			  best-duration is flexible with certainty 70))

  (rule (if preferred-duration is pm)
        (then best-duration is pm with certainty 90 and
			  best-duration is flexible with certainty 70))

  (rule (if preferred-duration is wholeday)
        (then best-duration is wholeday and
			  best-duration is flexible with certainty 70))
		  		
  (rule (if preferred-duration is flexible)
        (then best-duration is wholeday with certainty 70 and
			  best-duration is am with certainty 60 and
			  best-duration is pm with certainty 50 and
			  best-duration is lessthan8 with certainty 60 and
			  best-duration is multiple with certainty 80 and
			  best-duration is flexible))
		  		
;  (rule (if preferred-duration is unknown)
;        (then best-duration is flexible))
		  		
  ; Rules for picking the best cause
  ; Rules based on VWO cause	

  (rule (if p-cause is socialservice)
        (then b-cause is SocialService and
		      b-cause is Health))

  (rule (if p-cause is health)
        (then b-cause is Health with certainty 85 and
		      b-cause is SocialService with certainty 50 and
			  b-cause is Elderly with certainty 85))
			  		
  (rule (if p-cause is childrenyouth)
        (then b-cause is ChildrenYouth and
		      b-cause is Community with certainty 80 and
		      b-cause is SocialService with certainty 60 and
		      b-cause is Elderly with certainty -100))
			  		
  (rule (if p-cause is elderly)
        (then b-cause is Elderly and
		      b-cause is Community with certainty 70 and
		      b-cause is ChildrenYouth with certainty -100))
			  		
  (rule (if p-cause is education)
        (then b-cause is Education and
		      b-cause is ChildrenYouth with certainty 60 and
		      b-cause is Elderly with certainty -80 and
			  b-cause is Animals with certainty -80))
			  		
  (rule (if p-cause is community)
        (then b-cause is Community and
		      b-cause is Elderly with certainty 70 and
		      b-cause is Health with certainty 60 and
		      b-cause is Education with certainty 60 and
		      b-cause is ChildrenYouth with certainty 60 and
			  b-cause is Animals with certainty -80))
			  		
  (rule (if p-cause is unknown)
        (then b-cause is medical with certainty 20 and
		      b-cause is ChildrenYouth with certainty 20 and
		      b-cause is Elderly with certainty 20 and
		      b-cause is youth with certainty 20 and
		      b-cause is Education with certainty 20 and
		      b-cause is Community with certainty 20 and
			  b-cause is Health with certainty 20))

  (rule (if p-cause is disability)
        (then b-cause is Disability))

  (rule (if p-cause is artsheritage)
        (then b-cause is ArtsHeritage and
		      b-skill-reqd is ArtsMusic with certainty 70))

  (rule (if p-cause is sports)
        (then b-cause is Sports and
		      b-skill-reqd is MedicalHealth with certainty 60))

  (rule (if p-cause is humanitarian)
        (then b-cause is Humanitarian and
		      b-cause is Elderly with certainty 80 and
			  b-cause is Community with certainty 70))

  (rule (if p-cause is environment)
        (then b-cause is Environment))

  (rule (if p-cause is animals)
        (then b-cause is Animals and
		      b-cause is Elderly with certainty -100 and
		      b-cause is Humanitarian with certainty -100 and
		      b-cause is Environment with certainty -100 and
		      b-cause is ChildrenYouth with certainty -100 and
			  b-cause is Community with certainty -100 and
			  b-cause is SocialService with certainty -100 and
		      b-skill-reqd is ArtsMusic with certainty -100))

  (rule (if p-cause is families)
        (then b-cause is Families and
		      b-cause is ChildrenYouth with certainty 60 and
			  b-cause is Elderly with certainty 60))

  (rule (if p-cause is womengirls)
        (then b-cause is WomenGirls and
		      b-cause is Families with certainty 60 and
			  b-cause is ChildrenYouth with certainty 60))

  ; Rules for picking the best age
  ; Rules based on age

  (rule (if agegroup is teen)
        (then b-age is teen and
			  b-age is any with certainty 85 and
			  b-age is youth with certainty 60))

  (rule (if agegroup is youth)
        (then b-age is youth with certainty 85 and
			  b-age is any with certainty 85 and
			  b-age is teen with certainty 80 and
			  b-age is middle with certainty 60))
			  		
  (rule (if agegroup is middle)
        (then b-age is middle and
			  b-age is any with certainty 90 and
			  b-age is teen with certainty 80 and
			  b-age is youth with certainty 70))
			  		
  (rule (if agegroup is 55plus)
        (then b-age is 55plus and
			  b-age is any with certainty 95 and
			  b-age is teen with certainty 80 and
			  b-age is middle with certainty 90 and
			  b-age is youth with certainty 60))
			  		
  (rule (if agegroup is unknown)
        (then b-age is youth with certainty 60 and
		      b-age is middle with certainty 70 and
			  b-age is any with certainty 90 and
			  ;b-cause is Elderly with certainty 60 and
		      ;b-cause is Education with certainty 60 and
		      best-freq is adhoc with certainty 60))

;  (rule (if agegroup is unknown)
;        (then b-cause is Elderly with certainty 60 and
;		      b-cause is Education with certainty 60 and
;		      best-freq is adhoc with certainty 60))

  ; Rules for picking the best required skill
  ; Rules based on skill

  (rule (if skill is photography)
        (then b-skill-reqd is photography and
			  b-skill-reqd is OtherSkills with certainty 60 and
		      b-skill-reqd is Legal with certainty -100 and
		      b-skill-reqd is MedicalHealth with certainty -100 and
			  b-cause is Sports with certainty 40))

  (rule (if skill is coachtrain)
        (then b-skill-reqd is CoachingTraining))

;  (rule (if skill is humanresource)
;        (then b-skill-reqd is HumanResource))

  (rule (if skill is humanresource)
        (then b-skill-reqd is HumanResource and
			  b-age is middle with certainty 80))

  (rule (if skill is artsmusic)
        (then b-skill-reqd is ArtsMusic and
		      b-skill-reqd is MedicalHealth with certainty -100 and
			  b-cause is ChildrenYouth with certainty 70))

  (rule (if skill is firstaid)
        (then b-skill-reqd is NoSpecificSkillsRequired and
			  b-skill-reqd is dummy with certainty 60 and
			  b-skill-reqd is MedicalHealth with certainty 60 and
			  b-cause is Community with certainty 80 and
			  b-cause is Humanitarian with certainty 70 and
			  b-cause is Sports with certainty 40))

  (rule (if skill is cpr)
        (then b-skill-reqd is MedicalHealth with certainty 80))

  (rule (if skill is medicalhealth)
        (then b-cause is medical with certainty 80 and
			  b-cause is Elderly with certainty 80 and
              b-cause is Humanitarian with certainty 70 and
			  b-skill-reqd is MedicalHealth with certainty 80 and
			  b-age is youth with certainty 70 and
			  b-age is middle with certainty 80))

  (rule (if skill is volunteermgmt)
        (then b-skill-reqd is VolunteerManagement and
		      b-skill-reqd is HumanResource with certainty 80 and
			  b-cause is Community with certainty 70))

  (rule (if skill is counsellingmentoring)
        (then b-skill-reqd is CounsellingMentoring and
		      b-skill-reqd is HumanResource with certainty 70 and
			  b-skill-reqd is OtherSkills with certainty 70 and
			  b-cause is SocialService with certainty 70 and
			  b-age is middle with certainty 80))

  (rule (if skill is legal)
        (then b-skill-reqd is Legal and
			  b-cause is Community with certainty 70 and
			  b-age is youth with certainty 50 and
			  b-age is middle with certainty 80))

;  (rule (if skill is infotech)
;        (then b-skill-reqd is OtherSkills and
;		      b-skill-reqd is Legal with certainty -100 and
;			  b-cause is Education with certainty 70 and
;			  b-cause is ChildrenYouth with certainty 90))

  (rule (if skill is leaddevt)
        (then b-skill-reqd is LeadershipDevelopment and
			  b-cause is ChildrenYouth with certainty 60))

  (rule (if skill is befriend)
        (then b-skill-reqd is OtherSkills with certainty 60 and
			  b-skill-reqd is NoSpecificSkillsRequired with certainty 50 and
			  b-skill-reqd is dummy with certainty 50 and
			  b-skill-reqd is CounsellingMentoring with certainty 50 and
              b-cause is Health with certainty 70 and
              b-cause is Elderly with certainty 70 and
              b-cause is Disability with certainty 60 and
              b-cause is SocialService with certainty 60 and
			  b-cause is Community with certainty 60))

  (rule (if skill is earlychild)
        (then b-skill-reqd is NoSpecificSkillsRequired and
			  b-skill-reqd is OtherSkills with certainty 60 and
			  b-skill-reqd is VolunteerManagement with certainty -100 and
		      b-skill-reqd is Legal with certainty -100 and
              b-cause is Elderly with certainty -100 and
              b-cause is Environment with certainty -100 and
              b-cause is Education with certainty 90 and
			  b-cause is ChildrenYouth with certainty 90))

  (rule (if skill is specialneeds)
        (then b-skill-reqd is OtherSkills with certainty 80 and
			  b-skill-reqd is VolunteerManagement with certainty -100 and
		      b-skill-reqd is Legal with certainty -100 and
              b-cause is Health with certainty -60 and
              b-cause is SocialService with certainty 80 and
			  b-cause is Community with certainty 80))

  (rule (if skill is other)
        (then b-skill-reqd is OtherSkills with certainty 50 and
			  b-skill-reqd is NoSpecificSkillsRequired with certainty 80 and
			  b-skill-reqd is dummy with certainty 60 and
			  b-cause is medical with certainty 15))

  (rule (if skill is unknown)
        (then b-cause is Environment with certainty 60 and
			  b-cause is ChildrenYouth with certainty 40 and
		      b-skill-reqd is Legal with certainty -100 and
			  b-skill-reqd is MedicalHealth with certainty -100 and
			  b-skill-reqd is CounsellingMentoring with certainty -100 and
			  b-skill-reqd is OtherSkills with certainty 10 and
			  b-skill-reqd is NoSpecificSkillsRequired with certainty 80 and
			  b-skill-reqd is dummy with certainty 80))

  ; Rules for picking the best opening size
  ; Rules based on group size

  (rule (if mygroupsize is solo)
        (then b-openingsize is any and
		      b-openingsize is small with certainty 90 and
		      b-openingsize is medium with certainty 80 and
		      b-openingsize is 11plus with certainty 70))

  (rule (if mygroupsize is 2-5)
        (then b-openingsize is small and
		      b-openingsize is medium with certainty 90 and
		      b-openingsize is 11plus with certainty 80))
			  		
  (rule (if mygroupsize is 6-10)
        (then b-openingsize is medium))
			  		
  (rule (if mygroupsize is 11plus)
        (then b-openingsize is 11plus))
			  		
;  (rule (if mygroupsize is unknown)
;        (then b-openingsize is any and
;		      b-openingsize is small with certainty 40 and
;		      b-openingsize is 6-10 with certainty 60 and
;		      b-openingsize is 11plus with certainty 80))

  (rule (if mygroupsize is unknown)
        (then b-openingsize is any and
		      b-openingsize is small with certainty 80 and
		      b-openingsize is 6-10 with certainty 60 and
		      b-openingsize is 11plus with certainty 80))

  ; Rules for picking the best frequency
  ; Rules based on preferred frequency

  (rule (if preferred-freq is adhoc)
        (then best-freq is adhoc and
              best-freq is daily with certainty -50 and
              best-freq is weekly with certainty -30 and
              best-freq is monthly with certainty -10 and
              best-freq is annually with certainty -20 and
			  best-duration is lessthan8 with certainty 80 and
			  best-duration is am with certainty 70 and
			  best-duration is pm with certainty 70))

  (rule (if preferred-freq is annually)
        (then best-freq is annually))

  (rule (if preferred-freq is weekly)
        (then best-freq is weekly and
              best-freq is adhoc with certainty -100))

  (rule (if preferred-freq is unknown)
        (then best-freq is adhoc with certainty 80 and
              best-freq is daily with certainty 15 and
              best-freq is weekly with certainty 30 and
              best-freq is monthly with certainty 50 and
              best-freq is annually with certainty 60))
  
)

;;************************
;;* VWO SELECTION RULES *
;;************************

(defmodule VWOs (import MAIN ?ALL)
                 (export deffunction get-vwo-list))

(deffacts any-attributes
  (attribute (name best-freq) (value any))
  (attribute (name best-orgtype) (value any))
  (attribute (name best-area) (value any))
  (attribute (name best-duration) (value any))
  (attribute (name b-cause) (value any))
  (attribute (name b-dow) (value any))
  (attribute (name b-openingsize) (value any))
  (attribute (name b-skill-reqd) (value any))
  (attribute (name b-age) (value any)))

(deftemplate VWOs::vwo
  (slot name (default ?NONE))
  (multislot freq (default any))
  (multislot orgtype (default any))
  (multislot area (default any))
  (multislot duration (default any))
  (multislot wkend-wkday-any (default any))
  (multislot cause (default any))
  (multislot opening-size (default any))
  (multislot skill-reqd (default any))
  (multislot age-cat (default any)))

(deffacts VWOs::the-vwo-list 
  (vwo (name ChineseDevelopmentAssistanceCouncil-2018MandarinNewsReadingandSharingProgramme) (freq adhoc) (wkend-wkday-any weekday) (duration lessthan8) (age-cat teen) (opening-size small) (cause Elderly  ) (area west) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name SINGAPOREHEARTFOUNDATION-VWOFairFuhuaSecondarySchool) (freq adhoc) (duration am) (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area west) (cause ChildrenYouth Community Elderly) (skill-reqd OtherSkills NoSpecificSkillsRequired ))
(vwo (name PresidentsChallenge-HelpusraisefundsforPCattheIstanaOpenHouse) (freq adhoc) (duration am) (wkend-wkday-any weekday) (age-cat teen) (opening-size 11plus) (area islandwide) (cause ChildrenYouth Disability Elderly) (skill-reqd NoSpecificSkillsRequired  ))
  (vwo (name SingaporeRedCrossSociety-Elderaidbefriender) (freq adhoc) (duration flexible) (wkend-wkday-any anyday) (age-cat middle) (opening-size 11plus) (area east) (cause Community Elderly Humanitarian) (skill-reqd dummy  ))
  (vwo (name PresbyterianCommunityServices-CommunityBefriendingProgramme) (freq adhoc) (duration flexible) (wkend-wkday-any anyday) (age-cat middle) (opening-size small) (area central) (cause Community Elderly SocialService) (skill-reqd ArtsMusic CounsellingMentoring MedicalHealth))
  (vwo (name SingYouthHub-Transporterneededforcharityevent_adhocbasis) (freq adhoc) (duration flexible) (wkend-wkday-any anyday) (age-cat youth) (opening-size small) (area north) (cause ChildrenYouth Community Education) (skill-reqd NoSpecificSkillsRequired  ))
  (vwo (name SingYouthHub-AdminworkforSingYouthHub) (freq adhoc) (duration flexible) (wkend-wkday-any anyday) (age-cat youth) (opening-size small) (area central) (cause ChildrenYouth Community Education) (skill-reqd NoSpecificSkillsRequired  ))
  (vwo (name AllSaintsHome-BeanAllSaintsHomeVolunteer) (freq adhoc) (duration pm) (wkend-wkday-any weekend) (age-cat teen) (opening-size 11plus) 	(area north) (cause Community Elderly Health) (skill-reqd NoSpecificSkillsRequired  ))
  (vwo (name MettaWelfareAssociation-VolunteerPhotographerforMettaCharityGolfTournament2018) (freq adhoc) (duration wholeday)
             (wkend-wkday-any weekday) (age-cat youth) (opening-size small) (area northeast)
             (cause ChildrenYouth Disability Elderly) (skill-reqd OtherSkills  ))
  (vwo (name YishunCommunityHospital-MobileLibraryinthewardsEveryWednesday930am1130am) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size 11plus) (area north)
             (cause Community Education Elderly) (skill-reqd NoSpecificSkillsRequired  ))
  (vwo (name AMKFSCCommunityServices-BringingJoytoourSeniorsSeniorActivityHubPunggol) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size 11plus) (area northeast)
             (cause Elderly Community ) (skill-reqd ArtsMusic CoachingTraining ))
  (vwo (name EconomicDevelopmentInnovationsSingaporePteLtd-EarlyLearningProgrammeBeyondSocialServicesBukitMerah) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size medium) (area central) (cause ChildrenYouth Education ) (skill-reqd NoSpecificSkillsRequired  ))
  (vwo (name SAGECounsellingCentre-SeniorsHelpdeskVolunteering) (freq adhoc) (duration lessthan8) (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area west) (cause Elderly) (skill-reqd NoSpecificSkillsRequired))
  (vwo (name NewHopeCommunityServices-Tutoring) (freq weekly) (duration wholeday) (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area north) (cause ChildrenYouth Community Education) (skill-reqd dummy ))
  (vwo (name YMCAofSingapore-YMakanFellowship) (freq adhoc) (duration am)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size medium) (area central)
             (cause Community Elderly SocialService) (skill-reqd NoSpecificSkillsRequired  ))
  (vwo (name AssociationforEarlyChildhoodEducatorsSingapore-ProjectHandinHand) (freq weekly) (duration multiple)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size 11plus) (area islandwide)
             (cause ChildrenYouth Community Education) (skill-reqd NoSpecificSkillsRequired  ))
  (vwo (name EnCommunityServicesSociety-ThursdayMorningUkuleleTNCC) (freq weekly) (duration wholeday) (wkend-wkday-any weekday) (age-cat youth) (opening-size small) (area east) (cause ArtsHeritage Community Education) (skill-reqd ArtsMusic CoachingTraining HumanResource))
  (vwo (name HeartToHeartService-FoodDistributionServices) (freq adhoc) (duration flexible)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area central)
             (cause Community Elderly Families) (skill-reqd VolunteerManagement NoSpecificSkillsRequired ))
  (vwo (name ThyeHuaKwanNursingHomeLimited-RegularVolunteers) (freq adhoc) (duration flexible)
             (wkend-wkday-any anyday) (age-cat teen) (opening-size 11plus) (area northeast)
             (cause Community Disability Elderly) (skill-reqd VolunteerManagement  ))
  (vwo (name SingaporeAnglicanCommunityServices-LanguageClasses) (freq weekly) (duration wholeday)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area west)
             (cause ArtsHeritage Community Education) (skill-reqd  dummy ))
  (vwo (name TheNationalKidneyFoundation-FundraisingTianJunTemple) (freq adhoc) (duration pm) (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast) (cause Community Disability Elderly) (skill-reqd NoSpecificSkillsRequired  ))
  (vwo (name CareCommunityServicesSociety-SembawangdKlubMentoringProgrammeP3P6) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area north)
             (cause ChildrenYouth Community Education) (skill-reqd NoSpecificSkillsRequired  ))
  (vwo (name SingaporeRedCrossSociety-SRCSouthEastDistrictElderAidProgramme) (freq adhoc) (duration flexible) (wkend-wkday-any anyday) (age-cat teen) (opening-size 11plus) (area east) (cause Community Disability Elderly) (skill-reqd NoSpecificSkillsRequired  ))
  (vwo (name LionsBefriendersServiceAssociation-BefriendaSenior) (freq weekly) (duration wholeday)
             (wkend-wkday-any anyday) (age-cat teen) (opening-size 11plus) (area central)
             (cause Community Elderly SocialService) (skill-reqd NoSpecificSkillsRequired  ))
  (vwo (name TheSalvationArmy-PrisonSupportServicesGroupSessions) (freq adhoc) (duration pm) (wkend-wkday-any weekend) (age-cat youth) (opening-size 11plus) (area central) (cause ChildrenYouth  ) (skill-reqd OtherSkills  ))
  (vwo (name CalvaryCommunityCare-VolunteerAdministratorSeniors) (freq weekly) (duration wholeday)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast)
             (cause Community Elderly ) (skill-reqd dummy  ))
  (vwo (name MeTooClubMINDS-PhysicalActivitieswithMeTooClubEveryTuesday) (freq adhoc) (duration pm) (wkend-wkday-any weekday) (age-cat teen) (opening-size 11plus) (area central) (cause Community Disability Families) (skill-reqd dummy  ))
  (vwo (name YMCAofSingapore-YOutingBlueCross) (freq adhoc) (duration am)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size medium) (area west)
             (cause Disability  ) (skill-reqd NoSpecificSkillsRequired  ))
  (vwo (name AngMoKioThyeHuaKwanHospital-Bingo) (freq adhoc) (duration pm) (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast) (cause Elderly  ) (skill-reqd  dummy ))
  (vwo (name YishunCommunityHospital-RooftopGardeningAtleast6months830am11am) (freq weekly) (duration multiple) (wkend-wkday-any weekday) (age-cat teen) (opening-size 11plus) (area north) (cause Community Environment Health) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name SamaritansofSingapore-LendalisteningearBeanSOShotlinevolunteer) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat youth) (opening-size 11plus) (area central)
             (cause Community SocialService ) (skill-reqd dummy  ))
(vwo (name SingaporeAnglicanCommunityServices-CookingClass) (freq weekly) (duration multiple)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area west)
             (cause Community Elderly Families) (skill-reqd dummy  ))
(vwo (name RenCiHospital-BingowithResidentsRenCiCommunityHospital) (freq adhoc) (duration am)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size 11plus) (area central)
             (cause Community Elderly Health) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name PeoplesMovementtoStopHaze-HazeIntelligence) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area central)
             (cause ChildrenYouth Education Environment) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name GroundUpInitiativeGUI-CraftworkMaintenanceKampungKampus) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area north)
             (cause Community Education Environment) (skill-reqd dummy  ))
(vwo (name CareCommunityServicesSociety-dKlubMentoringProgrammeP3P6) (freq weekly) (duration wholeday)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size 11plus) (area islandwide)
             (cause ChildrenYouth Community Education) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name YMCAofSingapore-YSportsClementiMINDS) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area west)
             (cause Disability Sports ) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name YMCAofSingapore-YPhotoClubAPSNCFA) (freq adhoc) (duration am)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size small) (area central)
             (cause Disability SocialService ) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name CareCommunityServicesSociety-TutorsforCareHutProgramme) (freq weekly) (duration wholeday)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size 11plus) (area islandwide)
             (cause ChildrenYouth Community SocialService) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name SingaporeDisabilitySportsCouncil-TigerBalmBocciaInvitationalSingapore2018) (freq adhoc) (duration wholeday)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area central)
             (cause Disability Sports ) (skill-reqd LeadershipDevelopment MarketingCommunications VolunteerManagement))
(vwo (name YMCAofSingapore-YVisitBizlink) (freq adhoc) (duration pm) (wkend-wkday-any weekday) (age-cat teen) (opening-size 11plus) (area east) (cause Community Disability SocialService) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name EconomicDevelopmentInnovationsSingaporePteLtd-EarlyLearningProgrammeFaithActsCommonwealth) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size medium) (area central)
             (cause ChildrenYouth Education ) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name YMCAofSingapore-YOutingHandicapsWelfareAssociation) (freq adhoc) (duration am)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size 11plus) (area central)
             (cause Community Disability Elderly) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name SpecialOlympicsSingapore-SpecialOlympicsSingaporeUnifiedFloorballTeamMale) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekend) (age-cat youth) (opening-size medium) (area central)
             (cause ChildrenYouth Community Disability) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name TheNewCharisMission-FreeHaircut) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast)
             (cause Elderly  ) (skill-reqd OtherSkills  ))
(vwo (name CalvaryCommunityCare-BeaYouthMentorACEProgramme) (freq weekly) (duration wholeday)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area central)
             (cause ChildrenYouth Education Sports) (skill-reqd OtherSkills  ))
(vwo (name MigrantWorkersCentre-MWCHelpKiosk) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area west)
             (cause SocialService  ) (skill-reqd dummy  ))
(vwo (name AMKFSCCommunityServices-EnrichingourchildrenAchievingKidsandKins) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area northeast)
             (cause ChildrenYouth  ) (skill-reqd dummy  ))
(vwo (name YMCAofSingapore-YOutingAPSNCFA) (freq adhoc) (duration am)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size 11plus) (area central)
             (cause Community Disability ) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name SingaporeRedCrossSociety-ShopRedcrossProgramme) (freq weekly) (duration multiple)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area central)
             (cause Community Disability Elderly) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name PresbyterianCommunityServices-CommunityBefriendingProgramme) (freq adhoc) (duration flexible)
             (wkend-wkday-any anyday) (age-cat middle) (opening-size 11plus) (area central)
             (cause Community Elderly SocialService) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name MontfortCare-MedicalEscortTrainingSession) (freq adhoc) (duration am)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size 11plus) (area central)
             (cause Community Disability Elderly) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name LovingHeartMultiServiceCentreJurong-FreeTuitionProgramme) (freq adhoc) (duration lessthan8) (wkend-wkday-any weekday) (age-cat teen) (opening-size 11plus) (area west) (cause ChildrenYouth Education Elderly) (skill-reqd OtherSkills  ))
(vwo (name YMCAofSingapore-ISPMyanmarMaubinOpenTeam28Apr6May2018) (freq adhoc) (duration wholeday) (wkend-wkday-any weekend) (age-cat teen) (opening-size medium) (area overseas) (cause ChildrenYouth Community Education) (skill-reqd dummy  ))
(vwo (name SingaporeCancerSociety-SingaporeCancerSocietyRelayforLife2018) (freq adhoc) (duration pm)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size 11plus) (area central)
             (cause Community Health SocialService) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name YMCAofSingapore-YSportsClementiMINDS) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area west)
             (cause Disability Sports ) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name SingaporeAnglicanCommunityServices-BakingClass) (freq weekly) (duration wholeday)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area west)
             (cause Community Elderly Families) (skill-reqd dummy  ))
(vwo (name PresbyterianCommunityServices-CommunityBefriendingProgramme) (freq adhoc) (duration flexible)
             (wkend-wkday-any anyday) (age-cat middle) (opening-size medium) (area east)
             (cause Community Elderly SocialService) (skill-reqd ArtsMusic CounsellingMentoring OtherSkills))
(vwo (name AllSaintsHome-BeanAllSaintsHomeVolunteer) (freq adhoc) (duration pm)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size 11plus) (area east)
             (cause Community Elderly Health) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name ASSOCIATIONFORPERSONSWITHSPECIALNEEDS-DeliveryDistributionofvegetarianmealstoElderlyHome) (freq weekly) (duration multiple)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area east)
             (cause Community Elderly SocialService) (skill-reqd OtherSkills  ))
(vwo (name PresbyterianCommunityServices-CommunityBefriendingProgramme) (freq adhoc) (duration flexible)
             (wkend-wkday-any anyday) (age-cat middle) (opening-size small) (area central)
             (cause Community Elderly SocialService) (skill-reqd dummy  ))
(vwo (name MontfortCare-ChildMinding) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area central)
             (cause ChildrenYouth Community Families) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name CommunityNetworksforSeniors-Befriendaseniorlivingnearyou) (freq adhoc) (duration flexible)
             (wkend-wkday-any anyday) (age-cat teen) (opening-size 11plus) (area islandwide)
             (cause Community Elderly Health) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name ProjectCARE-ProjectCARECaringwithAuthenticityRespectforElders) (freq adhoc) (duration am)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size 11plus) (area east)
             (cause Community Elderly SocialService) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name BrightVisionHospital-MiniPatientOuting) (freq adhoc) (duration lessthan8) (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast) (cause Elderly Health ) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name EnCommunityServicesSociety-FridayMorningCraftworkVolunteers) (freq weekly) (duration wholeday)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area east)
             (cause ArtsHeritage Community Education) (skill-reqd ArtsMusic CoachingTraining CounsellingMentoring))
(vwo (name SingaporeAnglicanCommunityServices-ExerciseWorkoutClasses) (freq adhoc) (duration flexible)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area west)
             (cause Community Families Health) (skill-reqd dummy  ))
(vwo (name ChineseDevelopmentAssistanceCouncil-2018MandarinNewsReadingandSharingProgramme) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast)
             (cause Elderly  ) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name FocusontheFamilySingaporeLimited-SUPPORTDAILYOPERATIONSFocusontheFamily) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area central)
             (cause ChildrenYouth Community Education) (skill-reqd dummy  ))
(vwo (name MeTooClubMINDS-HomeBefriendingwithMeTooClub6Months) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size 11plus) (area islandwide)
             (cause Community Disability Families) (skill-reqd dummy  ))
(vwo (name CareCommunityServicesSociety-QueenstowndKlubMentoringProgrammeP3P6) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area central)
             (cause ChildrenYouth Community Education) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name BoysTown-BoysTownFlagDay2018) (freq adhoc) (duration am)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size 11plus) (area central)
             (cause ChildrenYouth Community Families) (skill-reqd OtherSkills  ))
(vwo (name YoungWomensChristianAssociationofSingapore-YWCAEmpoweringMumProgramme) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size 11plus) (area central)
             (cause Community Families WomenGirls) (skill-reqd dummy  ))
(vwo (name InfantJesusHomesChildrensCentres-Tutoring) (freq weekly) (duration multiple)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast)
             (cause ChildrenYouth  ) (skill-reqd OtherSkills  ))
(vwo (name LakesideFamilyServices-ExpeditionAgape) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekend) (age-cat youth) (opening-size 11plus) (area west)
             (cause ChildrenYouth Community Education) (skill-reqd CounsellingMentoring OtherSkills ))
(vwo (name SPDformerlySocietyforthePhysicallyDisabled-SPDFlagDay2018) (freq adhoc) (duration wholeday) (wkend-wkday-any weekend) (age-cat teen) (opening-size 11plus) (area central) (cause Disability  ) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name BlossomWorldSociety-BlossomWorldFlagDay) (freq adhoc) (duration am)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size 11plus) (area islandwide)
             (cause ChildrenYouth Community Education) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name SingaporeAnglicanCommunityServices-MusicAppreciation) (freq weekly) (duration wholeday)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area west)
             (cause Community Families Health) (skill-reqd ArtsMusic  ))
(vwo (name TheNationalKidneyFoundation-FundraisingThiamHockKeng) (freq adhoc) (duration pm)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size small) (area central)
             (cause Community Disability Elderly) (skill-reqd Fundraising NoSpecificSkillsRequired ))
(vwo (name HCAHOSPICECARE-LendaHelpingHand) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size 11plus) (area islandwide)
             (cause Elderly Health ) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name AMKFSCCommunityServices-BakingforlowincomefamiliesBakeryHearts) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast)
             (cause Families  ) (skill-reqd dummy  ))
(vwo (name AMKFSCCommunityServices-EnrichingourchildrenBASICStudentCareServicesAngMoKio) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast)
             (cause ChildrenYouth  ) (skill-reqd dummy  ))
(vwo (name SingaporeCancerSociety-SingaporeCancerSocietyRelayforLife2018) (freq adhoc) (duration pm)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size 11plus) (area central)
             (cause Community Health SocialService) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name CalvaryCommunityCare-VolunteersneededOTAGOExerciseforseniors) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size 11plus) (area central)
             (cause Community Elderly Health) (skill-reqd OtherSkills  ))
(vwo (name PioneerGenerationOffice-PioneerGenerationAmbassadorsPGARecruitmentTalkRSVPSingapore) (freq weekly) (duration wholeday)
             (wkend-wkday-any anyday) (age-cat teen) (opening-size 11plus) (area central)
             (cause Community Education Elderly) (skill-reqd OtherSkills NoSpecificSkillsRequired ))
(vwo (name LearnInPteLtd-EnablingFuturesLifeskillsfortheDigitalEconomyAWWA) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size small) (area northeast)
             (cause ChildrenYouth Community Disability) (skill-reqd CounsellingMentoring NoSpecificSkillsRequired ))
(vwo (name YishunCommunityHospital-Portersrequiredatleast6months) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat youth) (opening-size small) (area north)
             (cause Community Elderly Health) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name YMCAofSingapore-YSpringCleanTeckGhee) (freq adhoc) (duration am) (wkend-wkday-any weekend) (age-cat teen) (opening-size medium) (area northeast) (cause Community Elderly SocialService) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name SouthCentralCommunityFamilyServiceCentreLimited-TutoringOpportunitiesforWorkingAdults) (freq adhoc) (duration flexible)
             (wkend-wkday-any anyday) (age-cat teen) (opening-size medium) (area central)
             (cause ChildrenYouth Families SocialService) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name TheNationalKidneyFoundation-PatientEscort) (freq adhoc) (duration flexible)
             (wkend-wkday-any anyday) (age-cat youth) (opening-size medium) (area islandwide)
             (cause Disability Elderly Health) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name MontfortCare-VolunteerTutor) (freq weekly) (duration wholeday)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area central)
             (cause ChildrenYouth Families ) (skill-reqd OtherSkills  ))
(vwo (name SingaporeAnglicanCommunityServices-ReadingClub) (freq weekly) (duration wholeday)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area west)
             (cause Community Families Health) (skill-reqd dummy  ))
(vwo (name LearnInPteLtd-EnablingFuturesLifeskillsfortheDigitalEconomyAWWA) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size small) (area northeast)
             (cause ChildrenYouth Community Disability) (skill-reqd CounsellingMentoring NoSpecificSkillsRequired ))
(vwo (name YMCAofSingapore-YVisitCOH) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area central)
             (cause Community Disability SocialService) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name StLukesHospital-VolunteeringOpportunities) (freq adhoc) (duration flexible)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area west)
             (cause Community Disability Elderly) (skill-reqd VolunteerManagement OtherSkills ))
(vwo (name BethesdaCommunityAssistanceandRelationshipEnrichmentCentre-BCAREAcademicAssistanceProgrammeforLowIncomeFamilies) (freq weekly) (duration wholeday)
             (wkend-wkday-any weekday) (age-cat youth) (opening-size small) (area northeast)
             (cause ChildrenYouth Community Education) (skill-reqd CoachingTraining  ))
(vwo (name SingaporeRedCrossSociety-Elderaidbefriender) (freq adhoc) (duration flexible)
             (wkend-wkday-any anyday) (age-cat middle) (opening-size 11plus) (area north)
             (cause Community Elderly Humanitarian) (skill-reqd dummy  ))
(vwo (name AllSaintsHome-BeanAllSaintsHomeVolunteer) (freq adhoc) (duration pm)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size 11plus) (area west)
             (cause Community Elderly Health) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name SINGAPOREHEARTFOUNDATION-SaveALife) (freq adhoc) (duration am) (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area west) (cause Community Education Health) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name BrightVisionHospital-MahjongSession) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast)
             (cause Community Elderly ) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name StudentsCareService-EngagechildrenandyouthsatSCS) (freq adhoc) (duration flexible)
             (wkend-wkday-any anyday) (age-cat teen) (opening-size small) (area northeast)
             (cause ChildrenYouth Education Families) (skill-reqd dummy  ))
(vwo (name NationalHeritageBoard-MonumentWalkingTours) (freq adhoc) (duration flexible)
             (wkend-wkday-any anyday) (age-cat teen) (opening-size small) (area central)
             (cause ArtsHeritage Community Education) (skill-reqd VolunteerManagement  ))
(vwo (name MigrantWorkersCentre-MWCHelpKiosk) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area north)
             (cause SocialService  ) (skill-reqd dummy  ))
(vwo (name AMKFSCCommunityServices-EnrichingourchildrenBASICStudentCareServicesChengSan) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast)
             (cause ChildrenYouth  ) (skill-reqd dummy  ))
(vwo (name YongenCareCentre-Tuition) (freq weekly) (duration wholeday)
             (wkend-wkday-any anyday) (age-cat teen) (opening-size medium) (area central)
             (cause ChildrenYouth  ) (skill-reqd OtherSkills  ))
(vwo (name MigrantWorkersCentre-MWCHelpKiosk) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area west)
             (cause SocialService  ) (skill-reqd dummy  ))
(vwo (name YishunCommunityHospital-PatientSitterVolunteer) (freq adhoc) (duration flexible)
             (wkend-wkday-any anyday) (age-cat youth) (opening-size 11plus) (area north)
             (cause Community Elderly Health) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name WISEWASHinSoutheastAsiaLimited-Trainingandmentoringprogram) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast)
             (cause Community Environment Health) (skill-reqd CoachingTraining VolunteerManagement OtherSkills))
(vwo (name CalvaryCommunityCare-BriskWalkingWithSeniors) (freq adhoc) (duration am)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast)
             (cause Community Elderly ) (skill-reqd dummy  ))
(vwo (name OperationHopeFoundation-HousebuildingprojectinCambodia) (freq adhoc) (duration wholeday)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size 11plus) (area central)
             (cause ChildrenYouth Community Humanitarian) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name SINGAPORESILATFEDERATION-NationalPencaksilatChampionship) (freq adhoc) (duration flexible) (wkend-wkday-any anyday) (age-cat teen) (opening-size small) (area east) (cause ChildrenYouth Community Education) (skill-reqd LeadershipDevelopment VolunteerManagement OtherSkills))
(vwo (name EmpowerAgeingLimited-DementiaOutingProject) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area central)
             (cause Community Elderly Health) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name PresbyterianCommunityServices-CommunityBefriendingProgramme) (freq adhoc) (duration flexible)
             (wkend-wkday-any anyday) (age-cat middle) (opening-size 11plus) (area northeast)
             (cause Community Elderly SocialService) (skill-reqd ArtsMusic CounsellingMentoring MedicalHealth))
(vwo (name YMCAofSingapore-YMakanFellowship2018) (freq adhoc) (duration am)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size medium) (area central)
             (cause Community Disability Elderly) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name ChineseDevelopmentAssistanceCouncil-2018MandarinNewsReadingandSharingProgramme) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area west)
             (cause Elderly  ) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name LearnInPteLtd-EnablingFuturesLifeskillsfortheDigitalEconomyMINDS) (freq adhoc) (duration pm)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size small) (area central)
             (cause ChildrenYouth Community Disability) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name SingaporeRedCrossSociety-SocialWorkerNetwork) (freq adhoc) (duration flexible)
             (wkend-wkday-any anyday) (age-cat teen) (opening-size 11plus) (area central)
             (cause Community Disability Humanitarian) (skill-reqd OtherSkills  ))
(vwo (name SingaporeAnglicanCommunityServices-SimpleScienceWorkshop) (freq weekly) (duration wholeday)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area west)
             (cause Community Elderly Families) (skill-reqd dummy  ))
(vwo (name SingaporeAnglicanCommunityServices-EntertainmentSessionHobbies/Games) (freq weekly) (duration multiple)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area west)
             (cause Community Elderly Families) (skill-reqd dummy  ))
(vwo (name AMKFSCCommunityServices-EnrichingourchildrenBASICStudentCareServicesSengkang) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast)
             (cause ChildrenYouth  ) (skill-reqd dummy  ))
(vwo (name SouthCentralCommunityFamilyServiceCentreLimited-WeeklyEnglishTutoringforPrimarySchoolStudents) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area central)
             (cause ChildrenYouth Education Families) (skill-reqd dummy  ))
(vwo (name BrightVisionHospital-WardBirthdayCelebration) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area northeast)
             (cause Community Elderly Health) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name SingaporeCancerSociety-SingaporeCancerSocietyCallManagementCentre) (freq adhoc) (duration flexible) (wkend-wkday-any anyday) (age-cat youth) (opening-size small) (area central) (cause Community Health SocialService) (skill-reqd OtherSkills  ))
(vwo (name YoungWomensChristianAssociationofSingapore-VolunteeringwithYWCAWorkzonWheelsWoWprogramme) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area northeast)
             (cause ChildrenYouth Community ) (skill-reqd OtherSkills  ))
(vwo (name VolunteerBikePatrol-Volunteersforsharedbikepatrols) (freq adhoc) (duration flexible)
             (wkend-wkday-any anyday) (age-cat teen) (opening-size 11plus) (area islandwide)
             (cause Community Environment ) (skill-reqd dummy  ))
(vwo (name TheNewCharisMission-Befriending/Cleaning) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area northeast)
             (cause Elderly  ) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name TheNewCharisMission-FreeHaircut) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast)
             (cause Elderly  ) (skill-reqd OtherSkills  ))
(vwo (name AWWALtd-LunchAssistantforSeniors) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast)
             (cause Elderly Health ) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name YMCAofSingapore-YOutingSarahSeniorsActivityCentre) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area central)
             (cause Community Disability Elderly) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name MigrantWorkersCentre-MWCHelpKiosk) (freq adhoc) (duration pm)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area central)
             (cause SocialService  ) (skill-reqd dummy  ))
(vwo (name SingaporeAnglicanCommunityServices-CraftWorkshop) (freq weekly) (duration wholeday)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area west)
             (cause ArtsHeritage Community SocialService) (skill-reqd ArtsMusic  ))
(vwo (name ChineseDevelopmentAssistanceCouncil-2018MandarinNewsReadingandSharingProgramme) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area northeast)
             (cause Elderly  ) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name BrightVisionHospital-BVHFlagDay2018) (freq adhoc) (duration pm)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size 11plus) (area islandwide)
             (cause Elderly Health ) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name SingYouthHub-LegalworksforSingYouthHub) (freq adhoc) (duration flexible)
             (wkend-wkday-any anyday) (age-cat youth) (opening-size small) (area central)
             (cause ChildrenYouth Community Education) (skill-reqd Legal OtherSkills ))
(vwo (name SingaporeRedCrossSociety-WorldBloodDonorDay) (freq adhoc) (duration am) (wkend-wkday-any weekend) (age-cat teen) (opening-size medium) (area central) (cause Community Health Humanitarian) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name BoysTown-SeekingKitchenAssistantforculinaryprogramme) (freq weekly) (duration wholeday)
             (wkend-wkday-any weekend) (age-cat youth) (opening-size small) (area east)
             (cause ChildrenYouth Community Families) (skill-reqd OtherSkills  ))
(vwo (name TheCreightCompany-ArtCraftFingerknitting) (freq adhoc) (duration am)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size small) (area central)
             (cause Community Elderly Health) (skill-reqd ArtsMusic NoSpecificSkillsRequired ))
(vwo (name AllSaintsHome-BeanAllSaintsHomeVolunteer) (freq adhoc) (duration pm)
             (wkend-wkday-any weekend) (age-cat teen) (opening-size 11plus) (area northeast)
             (cause Community Elderly Health) (skill-reqd NoSpecificSkillsRequired  ))
(vwo (name MorningStarCommunityServicesLtd-CareNightsBedokNorth) (freq adhoc) (duration lessthan8)
             (wkend-wkday-any weekday) (age-cat teen) (opening-size medium) (area east)
             (cause ChildrenYouth Community Families) (skill-reqd CoachingTraining OtherSkills ))
(vwo (name BoysTown-GuestChefneeded) (freq adhoc) (duration pm) (wkend-wkday-any weekday) (age-cat youth) (opening-size small) (area east) (cause ChildrenYouth Community Families) (skill-reqd OtherSkills  )))
  
(defrule VWOs::generate-VWOs
  (vwo (name ?name)
        (freq $? ?q $?)
        (orgtype $? ?t $?)
        (area $? ?a $?)
		(duration $? ?d $?)
		(cause $? ?c $?)
		(wkend-wkday-any $? ?w $?)
		(opening-size $? ?o $?)
		(skill-reqd $? ?s $?)
		(age-cat $? ?g $?))
  (attribute (name best-freq) (value ?q) (certainty ?certainty-1))
  (attribute (name best-orgtype) (value ?t) (certainty ?certainty-2))
  (attribute (name best-area) (value ?a) (certainty ?certainty-3))
  (attribute (name best-duration) (value ?d) (certainty ?certainty-4))
  (attribute (name b-cause) (value ?c) (certainty ?certainty-5))
  (attribute (name b-dow) (value ?w) (certainty ?certainty-6))
  (attribute (name b-openingsize) (value ?o) (certainty ?certainty-7))
  (attribute (name b-skill-reqd) (value ?s) (certainty ?certainty-8))
  (attribute (name b-age) (value ?g) (certainty ?certainty-9))
  =>
  (assert (attribute (name vwo) (value ?name)
                     (certainty (min ?certainty-1 ?certainty-2 ?certainty-3 ?certainty-4 ?certainty-5 ?certainty-6 ?certainty-7 ?certainty-8 ?certainty-9)))))

(deffunction VWOs::vwo-sort (?w1 ?w2)
   (< (fact-slot-value ?w1 certainty)
      (fact-slot-value ?w2 certainty)))
      
(deffunction VWOs::get-vwo-list ()
  (bind ?facts (find-all-facts ((?f attribute))
                               (and (eq ?f:name vwo)
                                    (>= ?f:certainty 15))))
  (sort vwo-sort ?facts))
  

