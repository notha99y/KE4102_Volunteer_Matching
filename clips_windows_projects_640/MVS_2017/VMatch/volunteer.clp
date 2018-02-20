
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
  

