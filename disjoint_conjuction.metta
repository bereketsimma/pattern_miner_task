;; Helper to check if variable already exists in accumulator (duplicate detection)  
(= (checkInter $x $acc)   
    ((intersection-atom ($x) $acc)))  
  
;; Type checking helper  
(= (is-variable $var)   
   (== (get-metatype $var) Variable))  
  
;; Main variable extraction function with duplicate prevention  
(= (get-variables $pattern $acc)  
    (if (== $pattern ())  
        $acc   
        (let* (  
                ($head (car-atom $pattern))   
                ($tail (cdr-atom $pattern)))   
  
            (if (== (get-metatype $head) Expression)  
                (get-variables $tail  
                    (get-variables $head $acc))   
                (if (and (is-variable $head)  
                         (== (checkInter $head $acc) ()))   
                    (get-variables $tail  
                        (union-atom $acc ($head)))   
                    (get-variables $tail $acc))))))   
  
;; Overloaded version for convenience  
(= (get-variables $pattern)   
    (get-variables $pattern ()))  
  
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
  
;; Initialize DSU for a set of variables    
(= (dsu-initialize $variables)    
    (let* (($parent (map-atom $variables $v $v))    
           ($rank (map-atom $variables $v 0)))    
        ($parent $rank)))    
    
;; Check if two patterns are disjoint using DSU - MODIFIED TO USE get-variables DIRECTLY  
(= (dsu-are-disjoint $pattern1 $pattern2)    
    (let* (($vars1 (get-variables $pattern1 ()))    
           ($vars2 (get-variables $pattern2 ()))    
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
 
! (println "=== DSU Disjoint Conjunction Tests ===")    

;; Test Case 1: Disjoint patterns (should return True)    
! (println "Test 1: Disjoint patterns")    
! (let* (($pattern1 (inheritance $x $y))    
         ($pattern2 (inheritance $z $w)))    
    (println "Pattern1:" $pattern1)    
    (println "Pattern2:" $pattern2)    
    (println "Are disjoint?" (dsu-are-disjoint $pattern1 $pattern2)))    
  
;; Test Case 2: Connected patterns (should return False)    
! (println "Test 2: Connected patterns")    
! (let* (($pattern1 (inheritance $x $y))    
         ($pattern2 (inheritance $y $z)))    
    (println "Pattern1:" $pattern1)    
    (println "Pattern2:" $pattern2)    
    (println "Are disjoint?" (dsu-are-disjoint $pattern1 $pattern2)))    
  
;; Test Case 3: Empty pattern (should return True)    
! (println "Test 3: Empty pattern")    
! (let* (($pattern1 (inheritance $x $y))    
         ($pattern2 ()))    
    (println "Pattern1:" $pattern1)    
    (println "Pattern2:" $pattern2)    
    (println "Are disjoint?" (dsu-are-disjoint $pattern1 $pattern2)))    
  
! (println "=== Tests Complete ===")