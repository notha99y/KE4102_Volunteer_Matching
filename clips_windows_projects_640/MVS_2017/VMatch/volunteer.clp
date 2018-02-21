
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

  ; Rules for picking the best organisation type

  (rule (if has-sauce is yes and
            sauce is spicy)
        (then best-orgtype is ss.women))

  (rule (if preferred-orgtype is animal)
        (then best-orgtype is animal))

  (rule (if preferred-location is delicate)
        (then best-orgtype is ss.children))

  (rule (if preferred-location is average)
        (then best-orgtype is ss.children with certainty 30 and
              best-orgtype is medical with certainty 60 and
              best-orgtype is ss.women with certainty 30))

  (rule (if skill is firstaid)
        (then best-orgtype is medical with certainty 80 and
              best-orgtype is ss.women with certainty 10))

  (rule (if skill is unknown)
        (then best-orgtype is medical with certainty 20 and
              best-orgtype is sports with certainty 40 and
			  best-orgtype is ss.women with certainty 40))

  (rule (if has-sauce is yes and
            sauce is cream)
        (then best-orgtype is medical with certainty 40 and
              best-orgtype is ss.women with certainty 60))

  (rule (if preferred-orgtype is ss.women)
        (then best-orgtype is ss.women with certainty 80))

  (rule (if preferred-orgtype is medical)
        (then best-orgtype is medical with certainty 90))

  (rule (if preferred-orgtype is ss.children)
        (then best-orgtype is ss.children with certainty 80))

  (rule (if preferred-orgtype is ss.children and
            best-orgtype is ss.women)
        (then best-orgtype is medical))

  (rule (if preferred-orgtype is ss.women and
            best-orgtype is ss.children)
        (then best-orgtype is medical))

  (rule (if preferred-orgtype is unknown)
        (then best-orgtype is ss.children with certainty 20 and
              best-orgtype is sports with certainty 35 and
              best-orgtype is medical with certainty 20 and
              best-orgtype is animal with certainty 20 and
              best-orgtype is ss.women with certainty 20))

  (rule (if cause is health and
            has-turkey is no)
        (then best-orgtype is sports with certainty 75))

  ; Rules for picking the best frequency

  (rule (if cause is socialservice)
        (then best-freq is adhoc with certainty 90))

  (rule (if cause is health and
            has-turkey is no)
        (then best-freq is adhoc with certainty 30))

  (rule (if cause is disability)
        (then best-freq is annually))

  (rule (if cause is-not disability and
            has-sauce is yes and
            sauce is tomato)
        (then best-freq is adhoc))

  (rule (if has-sauce is yes and
            sauce is cream)
        (then best-freq is annually with certainty 40))

  (rule (if preferred-freq is adhoc)
        (then best-freq is adhoc with certainty 99))

  (rule (if preferred-freq is annually)
        (then best-freq is annually with certainty 99))

  (rule (if preferred-freq is unknown)
        (then best-freq is adhoc with certainty 60 and
              best-freq is annually with certainty 40))

  ; Rules for picking the best area

  ; (rule (if has-sauce is yes and
  ;          sauce is sweet)
  ;      (then best-area is east with certainty 90 and
  ;            best-area is northeast with certainty 40))

  (rule (if preferred-area is north)
        (then best-area is north with certainty 80))

  (rule (if preferred-area is northeast)
        (then best-area is northeast with certainty 80))

  (rule (if preferred-area is east)
        (then best-area is east with certainty 90))

  (rule (if preferred-area is west)
        (then best-area is west with certainty 90))

  (rule (if preferred-area is south)
        (then area is south and
		      best-area is south))

  (rule (if best-area is east and
            preferred-area is north)
        (then best-area is northeast))

  (rule (if best-area is north and
            preferred-area is east)
        (then best-area is northeast))

  (rule (if preferred-area is unknown)
        (then best-area is north with certainty 20 and
              best-area is northeast with certainty 20 and
              best-area is south with certainty 20 and
              best-area is central with certainty 20 and
              best-area is west with certainty 20 and
              best-area is east with certainty 20))

  (rule (if skill is unknown)
        (then best-area is north with certainty 20 and
              best-area is northeast with certainty 20 and
              best-area is south with certainty 20 and
              best-area is central with certainty 20 and
              best-area is west with certainty 20 and
              best-area is east with certainty 20))

  ; Rules for picking the best duration

  (rule (if preferred-duration is halfdayless)
        (then best-duration is halfdayless with certainty 80))

  (rule (if preferred-duration is unknown)
        (then best-duration is flexible with certainty 85 and
		      best-duration is halfdayless with certainty 80 and
			  best-duration is wholeday with certainty 80))

  ; Rules for picking the best cause

  (rule (if p-cause is socialservice)
        (then b-cause is socialservice with certainty 80))

  (rule (if p-cause is health)
        (then b-cause is health with certainty 85 and
			  b-cause is medical with certainty 85))

  (rule (if p-cause is unknown)
        (then b-cause is medical with certainty 20 and
		      b-cause is children with certainty 20 and
		      b-cause is elderly with certainty 20 and
		      b-cause is youth with certainty 20 and
		      b-cause is education with certainty 20 and
			  b-cause is health with certainty 20))

  (rule (if skill is unknown)
        (then b-cause is medical with certainty 20 and
              b-cause is sports with certainty 60 and
              b-cause is family with certainty 60 and
			  b-cause is ss.women with certainty 80))

  ; Rules for picking the best age

  (rule (if agegroup is 16-20)
        (then b-age is teens with certainty 80))

  (rule (if agegroup is 21-35)
        (then b-age is youth with certainty 85 and
			  b-age is any with certainty 85 and
			  b-age is middle with certainty 60))

  (rule (if agegroup is unknown)
        (then b-age is youth with certainty 20 and
		      b-age is middle with certainty 20 and
			  b-age is any with certainty 20))

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
  (attribute (name b-age) (value any)))

(deftemplate VWOs::vwo
  (slot name (default ?NONE))
  (multislot freq (default any))
  (multislot orgtype (default any))
  (multislot area (default any))
  (multislot duration (default any))
  (multislot cause (default any))
  (multislot age (default any)))

