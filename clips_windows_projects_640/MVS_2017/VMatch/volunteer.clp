
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
  (focus CHOOSE-QUALITIES WINES))

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
;;* CHOOSE WINE QUALITIES RULES *
;;*******************************

(defmodule CHOOSE-QUALITIES (import RULES ?ALL)
                            (import MAIN ?ALL))

(defrule CHOOSE-QUALITIES::startit => (focus RULES))

(deffacts the-wine-rules

  ; Rules for picking the best body

  (rule (if has-sauce is yes and 
            sauce is spicy)
        (then best-body is full))

  (rule (if tastiness is delicate)
        (then best-body is light))

  (rule (if tastiness is average)
        (then best-body is light with certainty 30 and
              best-body is medium with certainty 60 and
              best-body is full with certainty 30))

  (rule (if tastiness is strong)
        (then best-body is medium with certainty 40 and
              best-body is full with certainty 80))

  (rule (if has-sauce is yes and
            sauce is cream)
        (then best-body is medium with certainty 40 and
              best-body is full with certainty 60))

  (rule (if preferred-body is full)
        (then best-body is full with certainty 40))

  (rule (if preferred-body is medium)
        (then best-body is medium with certainty 40))

  (rule (if preferred-body is light) 
        (then best-body is light with certainty 40))

  (rule (if preferred-body is light and
            best-body is full)
        (then best-body is medium))

  (rule (if preferred-body is full and
            best-body is light)
        (then best-body is medium))

  (rule (if preferred-body is unknown) 
        (then best-body is light with certainty 20 and
              best-body is medium with certainty 20 and
              best-body is full with certainty 20))

  ; Rules for picking the best color

  (rule (if main-component is meat)
        (then best-color is red with certainty 90))

  (rule (if main-component is poultry and
            has-turkey is no)
        (then best-color is white with certainty 90 and
              best-color is red with certainty 30))

  (rule (if main-component is poultry and
            has-turkey is yes)
        (then best-color is red with certainty 80 and
              best-color is white with certainty 50))

  (rule (if main-component is fish)
        (then best-color is white))

  (rule (if main-component is-not fish and
            has-sauce is yes and
            sauce is tomato)
        (then best-color is red))

  (rule (if has-sauce is yes and
            sauce is cream)
        (then best-color is white with certainty 40))
                   
  (rule (if preferred-color is red)
        (then best-color is red with certainty 40))

  (rule (if preferred-color is white)
        (then best-color is white with certainty 40))

  (rule (if preferred-color is unknown)
        (then best-color is red with certainty 20 and
              best-color is white with certainty 20))
  
  ; Rules for picking the best sweetness

  (rule (if has-sauce is yes and
            sauce is sweet)
        (then best-sweetness is sweet with certainty 90 and
              best-sweetness is medium with certainty 40))

  (rule (if preferred-sweetness is dry)
        (then best-sweetness is dry with certainty 40))

  (rule (if preferred-sweetness is medium)
        (then best-sweetness is medium with certainty 40))

  (rule (if preferred-sweetness is sweet)
        (then best-sweetness is sweet with certainty 40))

  (rule (if best-sweetness is sweet and
            preferred-sweetness is dry)
        (then best-sweetness is medium))

  (rule (if best-sweetness is dry and
            preferred-sweetness is sweet) 
        (then best-sweetness is medium))

  (rule (if preferred-sweetness is unknown)
        (then best-sweetness is dry with certainty 20 and
              best-sweetness is medium with certainty 20 and
              best-sweetness is sweet with certainty 20))

)

;;************************
;;* VWO SELECTION RULES *
;;************************

(defmodule WINES (import MAIN ?ALL)
                 (export deffunction get-wine-list))

(deffacts any-attributes
  (attribute (name best-color) (value any))
  (attribute (name best-body) (value any))
  (attribute (name best-sweetness) (value any)))

(deftemplate WINES::wine
  (slot name (default ?NONE))
  (multislot color (default any))
  (multislot body (default any))
  (multislot sweetness (default any)))

(deffacts WINES::the-wine-list 
  (wine (name "Singapore Red Cross") (color red) (body medium) (sweetness medium sweet))
  (wine (name "AWWA") (color white) (body light) (sweetness dry))
  (wine (name "SPCA") (color white) (body medium) (sweetness dry))
  (wine (name "VWO A") (color white) (body medium full) (sweetness medium dry))
  (wine (name "VWO B") (color white) (body light) (sweetness medium dry))
  (wine (name "VWO C") (color white) (body light medium) (sweetness medium sweet))
  (wine (name "VWO D") (color white) (body full))
  (wine (name "VWO E") (color white) (body light) (sweetness medium sweet))
  (wine (name "VWO F") (color red) (body light))
  (wine (name "VWO G") (color red) (sweetness dry medium))
  (wine (name "VWO H") (color red) (sweetness dry medium))
  (wine (name "VWO I") (color red) (body medium) (sweetness medium))
  (wine (name "VWO K") (color red) (body full))
  (wine (name "VWO L") (color red) (sweetness dry medium)))
  
  
(defrule WINES::generate-wines
  (wine (name ?name)
        (color $? ?c $?)
        (body $? ?b $?)
        (sweetness $? ?s $?))
  (attribute (name best-color) (value ?c) (certainty ?certainty-1))
  (attribute (name best-body) (value ?b) (certainty ?certainty-2))
  (attribute (name best-sweetness) (value ?s) (certainty ?certainty-3))
  =>
  (assert (attribute (name wine) (value ?name)
                     (certainty (min ?certainty-1 ?certainty-2 ?certainty-3)))))

(deffunction WINES::wine-sort (?w1 ?w2)
   (< (fact-slot-value ?w1 certainty)
      (fact-slot-value ?w2 certainty)))
      
(deffunction WINES::get-wine-list ()
  (bind ?facts (find-all-facts ((?f attribute))
                               (and (eq ?f:name wine)
                                    (>= ?f:certainty 20))))
  (sort wine-sort ?facts))
  

