; (= (disjoint-conjunction 
;  (inheritance $y $x)
;   (inheritance $x $z)
;   (inheritance $z $w)
;   (inheritance $w living-thing)
; )
;   false
; )
;  !(disjoint-conjunction 
;  (inheritance human $x)
;   (inheritance $x mammal)
;   (inheritance mammal animal)
;   (inheritance animal living-thing))




; ------------------------------------------------------------
; share-var
; ------------------------------------------------------------
; This function checks whether two inheritance patterns share
; at least one common variable.
;
; Each pattern has the form:
;     (inheritance subject object)
;
; The function returns:
;     True  → if the two patterns share a variable
;     False → if they do not share any variable


(= (share-var () _) False)
(= (share-var _ ()) False)
(= (share-var (inheritance $x $y) (inheritance $x $a)) True)
(= (share-var (inheritance $x $y) (inheritance $y $a)) True)
(= (share-var (inheritance $x $y) (inheritance $a $x)) True)
(= (share-var (inheritance $x $y) (inheritance $a $y)) True)
(= (share-var (inheritance $x $y) (inheritance $a $b)) False)

; ------------------------------------------------------------
; connected
; ------------------------------------------------------------
; This function checks whether a group of inheritance patterns
; is connected through shared variables.
;
; The patterns are given as a list:
;     (, pattern1 pattern2 ... patternN)
;
; It determines whether the patterns are linked either directly
; or indirectly. Two patterns are considered directly linked
; if they share a variable. Patterns can also be connected
; indirectly through other patterns in the list.
;
; How it works:
; 1. If the list has only one pattern, it cannot be connected
;    to anything else, so it returns False.
;
; 2. If the list has multiple patterns, it checks:
;    - Whether the first two patterns share a variable (direct connection)
;    - OR whether the first pattern is connected to the rest of the list
;    - OR whether the second pattern is connected to the rest of the list
;
; If any of these checks succeed, the patterns are considered
; connected and the function returns True. Otherwise it returns False.



(= (connected (, $p1)) False)
(= (connected (, $p1 $p2 . $rest))
   (if (or
         (share-var $p1 $p2)
         (connected (, $p1 . $rest))
         (connected (, $p2 . $rest))
       )
       True
       False
   ))


; ------------------------------------------------------------
; disjoint-conjunction
; ------------------------------------------------------------
; This function determines whether a set of patterns is
; disjoint (independent).
;
; A conjunction is disjoint when none of the patterns are
; connected through shared variables.
;
; Logic:
;     If patterns are connected → return False
;     If patterns are not connected → return True

(= (disjoint-conjunction $patterns)
   (if (connected $patterns)
       False
       True
   ))

   !(disjoint-conjunction
    (,
      (inheritance $y $x)
      (inheritance $x $z)
      (inheritance $z $w)
      (inheritance $w living-thing)
    )
)
