;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definition of a List data structure with various methods for it. ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(:List (-> $a Type))
(:Nil (List $a))
(: Cons (-> $a (List $a)(List $a)))
!(get-type (List $Number)) ;;
(Cons 1 (Cons 2 (Cons 3 Nil)))
(Cons $a $list)



!(List.sum (Cons 1 (Cons 2 (Cons 3 Nil)))) ;; Returns 6


;; Fold a tuple from left to right
(:List.fold1(->(-> $a $b $b) $b (List $a) $b)); fanally retirn $bty
(=(List.fold1 $f $i Nil ) $i)
(= (List.fold1 $f $i (Cons $h $t)) (chain ($f $h $i) $i' (List.fold1 $f $i'$t)))

;; Fold a tuple from right to left
(: List.foldr (-> (-> $a $b $b) $b (List $a) $b))
(= (List.foldr $f $i Nil) $i)
(= (List.foldr $f $i (Cons $h $t)) ($f $h (List.foldr $f $i $t)))


;; generalized foldl and foldr
;; considering potential transfomration of input values before applying a function over them
(= (id $x) $x)
(= (exp $x) ($x))
;;??? is the name List.tFoldl/tFoldr is better than List.t-foldl	
(= (List.tFoldl Nil $f $t $acc) $acc)		
(= (List.tFoldl (Cons $x $xs) $f $t $acc) (let $tr ($t $x) (let $new-acc ($f $acc $tr) (List.tFoldl $xs $f $t $new-acc))))		



(= (List.tFoldr Nil $f $t $acc) $acc)		
(= (List.tFoldr (Cons $x $xs) $f $t $acc) (let $new-acc (List.tFoldr $xs $f $t $acc) (let $tr ($t $x) ($f $tr $new-acc))))	        

;; Define List.sum
(: List.sum (-> (List Number) Number))
(= (List.sum $xs) (List.foldr + 0 $xs))

(: List.append (-> $a (List $a) (List $a)))
(= (List.append $val Nil) (Cons $val Nil))
(= (List.append $val (Cons $head $tail)) (Cons $head (List.append $val $tail)))


;; Get an element by index from a list
(: List.getByIdx (-> (List $a) Number $a))
(= (List.getByIdx Nil $idx) (Error Nil (Index out of range)))
(= (List.getByIdx (Cons $head $tail) $idx) (if (== $idx 0 ) $head (List.getByIdx $tail (- $idx 1))) )


;; Insert an element to a presumably sorted list, remains sorted.
(: List.insert (-> $a (List $a) (List $a)))
(= (List.insert $x Nil) (Cons $x Nil))
(= (List.insert $x (Cons $head $tail))
   (if (< $x $head)
       (Cons $x (Cons $head $tail))
       (Cons $head (List.insert $x $tail))))


;; Sort a List in ascending order
(: List.sort (-> (List $a) (List $a)))
(= (List.sort Nil) Nil)

;;sort using custome oparator
(= (List.sort (Cons $head $tail) $op)
    (let* (($expr (List.listToExpr  (Cons $head $tail)))
            ($n (size-atom $expr))
           ($sortedExpr (selectionSort $expr $n $op))
           ($sortedList (exprToList $sortedExpr)))
        $sortedList)
)

;; helper function to find the length of the list
(: List.length (-> (List $a) Number))
(= (List.length Nil) 0)
(= (List.length (Cons $head $tail)) (+ 1 (List.length $tail)))


;; Map a function over a list
(: List.map (-> (-> $a $b) (List $a) (List $b)))
(= (List.map $f Nil) Nil)
(= (List.map $f (Cons $x $xs)) (Cons ($f $x) (List.map $f $xs)))


;; Map a function that takes an additional arg
(: List.mapOverArg (-> (-> $a $b $a) $b (List $a)))
(= (List.mapOverArg $f Nil $arg) Nil)
(= (List.mapOverArg $f (Cons $head $tail) $arg)
    (let $new-head ($f $head $arg)
        (if (== $new-head Nil)
            (List.mapOverArg $f $tail $arg)
            (Cons $new-head (List.mapOverArg $f $tail $arg)))))



;; Filter a list based on a predicate.
(: List.filter (-> (-> $a Bool) (List $a) (List $a)))
(= (List.filter $p Nil) Nil)
(= (List.filter $p (Cons $x $xs)) (if ($p $x) (Cons $x (List.filter $p $xs)) (List.filter $p $xs)))

;; Convert a list to an expression.
(: List.listToExpr (-> (List $a) Expression))
(= (List.listToExpr Nil) ())
(= (List.listToExpr (Cons $x $xs)) (let $t (List.listToExpr $xs) (cons-atom $x $t)))