(deffacts VWOs::the-vwo-list
  (vwo (name "Singapore Red Cross") (freq adhoc) (orgtype medical) (area northeast east south) (cause medical))
  (vwo (name "AWWA_Lunch-Assistant-For-Seniors") (freq adhoc) (orgtype ss.women) (area north northeast) (duration halfdayless) (cause elderly))
  (vwo (name "SPCA") (freq annually) (orgtype animal) (area west north) (age youth middle))
  (vwo (name "StLuke_AdHoc") (freq adhoc) (orgtype medical) (area west) (duration flexible) (age any))
  (vwo (name "SouthCentral_CNY-Event") (freq adhoc) (orgtype ss.children) (area south central) (duration wholeday) (age any))
  (vwo (name "ShanYou_Good-Day-Out") (freq adhoc) (orgtype ss.children medical) (area central))
  (vwo (name "StudentCareService") (freq adhoc) (orgtype ss.children) (duration flexible) (area northeast) (cause children youth education family) (age youth middle))
  (vwo (name "StanChart_Singapore-Marathon") (freq annually) (orgtype sports) (area south) (cause health) (duration wholeday))
  (vwo (name "VWO F") (freq adhoc) (orgtype ss.children))
  (vwo (name "VWO G") (freq adhoc) (area northeast)))


(defrule VWOs::generate-VWOs
  (vwo (name ?name)
        (freq $? ?q $?)
        (orgtype $? ?t $?)
        (area $? ?a $?)
		(duration $? ?d $?)
		(cause $? ?c $?)
		(age $? ?g $?))
  (attribute (name best-freq) (value ?q) (certainty ?certainty-1))
  (attribute (name best-orgtype) (value ?t) (certainty ?certainty-2))
  (attribute (name best-area) (value ?a) (certainty ?certainty-3))
  (attribute (name best-duration) (value ?d) (certainty ?certainty-4))
  (attribute (name b-cause) (value ?c) (certainty ?certainty-5))
  (attribute (name b-age) (value ?g) (certainty ?certainty-6))
  =>
  (assert (attribute (name vwo) (value ?name)
                     (certainty (min ?certainty-1 ?certainty-2 ?certainty-3 ?certainty-4 ?certainty-5 ?certainty-6)))))

(deffunction VWOs::vwo-sort (?w1 ?w2)
   (< (fact-slot-value ?w1 certainty)
      (fact-slot-value ?w2 certainty)))

(deffunction VWOs::get-vwo-list ()
  (bind ?facts (find-all-facts ((?f attribute))
                               (and (eq ?f:name vwo)
                                    (>= ?f:certainty 15))))
  (sort vwo-sort ?facts))


