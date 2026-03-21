;; DSU Find operation with path compression  
(= (dsu-find $parent $x)  
    (if (== (index-atom $parent $x) $x)  
        $x  
        (let* (($root (dsu-find $parent (index-atom $parent $x))))  
            ;; Path compression  
            (replace-atom $parent $x $root)  
            $root)))  
  
;; DSU Union operation    
(= (dsu-union $parent $rank $x $y)  
    (let* (($root-x (dsu-find $parent $x))  
           ($root-y (dsu-find $parent $y)))  
        (if (== $root-x $root-y)  
            ($parent $rank)  ;; Already in same set  
            (let* (($rank-x (index-atom $rank $root-x))  
                   ($rank-y (index-atom $rank $root-y)))  
                (if (> $rank-x $rank-y)  
                    ;; Attach smaller tree to larger  
                    (let* (($new-parent (replace-atom $parent $root-y $root-x)))  
                        ($new-parent $rank))  
                    (let* (($new-parent (replace-atom $parent $root-x $root-y))  
                           ($new-rank (if (== $rank-x $rank-y)  
                                         (replace-atom $rank $root-y (+ $rank-y 1))  
                                         $rank)))  
                        ($new-parent $new-rank)))))))
;; Extract variables from a conjunction pattern  
(= (extract-pattern-variables $conjunction)  
    (get-variables $conjunction ()))

;; Initialize DSU for a set of variables  
(= (dsu-initialize $variables)  
    (let* (($parent (map-atom $variables $v $v))  
           ($rank (map-atom $variables $v 0)))  
        ($parent $rank)))  
  
;; Check if two patterns are disjoint using DSU  
(= (dsu-are-disjoint $pattern1 $pattern2)  
    (let* (($vars1 (extract-pattern-variables $pattern1))  
           ($vars2 (extract-pattern-variables $pattern2))  
           ($all-vars (union-atom $vars1 $vars2)))  
        (if (or (== $vars1 ()) (== $vars2 ()))  
            True  ;; Empty pattern is disjoint with anything  
            (let* (($dsu (dsu-initialize $all-vars))  
                   ($parent (car-atom $dsu))  
                   ($rank (cadr-atom $dsu)))  
                ;; Check if any variable from pattern1 shares a set with pattern2  
                (not (any-variable-connected $parent $vars1 $vars2))))))  
  
;; Helper to check if any variables are connected  
(= (any-variable-connected $parent $vars1 $vars2)  
    (if (== $vars1 ())  
        False  
        (let* (($var1 (car-atom $vars1))  
               ($rest1 (cdr-atom $vars1)))  
            (if (any-variable-in-same-set $parent $var1 $vars2)  
                True  
                (any-variable-connected $parent $rest1 $vars2)))))  
  
;; Check if a variable is in the same set as any variable in a list  
(= (any-variable-in-same-set $parent $var $var-list)  
    (if (== $var-list ())  
        False  
        (let* (($var2 (car-atom $var-list))  
               ($rest (cdr-atom $var-list)))  
            (if (== (dsu-find $parent $var) (dsu-find $parent $var2))  
                True  
                (any-variable-in-same-set $parent $var $rest)))))