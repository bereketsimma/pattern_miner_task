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




(= (share-var () _) False)
(= (share-var _ ()) False)
(= (share-var (inheritance $x $y) (inheritance $x $a)) True)
(= (share-var (inheritance $x $y) (inheritance $y $a)) True)
(= (share-var (inheritance $x $y) (inheritance $a $x)) True)
(= (share-var (inheritance $x $y) (inheritance $a $y)) True)
(= (share-var (inheritance $x $y) (inheritance $a $b)) False)

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

(= (disjoint-conjunction $patterns)
   (if (connected $patterns)
       False
       True
   ))

   ! (disjoint-conjunction
    (,
      (inheritance $y $x)
      (inheritance $x $z)
      (inheritance $z $w)
      (inheritance $w living-thing)
    )
)