; (deftemplate VWOs::event
;   (slot name-org (default ?NONE))
;   (slot start-date (default ?NONE))
;   (slot end-date (default ?NONE))
;   (slot duration (default ?NONE))
;   (slot wkend-wkday-any (default ?NONE))
;   (slot location (default ?NONE))
;   (slot min-age (default ?NONE))
;   (slot opening (default ?NONE))
;   (multislot cause (default ?NONE))
;   (multislot skill (default any))
;   (multislot suitability (default any))
;   )
;
; (deffacts VWOs::Event
;   (event (name-org "Volunteer Photographer for Metta Charity Golf Tournament 2018-Metta Welfare Association") (start-date " 27 Jul 2018") (end-date "Ad Hoc") (duration 10.0)
;          (wkend-wkday-any "Weekday") (location "Seletar") (min-age 22) (opening 2)
;          (cause "Children & Youth" "Disability" "Elderly") (skill " Other Skills" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "CareNights @ Sengkang-Morning Star Community Services Ltd.") (start-date " 3 Jan 2018 ") (end-date " 31 Aug 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Bedok") (min-age 17) (opening 13)
;          (cause "Children & Youth" "Community" "Families") (skill " Coaching & Training" " Other Skills" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Mobile Library in the wards (Every Wednesday, 9.30am-11.30am)-Yishun Community Hospital") (start-date " 15 Nov 2017 ") (end-date " 26 Dec 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Yishun") (min-age 13) (opening 15)
;          (cause "Community" "Education" "Elderly") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Be an All Saints Home Volunteer!-All Saints Home") (start-date " 17 Nov 2018") (end-date "Ad Hoc") (duration 2.5)
;          (wkend-wkday-any "Weekend") (location "Yishun") (min-age 13) (opening 499)
;          (cause "Community" "Elderly" "Health") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" " Family Friendly"))
; (event (name-org "Bringing Joy to our Seniors - Senior Activity Hub @ Punggol-AMKFSC Community Services") (start-date " 2 Jan 2018 ") (end-date " 30 Jun 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Punggol") (min-age 16) (opening 15)
;          (cause "Community" "Elderly" "null") (skill " Arts & Music" " Coaching & Training" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Early Learning Programme (Beyond Social Services, Bukit Merah)-Economic Development Innovations Singapore Pte Ltd") (start-date " 3 Mar 2018 ") (end-date " 24 Nov 2018") (duration 2.0)
;          (wkend-wkday-any "Weekend") (location "Bukit Merah") (min-age 18) (opening 12)
;          (cause "Children & Youth" "Education" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "Seniors Helpdesk Volunteering-SAGE Counselling Centre") (start-date " 1 Mar 2018 ") (end-date " 31 Mar 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Boon Lay") (min-age 18) (opening 10)
;          (cause "Elderly" "null" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" "nan"))
; (event (name-org "Tutoring-New Hope Community Services") (start-date " 1 Feb 2018 ") (end-date " 30 Nov 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Yishun") (min-age 13) (opening 2)
;          (cause "Children & Youth" "Community" "Education") (skill "nan" "nan" "nan") (suitability "nan" "nan" "nan" "nan"))
; (event (name-org "2018 Mandarin News Reading and Sharing Programme-Chinese Development Assistance Council") (start-date " 8 Jan 2018 ") (end-date " 30 Nov 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Choa Chu Kang") (min-age 13) (opening 5)
;          (cause "Elderly" "null" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Y Makan Fellowship-YMCA of Singapore") (start-date " 17 Mar 2018") (end-date "Ad Hoc") (duration 5.0)
;          (wkend-wkday-any "Weekend") (location "Orchard") (min-age 13) (opening 9)
;          (cause "Community" "Elderly" "Social Service") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "Project Hand in Hand-Association for Early Childhood Educators (Singapore)") (start-date " 2 Jan 2018 ") (end-date " 30 Jun 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Islandwide") (min-age 18) (opening 43)
;          (cause "Children & Youth" "Community" "Education") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" " Family Friendly"))
; (event (name-org "Thursday Morning Ukulele @ TNCC-En Community Services Society") (start-date " 22 Mar 2018 ") (end-date " 22 Nov 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Tampines") (min-age 21) (opening 6)
;          (cause "Arts & Heritage" "Community" "Education") (skill " Arts & Music" " Coaching & Training" " Human Resource") (suitability " Open to All" " Organisation or Groups" "nan" "nan"))
; (event (name-org "Elderaid befriender-Singapore Red Cross Society") (start-date " 1 Mar 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Tampines") (min-age 50) (opening 50)
;          (cause "Community" "Elderly" "Humanitarian") (skill " NA" "nan" "nan") (suitability " Seniors" "nan" "nan" "nan"))
; (event (name-org "Food Distribution Services-Heart To Heart Service") (start-date " 8 Feb 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Downtown Core") (min-age 13) (opening 5)
;          (cause "Community" "Elderly" "Families") (skill " Volunteer Management" " No Specific Skills Required" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "Regular Volunteers-Thye Hua Kwan Nursing Home Limited") (start-date " 8 Feb 2018 ") (end-date " 28 Feb 2019") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Hougang") (min-age 13) (opening 49)
;          (cause "Community" "Disability" "Elderly") (skill " Volunteer Management" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Community Befriending Programme-Presbyterian Community Services") (start-date " 2 Jan 2018 ") (end-date " 31 Jul 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Geylang") (min-age 48) (opening 5)
;          (cause "Community" "Elderly" "Social Service") (skill " Arts & Music" " Counselling & Mentoring" " Medical & Health") (suitability " First Timers" " Seniors" " Open to All" " Family Friendly"))
; (event (name-org "Transporter needed for charity event_ad-hoc basis-SingYouth Hub") (start-date " 2 Mar 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Yishun") (min-age 30) (opening 2)
;          (cause "Children & Youth" "Community" "Education") (skill " No Specific Skills Required" "nan" "nan") (suitability " Seniors" "nan" "nan" "nan"))
; (event (name-org "Language Classes-Singapore Anglican Community Services") (start-date " 1 Jan 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Bukit Batok") (min-age 13) (opening 2)
;          (cause "Arts & Heritage" "Community" "Education") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Fundraising @ Tian Jun Temple-The National Kidney Foundation") (start-date " 14 Mar 2018") (end-date "Ad Hoc") (duration 2.5)
;          (wkend-wkday-any "Weekday") (location "Punggol") (min-age 18) (opening 5)
;          (cause "Community" "Disability" "Elderly") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Sembawang d'Klub Mentoring Programme (P3-P6)-Care Community Services Society") (start-date " 25 Jan 2018 ") (end-date " 26 Jan 2019") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Sembawang") (min-age 18) (opening 10)
;          (cause "Children & Youth" "Community" "Education") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "SRC South East District ElderAid Programme-Singapore Red Cross Society") (start-date " 1 Jan 2018 ") (end-date " 31 Jul 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Bedok") (min-age 18) (opening 20)
;          (cause "Community" "Disability" "Elderly") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" "nan"))
; (event (name-org "Befriend a Senior-Lions Befrienders Service Association") (start-date " 1 Jan 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Bukit Merah") (min-age 18) (opening 40)
;          (cause "Community" "Elderly" "Social Service") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" " Family Friendly" "nan" "nan"))
; (event (name-org "Prison Support Services Group Sessions-The Salvation Army") (start-date " 25 Aug 2018") (end-date "Ad Hoc") (duration 4.0)
;          (wkend-wkday-any "Weekend") (location "Tanglin") (min-age 21) (opening 60)
;          (cause "Children & Youth" "null" "null") (skill " Other Skills" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Volunteer Administrator (Seniors)-Calvary Community Care") (start-date " 9 Mar 2018 ") (end-date " 6 Jul 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Serangoon") (min-age 13) (opening 3)
;          (cause "Community" "Elderly" "null") (skill " NA" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" " Family Friendly"))
; (event (name-org "Physical Activities with Me Too! Club (Every Tuesday)-Me Too! Club (MINDS)") (start-date " 06 Mar 2018") (end-date "Ad Hoc") (duration 3.5)
;          (wkend-wkday-any "Weekday") (location "Geylang") (min-age 13) (opening 20)
;          (cause "Community" "Disability" "Families") (skill " NA" "nan" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "Y Outing @ Blue Cross-YMCA of Singapore") (start-date " 03 Mar 2018") (end-date "Ad Hoc") (duration 6.0)
;          (wkend-wkday-any "Weekend") (location "Jurong East") (min-age 17) (opening 10)
;          (cause "Disability" "null" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "Bingo-Ang Mo Kio - Thye Hua Kwan Hospital") (start-date " 05 Mar 2018") (end-date "Ad Hoc") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Ang Mo Kio") (min-age 15) (opening 4)
;          (cause "Elderly" "null" "null") (skill " NA" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" "nan"))
; (event (name-org "Rooftop Gardening (At least 6 months) (8.30am-11am)-Yishun Community Hospital") (start-date " 30 Jan 2018 ") (end-date " 31 Jan 2019") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Yishun") (min-age 17) (opening 20)
;          (cause "Community" "Environment" "Health") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Admin work for SingYouth Hub-SingYouth Hub") (start-date " 24 Feb 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Paya Lebar") (min-age 25) (opening 2)
;          (cause "Children & Youth" "Community" "Education") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Lend a listening ear. Be an SOS hotline volunteer-Samaritans of Singapore") (start-date " 1 Nov 2017 ") (end-date " 31 Dec 2026") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Outram") (min-age 23) (opening 183)
;          (cause "Community" "Social Service" "null") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Cooking Class-Singapore Anglican Community Services") (start-date " 1 Jan 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Bukit Batok") (min-age 13) (opening 1)
;          (cause "Community" "Elderly" "Families") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Bingo with Residents @ Ren Ci Community Hospital-Ren Ci Hospital") (start-date " 11 Mar 2018") (end-date "Ad Hoc") (duration 2.0)
;          (wkend-wkday-any "Weekend") (location "Novena") (min-age 13) (opening 39)
;          (cause "Community" "Elderly" "Health") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Haze Intelligence-People's Movement to Stop Haze") (start-date " 1 Feb 2018 ") (end-date " 30 Jun 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Orchard") (min-age 13) (opening 1)
;          (cause "Children & Youth" "Education" "Environment") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" "nan"))
; (event (name-org "Craftwork & Maintenance @ Kampung Kampus-Ground-Up Initiative (GUI)") (start-date " 01 Mar 2018") (end-date "Ad Hoc") (duration 6.0)
;          (wkend-wkday-any "Weekday") (location "Yishun") (min-age 13) (opening 2)
;          (cause "Community" "Education" "Environment") (skill "nan" "nan" "nan") (suitability "nan" "nan" "nan" "nan"))
; (event (name-org "d'Klub Mentoring Programme (P3-P6)-Care Community Services Society") (start-date " 13 Jan 2018 ") (end-date " 12 Jan 2019") (duration 3.0)
;          (wkend-wkday-any "Weekend") (location "Islandwide") (min-age 18) (opening 18)
;          (cause "Children & Youth" "Community" "Education") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Y Sports @Clementi MINDS-YMCA of Singapore") (start-date " 13 Apr 2018") (end-date "Ad Hoc") (duration 2.5)
;          (wkend-wkday-any "Weekday") (location "Clementi") (min-age 17) (opening 10)
;          (cause "Disability" "Sports" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Y Photo Club @ APSN CFA-YMCA of Singapore") (start-date " 03 Mar 2018") (end-date "Ad Hoc") (duration 3.0)
;          (wkend-wkday-any "Weekend") (location "Paya Lebar") (min-age 17) (opening 5)
;          (cause "Disability" "Social Service" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" "nan"))
; (event (name-org "Tutors for CareHut Programme-Care Community Services Society") (start-date " 16 Jan 2018 ") (end-date " 15 Jan 2019") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Islandwide") (min-age 18) (opening 24)
;          (cause "Children & Youth" "Community" "Social Service") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Tiger Balm Boccia Invitational Singapore 2018-Singapore Disability Sports Council") (start-date " 28 May 2018") (end-date "Ad Hoc") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Kallang") (min-age 18) (opening 12)
;          (cause "Disability" "Sports" "null") (skill " Leadership Development" " Marketing & Communications" " Volunteer Management") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Y Visit @ Bizlink-YMCA of Singapore") (start-date " 16 Mar 2018") (end-date "Ad Hoc") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Bedok") (min-age 17) (opening 15)
;          (cause "Community" "Disability" "Social Service") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "Early Learning Programme (Faith Acts, Commonwealth)-Economic Development Innovations Singapore Pte Ltd") (start-date " 17 Mar 2018 ") (end-date " 17 Nov 2018") (duration 2.0)
;          (wkend-wkday-any "Weekend") (location "Queenstown") (min-age 16) (opening 10)
;          (cause "Children & Youth" "Education" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "Y Outing @ Handicaps Welfare Association-YMCA of Singapore") (start-date " 31 Mar 2018") (end-date "Ad Hoc") (duration 4.5)
;          (wkend-wkday-any "Weekend") (location "Marina South") (min-age 17) (opening 20)
;          (cause "Community" "Disability" "Elderly") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" " Organisation or Groups"))
; (event (name-org "Special Olympics Singapore Unified Floorball Team (Male)-Special Olympics Singapore") (start-date " 1 Apr 2018 ") (end-date " 31 Dec 2018") (duration 2.0)
;          (wkend-wkday-any "Weekend") (location "Marine Parade") (min-age 21) (opening 10)
;          (cause "Children & Youth" "Community" "Disability") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Free Haircut-The New Charis Mission") (start-date " 07 Mar 2018") (end-date "Ad Hoc") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Ang Mo Kio") (min-age 19) (opening 2)
;          (cause "Elderly" "null" "null") (skill " Other Skills" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Be a Youth Mentor (ACE Programme)-Calvary Community Care") (start-date " 1 Mar 2018 ") (end-date " 25 Aug 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Bishan") (min-age 17) (opening 10)
;          (cause "Children & Youth" "Education" "Sports") (skill " Other Skills" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "MWC Help Kiosk-Migrant Workers' Centre") (start-date " 21 Mar 2018") (end-date "Ad Hoc") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Pioneer") (min-age 13) (opening 2)
;          (cause "Social Service" "null" "null") (skill "nan" "nan" "nan") (suitability "nan" "nan" "nan" "nan"))
; (event (name-org "Enriching our children - Achieving Kids and Kins-AMKFSC Community Services") (start-date " 1 Feb 2018 ") (end-date " 31 Dec 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Ang Mo Kio") (min-age 18) (opening 10)
;          (cause "Children & Youth" "null" "null") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Y Outing @ APSN CFA-YMCA of Singapore") (start-date " 24 Mar 2018") (end-date "Ad Hoc") (duration 5.0)
;          (wkend-wkday-any "Weekend") (location "Kallang") (min-age 17) (opening 20)
;          (cause "Community" "Disability" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "Shop@Redcross Programme-Singapore Red Cross Society") (start-date " 1 Jan 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Orchard") (min-age 13) (opening 10)
;          (cause "Community" "Disability" "Elderly") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" " Family Friendly"))
; (event (name-org "Community Befriending Programme-Presbyterian Community Services") (start-date " 2 Jan 2018 ") (end-date " 31 Jul 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Toa Payoh") (min-age 48) (opening 25)
;          (cause "Community" "Elderly" "Social Service") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" " Family Friendly"))
; (event (name-org "Medical Escort - Training Session!-Montfort Care") (start-date " 23 Mar 2018") (end-date "Ad Hoc") (duration 5.0)
;          (wkend-wkday-any "Weekday") (location "Outram") (min-age 18) (opening 25)
;          (cause "Community" "Disability" "Elderly") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Free Tuition Programme-Loving Heart Multi-Service Centre (Jurong)") (start-date " 23 Feb 2018 ") (end-date " 9 Nov 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Jurong East") (min-age 17) (opening 30)
;          (cause "Children & Youth" "Education" "Elderly") (skill " Other Skills" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" "nan"))
; (event (name-org "ISP@Myanmar (Maubin) - Open Team (28 Apr - 6 May 2018)-YMCA of Singapore") (start-date " 28 Apr 2018") (end-date "Ad Hoc") (duration 1.0)
;          (wkend-wkday-any "Weekend") (location "Overseas") (min-age 13) (opening 10)
;          (cause "Children & Youth" "Community" "Education") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Singapore Cancer Society Relay for Life 2018-Singapore Cancer Society") (start-date " 10 Mar 2018") (end-date "Ad Hoc") (duration 7.0)
;          (wkend-wkday-any "Weekend") (location "Kallang") (min-age 16) (opening 202)
;          (cause "Community" "Health" "Social Service") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Y Sports @Clementi MINDS-YMCA of Singapore") (start-date " 09 Mar 2018") (end-date "Ad Hoc") (duration 2.5)
;          (wkend-wkday-any "Weekday") (location "Clementi") (min-age 17) (opening 10)
;          (cause "Disability" "Sports" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Baking Class-Singapore Anglican Community Services") (start-date " 1 Jan 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Bukit Batok") (min-age 13) (opening 1)
;          (cause "Community" "Elderly" "Families") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Community Befriending Programme-Presbyterian Community Services") (start-date " 2 Jan 2018 ") (end-date " 31 Jul 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Tampines") (min-age 48) (opening 10)
;          (cause "Community" "Elderly" "Social Service") (skill " Arts & Music" " Counselling & Mentoring" " Other Skills") (suitability " First Timers" " Seniors" " Family Friendly" "nan"))
; (event (name-org "Be an All Saints Home Volunteer!-All Saints Home") (start-date " 17 Nov 2018") (end-date "Ad Hoc") (duration 2.5)
;          (wkend-wkday-any "Weekend") (location "Tampines") (min-age 13) (opening 498)
;          (cause "Community" "Elderly" "Health") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" " Family Friendly"))
; (event (name-org "Delivery & Distribution of vegetarian meals to Elderly Home-ASSOCIATION FOR PERSONS WITH SPECIAL NEEDS") (start-date " 1 Jan 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Bedok") (min-age 13) (opening 2)
;          (cause "Community" "Elderly" "Social Service") (skill " Other Skills" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Community Befriending Programme-Presbyterian Community Services") (start-date " 2 Jan 2018 ") (end-date " 31 Jul 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Bukit Timah") (min-age 48) (opening 5)
;          (cause "Community" "Elderly" "Social Service") (skill " NA" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" " Family Friendly"))
; (event (name-org "Child Minding-Montfort Care") (start-date " 26 Feb 2018 ") (end-date " 30 Apr 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Bukit Merah") (min-age 18) (opening 10)
;          (cause "Children & Youth" "Community" "Families") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Befriend a senior living near you-Community Networks for Seniors") (start-date " 1 Apr 2018 ") (end-date " 31 Mar 2019") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Islandwide") (min-age 13) (opening 100)
;          (cause "Community" "Elderly" "Health") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Project CARE (Caring with Authenticity & Respect for Elders)-Project CARE") (start-date " 10 Mar 2018") (end-date "Ad Hoc") (duration 4.0)
;          (wkend-wkday-any "Weekend") (location "Bedok") (min-age 18) (opening 15)
;          (cause "Community" "Elderly" "Social Service") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Mini Patient Outing-Bright Vision Hospital") (start-date " 06 Mar 2018") (end-date "Ad Hoc") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Hougang") (min-age 18) (opening 6)
;          (cause "Elderly" "Health" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Friday Morning Craftwork Volunteers-En Community Services Society") (start-date " 16 Mar 2018 ") (end-date " 25 May 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Tampines") (min-age 13) (opening 5)
;          (cause "Arts & Heritage" "Community" "Education") (skill " Arts & Music" " Coaching & Training" " Counselling & Mentoring") (suitability " Seniors" " Open to All" " Organisation or Groups" "nan"))
; (event (name-org "VWO Fair @ Fuhua Secondary School-SINGAPORE HEART FOUNDATION") (start-date " 02 Mar 2018") (end-date "Ad Hoc") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Jurong West") (min-age 17) (opening 2)
;          (cause "Children & Youth" "Community" "Elderly") (skill " Other Skills" " No Specific Skills Required" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "Exercise Work-out Classes-Singapore Anglican Community Services") (start-date " 1 Jan 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Bukit Batok") (min-age 13) (opening 5)
;          (cause "Community" "Families" "Health") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "2018 Mandarin News Reading and Sharing Programme-Chinese Development Assistance Council") (start-date " 8 Jan 2018 ") (end-date " 30 Nov 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Ang Mo Kio") (min-age 13) (opening 5)
;          (cause "Elderly" "null" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "SUPPORT DAILY OPERATIONS - Focus on the Family-Focus on the Family Singapore Limited") (start-date " 9 Jan 2018 ") (end-date " 1 Jan 2020") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Bishan") (min-age 13) (opening 2)
;          (cause "Children & Youth" "Community" "Education") (skill "nan" "nan" "nan") (suitability "nan" "nan" "nan" "nan"))
; (event (name-org "Home Befriending with Me Too! Club (6 Months)-Me Too! Club (MINDS)") (start-date " 01 Mar 2018") (end-date "Ad Hoc") (duration 6.0)
;          (wkend-wkday-any "Weekday") (location "Islandwide") (min-age 13) (opening 15)
;          (cause "Community" "Disability" "Families") (skill " NA" "nan" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "Queenstown d'Klub Mentoring Programme (P3-P6)-Care Community Services Society") (start-date " 25 Jan 2018 ") (end-date " 26 Jan 2019") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Queenstown") (min-age 18) (opening 7)
;          (cause "Children & Youth" "Community" "Education") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Boys' Town Flag Day 2018-Boys' Town") (start-date " 14 Mar 2018") (end-date "Ad Hoc") (duration 4.0)
;          (wkend-wkday-any "Weekday") (location "Bukit Timah") (min-age 15) (opening 94)
;          (cause "Children & Youth" "Community" "Families") (skill " Other Skills" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "YWCA - Empowering Mum Programme-Young Women's Christian Association of Singapore") (start-date " 09 Mar 2018") (end-date "Ad Hoc") (duration 4.0)
;          (wkend-wkday-any "Weekday") (location "Outram") (min-age 16) (opening 15)
;          (cause "Community" "Families" "Women & Girls") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Tutoring-Infant Jesus Homes & Children's Centres") (start-date " 1 Mar 2018 ") (end-date " 30 Nov 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Ang Mo Kio") (min-age 13) (opening 3)
;          (cause "Children & Youth" "null" "null") (skill " Other Skills" "nan" "nan") (suitability " First Timers" "nan" "nan" "nan"))
; (event (name-org "Expedition Agape-Lakeside Family Services") (start-date " 17 Mar 2018 ") (end-date " 16 Feb 2019") (duration 2.0)
;          (wkend-wkday-any "Weekend") (location "Jurong West") (min-age 21) (opening 20)
;          (cause "Children & Youth" "Community" "Education") (skill " Counselling & Mentoring" " Other Skills" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "SPD Flag Day 2018-SPD (formerly Society for the Physically Disabled)") (start-date " 07 Apr 2018") (end-date "Ad Hoc") (duration 8.0)
;          (wkend-wkday-any "Weekend") (location "Outram") (min-age 15) (opening 100)
;          (cause "Disability" "null" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" " Family Friendly"))
; (event (name-org "Blossom World Flag Day-Blossom World Society") (start-date " 21 Apr 2018") (end-date "Ad Hoc") (duration 5.0)
;          (wkend-wkday-any "Weekend") (location "Islandwide") (min-age 15) (opening 1995)
;          (cause "Children & Youth" "Community" "Education") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" " Family Friendly"))
; (event (name-org "Music Appreciation-Singapore Anglican Community Services") (start-date " 1 Jan 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Bukit Batok") (min-age 13) (opening 1)
;          (cause "Community" "Families" "Health") (skill " Arts & Music" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Fundraising @ Thiam Hock Keng-The National Kidney Foundation") (start-date " 17 Mar 2018") (end-date "Ad Hoc") (duration 2.5)
;          (wkend-wkday-any "Weekend") (location "Bishan") (min-age 18) (opening 5)
;          (cause "Community" "Disability" "Elderly") (skill " Fundraising" " No Specific Skills Required" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "Lend a Helping Hand-HCA HOSPICE CARE") (start-date " 12 Jan 2018 ") (end-date " 30 Jun 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Islandwide") (min-age 13) (opening 30)
;          (cause "Elderly" "Health" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "Baking for low income families - Bakery Hearts-AMKFSC Community Services") (start-date " 2 Jan 2018 ") (end-date " 31 Dec 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Ang Mo Kio") (min-age 16) (opening 5)
;          (cause "Families" "null" "null") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Enriching our children - BASIC Student Care Services (Ang Mo Kio)-AMKFSC Community Services") (start-date " 2 Jan 2018 ") (end-date " 31 Dec 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Ang Mo Kio") (min-age 16) (opening 5)
;          (cause "Children & Youth" "null" "null") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Singapore Cancer Society Relay for Life 2018-Singapore Cancer Society") (start-date " 10 Mar 2018") (end-date "Ad Hoc") (duration 7.0)
;          (wkend-wkday-any "Weekend") (location "Kallang") (min-age 16) (opening 115)
;          (cause "Community" "Health" "Social Service") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Volunteers needed! (OTAGO Exercise for seniors)-Calvary Community Care") (start-date " 24 Feb 2018 ") (end-date " 28 Jul 2018") (duration 2.0)
;          (wkend-wkday-any "Weekend") (location "Bishan") (min-age 13) (opening 20)
;          (cause "Community" "Elderly" "Health") (skill " Other Skills" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" "nan"))
; (event (name-org "Pioneer Generation Ambassadors (PGA) Recruitment Talk @ RSVP Singapore-Pioneer Generation Office") (start-date " 1 Apr 2018 ") (end-date " 31 Mar 2019") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Bishan") (min-age 17) (opening 20)
;          (cause "Community" "Education" "Elderly") (skill " Other Skills" " No Specific Skills Required" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Enabling Futures : Lifeskills for the Digital Economy (AWWA)-LearnIn Pte Ltd") (start-date " 10 Mar 2018") (end-date "Ad Hoc") (duration 7.5)
;          (wkend-wkday-any "Weekend") (location "Ang Mo Kio") (min-age 16) (opening 4)
;          (cause "Children & Youth" "Community" "Disability") (skill " Counselling & Mentoring" " No Specific Skills Required" "nan") (suitability " First Timers" " Organisation or Groups" "nan" "nan"))
; (event (name-org "Porters required (at least 6 months)-Yishun Community Hospital") (start-date " 1 Jan 2018 ") (end-date " 31 Dec 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Yishun") (min-age 25) (opening 5)
;          (cause "Community" "Elderly" "Health") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Y Spring Clean @ Teck Ghee-YMCA of Singapore") (start-date " 24 Mar 2018") (end-date "Ad Hoc") (duration 3.5)
;          (wkend-wkday-any "Weekend") (location "Ang Mo Kio") (min-age 17) (opening 9)
;          (cause "Community" "Elderly" "Social Service") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "Tutoring Opportunities for Working Adults-South Central Community Family Service Centre Limited") (start-date " 17 Nov 2017 ") (end-date " 17 Nov 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "River Valley") (min-age 20) (opening 7)
;          (cause "Children & Youth" "Families" "Social Service") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Patient Escort-The National Kidney Foundation") (start-date " 11 Jan 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Islandwide") (min-age 21) (opening 10)
;          (cause "Disability" "Elderly" "Health") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Help us raise funds for PC at the Istana Open House-President's Challenge") (start-date " 01 May 2018") (end-date "Ad Hoc") (duration 5.5)
;          (wkend-wkday-any "Weekday") (location "Islandwide") (min-age 15) (opening 15)
;          (cause "Children & Youth" "Disability" "Elderly") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Volunteer Tutor-Montfort Care") (start-date " 1 Mar 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Outram") (min-age 20) (opening 1)
;          (cause "Children & Youth" "Families" "null") (skill " Other Skills" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Reading Club-Singapore Anglican Community Services") (start-date " 1 Jan 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Bukit Batok") (min-age 13) (opening 1)
;          (cause "Community" "Families" "Health") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Enabling Futures : Lifeskills for the Digital Economy (AWWA)-LearnIn Pte Ltd") (start-date " 10 Mar 2018") (end-date "Ad Hoc") (duration 7.5)
;          (wkend-wkday-any "Weekend") (location "Ang Mo Kio") (min-age 16) (opening 4)
;          (cause "Children & Youth" "Community" "Disability") (skill " Counselling & Mentoring" " No Specific Skills Required" "nan") (suitability " First Timers" " Organisation or Groups" "nan" "nan"))
; (event (name-org "Y Visit @ COH-YMCA of Singapore") (start-date " 23 Mar 2018") (end-date "Ad Hoc") (duration 2.5)
;          (wkend-wkday-any "Weekday") (location "Toa Payoh") (min-age 13) (opening 9)
;          (cause "Community" "Disability" "Social Service") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "Volunteering Opportunities-St Luke's Hospital") (start-date " 16 Jan 2018 ") (end-date " 21 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Bukit Batok") (min-age 18) (opening 1)
;          (cause "Community" "Disability" "Elderly") (skill " Volunteer Management" " Other Skills" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "BCARE Academic Assistance Programme for Low-Income Families-Bethesda Community Assistance and Relationship Enrichment Centre") (start-date " 6 Feb 2018 ") (end-date " 30 Oct 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Sengkang") (min-age 21) (opening 2)
;          (cause "Children & Youth" "Community" "Education") (skill " Coaching & Training" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Elderaid befriender-Singapore Red Cross Society") (start-date " 1 Mar 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Yishun") (min-age 50) (opening 50)
;          (cause "Community" "Elderly" "Humanitarian") (skill " NA" "nan" "nan") (suitability " Seniors" "nan" "nan" "nan"))
; (event (name-org "Be an All Saints Home Volunteer!-All Saints Home") (start-date " 17 Nov 2018") (end-date "Ad Hoc") (duration 2.5)
;          (wkend-wkday-any "Weekend") (location "Jurong East") (min-age 13) (opening 489)
;          (cause "Community" "Elderly" "Health") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" " Family Friendly"))
; (event (name-org "Save-A-Life-SINGAPORE HEART FOUNDATION") (start-date " 15 Mar 2018") (end-date "Ad Hoc") (duration 6.0)
;          (wkend-wkday-any "Weekday") (location "Jurong East") (min-age 16) (opening 9)
;          (cause "Community" "Education" "Health") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Mahjong Session-Bright Vision Hospital") (start-date " 08 Mar 2018") (end-date "Ad Hoc") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Hougang") (min-age 18) (opening 4)
;          (cause "Community" "Elderly" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" "nan" "nan"))
; (event (name-org "Engage children and youths at SCS!-Students Care Service") (start-date " 2 Jan 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Hougang") (min-age 13) (opening 2)
;          (cause "Children & Youth" "Education" "Families") (skill "nan" "nan" "nan") (suitability "nan" "nan" "nan" "nan"))
; (event (name-org "Monument Walking Tours-National Heritage Board") (start-date " 1 Mar 2018 ") (end-date " 31 Mar 2019") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Downtown Core") (min-age 18) (opening 2)
;          (cause "Arts & Heritage" "Community" "Education") (skill " Volunteer Management" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "MWC Help Kiosk-Migrant Workers' Centre") (start-date " 28 Mar 2018") (end-date "Ad Hoc") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Woodlands") (min-age 13) (opening 2)
;          (cause "Social Service" "null" "null") (skill "nan" "nan" "nan") (suitability "nan" "nan" "nan" "nan"))
; (event (name-org "Enriching our children - BASIC Student Care Services (Cheng San)-AMKFSC Community Services") (start-date " 2 Jan 2018 ") (end-date " 31 Dec 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Ang Mo Kio") (min-age 16) (opening 5)
;          (cause "Children & Youth" "null" "null") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Tuition-Yong-en Care Centre") (start-date " 27 Jan 2018 ") (end-date " 30 Nov 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Outram") (min-age 17) (opening 9)
;          (cause "Children & Youth" "null" "null") (skill " Other Skills" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "MWC Help Kiosk-Migrant Workers' Centre") (start-date " 07 Mar 2018") (end-date "Ad Hoc") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Pioneer") (min-age 13) (opening 2)
;          (cause "Social Service" "null" "null") (skill "nan" "nan" "nan") (suitability "nan" "nan" "nan" "nan"))
; (event (name-org "Patient Sitter Volunteer-Yishun Community Hospital") (start-date " 27 Nov 2017 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Yishun") (min-age 25) (opening 18)
;          (cause "Community" "Elderly" "Health") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Training and mentoring program-WISE - WASH in Southeast Asia Limited") (start-date " 1 Feb 2018 ") (end-date " 31 Jan 2019") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Ang Mo Kio") (min-age 18) (opening 1)
;          (cause "Community" "Environment" "Health") (skill " Coaching & Training" " Volunteer Management" " Other Skills") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Brisk Walking With Seniors-Calvary Community Care") (start-date " 04 Jul 2018") (end-date "Ad Hoc") (duration 3.5)
;          (wkend-wkday-any "Weekday") (location "Serangoon") (min-age 13) (opening 3)
;          (cause "Community" "Elderly" "null") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "House building project in Cambodia-Operation Hope Foundation") (start-date " 29 Mar 2018") (end-date "Ad Hoc") (duration 1.0)
;          (wkend-wkday-any "Weekday") (location "Tanglin") (min-age 13) (opening 16)
;          (cause "Children & Youth" "Community" "Humanitarian") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "National Pencak silat Championship-SINGAPORE SILAT FEDERATION") (start-date " 30 Mar 2018 ") (end-date " 1 Apr 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Bedok") (min-age 17) (opening 4)
;          (cause "Children & Youth" "Community" "Education") (skill " Leadership Development" " Volunteer Management" " Other Skills") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Dementia Outing Project-Empower Ageing Limited") (start-date " 5 Mar 2018 ") (end-date " 30 Jun 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Geylang") (min-age 18) (opening 8)
;          (cause "Community" "Elderly" "Health") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" " Family Friendly"))
; (event (name-org "Community Befriending Programme-Presbyterian Community Services") (start-date " 2 Jan 2018 ") (end-date " 31 Jul 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Serangoon") (min-age 48) (opening 25)
;          (cause "Community" "Elderly" "Social Service") (skill " Arts & Music" " Counselling & Mentoring" " Medical & Health") (suitability " First Timers" " Seniors" " Family Friendly" "nan"))
; (event (name-org "Y Makan Fellowship 2018-YMCA of Singapore") (start-date " 24 Mar 2018") (end-date "Ad Hoc") (duration 5.0)
;          (wkend-wkday-any "Weekend") (location "Orchard") (min-age 13) (opening 10)
;          (cause "Community" "Disability" "Elderly") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "2018 Mandarin News Reading and Sharing Programme-Chinese Development Assistance Council") (start-date " 8 Jan 2018 ") (end-date " 30 Nov 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Choa Chu Kang") (min-age 13) (opening 5)
;          (cause "Elderly" "null" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Enabling Futures : Lifeskills for the Digital Economy (MINDS)-LearnIn Pte Ltd") (start-date " 03 Mar 2018") (end-date "Ad Hoc") (duration 2.5)
;          (wkend-wkday-any "Weekend") (location "Paya Lebar") (min-age 16) (opening 3)
;          (cause "Children & Youth" "Community" "Disability") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Organisation or Groups" "nan" "nan"))
; (event (name-org "Social Worker Network-Singapore Red Cross Society") (start-date " 1 Jan 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Orchard") (min-age 13) (opening 20)
;          (cause "Community" "Disability" "Humanitarian") (skill " Other Skills" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Simple Science Workshop-Singapore Anglican Community Services") (start-date " 1 Jan 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Bukit Batok") (min-age 13) (opening 1)
;          (cause "Community" "Elderly" "Families") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Entertainment Session - Hobbies/Games-Singapore Anglican Community Services") (start-date " 1 Jan 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Bukit Batok") (min-age 13) (opening 2)
;          (cause "Community" "Elderly" "Families") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Enriching our children - BASIC Student Care Services (Sengkang)-AMKFSC Community Services") (start-date " 2 Jan 2018 ") (end-date " 31 Dec 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Sengkang") (min-age 16) (opening 5)
;          (cause "Children & Youth" "null" "null") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Weekly English Tutoring for Primary School Students-South Central Community Family Service Centre Limited") (start-date " 1 Feb 2018 ") (end-date " 31 Aug 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "River Valley") (min-age 18) (opening 5)
;          (cause "Children & Youth" "Education" "Families") (skill " NA" "nan" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "Ward Birthday Celebration-Bright Vision Hospital") (start-date " 06 Mar 2018") (end-date "Ad Hoc") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Hougang") (min-age 16) (opening 8)
;          (cause "Community" "Elderly" "Health") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" "nan"))
; (event (name-org "Singapore Cancer Society - Call Management Centre-Singapore Cancer Society") (start-date " 1 Feb 2018 ") (end-date " 30 Apr 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Bishan") (min-age 25) (opening 5)
;          (cause "Community" "Health" "Social Service") (skill " Other Skills" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Volunteering with YWCA Workz on Wheels (WoW) programme-Young Women's Christian Association of Singapore") (start-date " 07 Mar 2018") (end-date "Ad Hoc") (duration 3.5)
;          (wkend-wkday-any "Weekday") (location "Hougang") (min-age 16) (opening 10)
;          (cause "Children & Youth" "Community" "null") (skill " Other Skills" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Volunteers for shared-bike patrols-Volunteer Bike Patrol") (start-date " 25 Dec 2017 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Islandwide") (min-age 15) (opening 100)
;          (cause "Community" "Environment" "null") (skill " NA" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Befriending/Cleaning-The New Charis Mission") (start-date " 07 Mar 2018") (end-date "Ad Hoc") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Ang Mo Kio") (min-age 15) (opening 10)
;          (cause "Elderly" "null" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Free Haircut-The New Charis Mission") (start-date " 07 Mar 2018") (end-date "Ad Hoc") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Ang Mo Kio") (min-age 19) (opening 2)
;          (cause "Elderly" "null" "null") (skill " Other Skills" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Lunch Assistant for Seniors-AWWA Ltd") (start-date " 11 Jan 2018 ") (end-date " 31 Mar 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Ang Mo Kio") (min-age 18) (opening 2)
;          (cause "Elderly" "Health" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" "nan"))
; (event (name-org "Y Outing @ Sarah Seniors Activity Centre-YMCA of Singapore") (start-date " 27 Mar 2018") (end-date "Ad Hoc") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Marina South") (min-age 15) (opening 5)
;          (cause "Community" "Disability" "Elderly") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Open to All" "nan" "nan"))
; (event (name-org "MWC Help Kiosk-Migrant Workers' Centre") (start-date " 14 Mar 2018") (end-date "Ad Hoc") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Paya Lebar") (min-age 13) (opening 2)
;          (cause "Social Service" "null" "null") (skill "nan" "nan" "nan") (suitability "nan" "nan" "nan" "nan"))
; (event (name-org "Craft Workshop-Singapore Anglican Community Services") (start-date " 1 Jan 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Weekday") (location "Bukit Batok") (min-age 13) (opening 2)
;          (cause "Arts & Heritage" "Community" "Social Service") (skill " Arts & Music" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "2018 Mandarin News Reading and Sharing Programme-Chinese Development Assistance Council") (start-date " 8 Jan 2018 ") (end-date " 30 Nov 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Punggol") (min-age 13) (opening 1)
;          (cause "Elderly" "null" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "BVH Flag Day 2018-Bright Vision Hospital") (start-date " 10 Mar 2018") (end-date "Ad Hoc") (duration 6.0)
;          (wkend-wkday-any "Weekend") (location "Islandwide") (min-age 14) (opening 680)
;          (cause "Elderly" "Health" "null") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Open to All" " Organisation or Groups" "nan"))
; (event (name-org "Legal works for SingYouth Hub-SingYouth Hub") (start-date " 26 Feb 2018 ") (end-date " 31 Dec 2018") (duration 3.0)
;          (wkend-wkday-any "Anyday") (location "Paya Lebar") (min-age 35) (opening 2)
;          (cause "Children & Youth" "Community" "Education") (skill " Legal" " Other Skills" "nan") (suitability " Seniors" "nan" "nan" "nan"))
; (event (name-org "World Blood Donor Day-Singapore Red Cross Society") (start-date " 23 Jun 2018") (end-date "Ad Hoc") (duration 6.5)
;          (wkend-wkday-any "Weekend") (location "Downtown Core") (min-age 18) (opening 10)
;          (cause "Community" "Health" "Humanitarian") (skill " No Specific Skills Required" "nan" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Seeking Kitchen Assistant for culinary programme-Boys' Town") (start-date " 11 Mar 2018 ") (end-date " 31 Aug 2018") (duration 3.0)
;          (wkend-wkday-any "Weekend") (location "Tampines") (min-age 25) (opening 2)
;          (cause "Children & Youth" "Community" "Families") (skill " Other Skills" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" "nan"))
; (event (name-org "Art & Craft : Fingerknitting-The Creight Company") (start-date " 23 Mar 2018") (end-date "Ad Hoc") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Bukit Merah") (min-age 13) (opening 5)
;          (cause "Community" "Elderly" "Health") (skill " Arts & Music" " No Specific Skills Required" "nan") (suitability " First Timers" " Seniors" " Open to All" "nan"))
; (event (name-org "Be an All Saints Home Volunteer!-All Saints Home") (start-date " 17 Nov 2018") (end-date "Ad Hoc") (duration 2.5)
;          (wkend-wkday-any "Weekend") (location "Serangoon") (min-age 13) (opening 497)
;          (cause "Community" "Elderly" "Health") (skill " No Specific Skills Required" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" " Family Friendly"))
; (event (name-org "CareNights @ Bedok North-Morning Star Community Services Ltd.") (start-date " 8 Jan 2018 ") (end-date " 31 Aug 2018") (duration 2.0)
;          (wkend-wkday-any "Weekday") (location "Bedok") (min-age 17) (opening 9)
;          (cause "Children & Youth" "Community" "Families") (skill " Coaching & Training" " Other Skills" "nan") (suitability " Open to All" "nan" "nan" "nan"))
; (event (name-org "Guest Chef needed-Boys' Town") (start-date " 01 May 2018") (end-date "Ad Hoc") (duration 5.0)
;          (wkend-wkday-any "Weekday") (location "Tampines") (min-age 25) (opening 2)
;          (cause "Children & Youth" "Community" "Families") (skill " Other Skills" "nan" "nan") (suitability " First Timers" " Seniors" " Open to All" "nan"))
;
;     )
