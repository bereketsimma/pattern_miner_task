;; ============================================================================  
;; VARIABLE EXTRACTION UTILITIES  
;; ============================================================================  
  
;; Fixed duplicate detection using member check instead of intersection-atom  
(= (checkInter $x $acc)     
    (if (== $acc ())     
        False     
        (if (== $x (car-atom $acc))     
            True     
            (checkInter $x (cdr-atom $acc)))))
    
;; Type checking function that determines if an atom is a variable  
(= (is-variable $var)     
   (== (get-metatype $var) Variable))    
    
;; Core recursive function that extracts all unique variables from a MeTTa pattern  
(= (get-variables $pattern $acc)          
    (if (== $pattern ())          
        $acc           
        (let* (($head (car-atom $pattern))           
               ($tail (cdr-atom $pattern)))           
            (if (== (get-metatype $head) Expression)          
                (get-variables $tail          
                    (get-variables $head $acc))           
                (if (and (is-variable $head)          
                         (not (checkInter $head $acc)))  ;; Fixed: use (not ...) instead of == ()  
                    (get-variables $tail          
                        (cons $head $acc))  ;; Fixed: use cons instead of union-atom  
                    (get-variables $tail $acc))))))    
;; Convenience wrapper  
(= (get-variables $pattern)         
    (get-variables $pattern ()))        
        
;; ============================================================================  
;; DSU (DISJOINT SET UNION) DATA STRUCTURE OPERATIONS  
;; ============================================================================  
        
;; DSU Find operation with path compression [1](#123-0)   
(= (dsu-find $parent $x)          
    (if (== (index-atom $parent $x) $x)          
        $x          
        (let* (($root (dsu-find $parent (index-atom $parent $x))))          
            (replace-atom $parent $x $root)          
            $root)))          
          
;; DSU initialization function  
(= (dsu-initialize $variables)          
    (let* (($parent (map-atom $variables $v $v))          
           ($rank (map-atom $variables $v 0)))          
        ($parent $rank)))          
          
;; ============================================================================  
;; PATTERN DISJOINTNESS CHECKING ALGORITHM  
;; ============================================================================  
          
;; Modified to accept multiple patterns as a list  
(= (dsu-are-disjoint $patterns)  
    (if (== $patterns ())  
        True  ;; Empty list is disjoint  
        (let* (($first-pattern (car-atom $patterns))  
               ($rest-patterns (cdr-atom $patterns))  
               ($vars1 (get-variables $first-pattern ()))  
               ($vars2 (get-patterns-variables $rest-patterns ())))  
            (if (or (== $vars1 ()) (== $vars2 ()))  
                True  
                (let* (($all-vars (union-atom $vars1 $vars2))  
                       ($dsu (dsu-initialize $all-vars))  
                       ($parent (car-atom $dsu))  
                       ($rank (cadr-atom $dsu)))  
                    ;; Check if any variable from first pattern connects to rest  
                    (not (any-variable-connected $parent $vars1 $vars2)))))))  
  
;; Helper to extract variables from multiple patterns  
(= (get-patterns-variables $patterns $acc)  
    (if (== $patterns ())  
        $acc  
        (let* (($pattern (car-atom $patterns))  
               ($rest (cdr-atom $patterns))  
               ($vars (get-variables $pattern ())))  
            (get-patterns-variables $rest (union-atom $acc $vars)))))  
  
;; Helper function that checks if any variable from pattern1 connects to pattern2  
(= (any-variable-connected $parent $vars1 $vars2)          
    (if (== $vars1 ())          
        False          
        (let* (($var1 (car-atom $vars1))          
               ($rest1 (cdr-atom $vars1)))          
            (if (any-variable-in-same-set $parent $var1 $vars2)          
                True          
                (any-variable-connected $parent $rest1 $vars2)))))          
          
;; Core comparison function  
(= (any-variable-in-same-set $parent $var $var-list)          
    (if (== $var-list ())          
        False          
        (let* (($var2 (car-atom $var-list))          
               ($rest (cdr-atom $var-list)))          
            (if (== (dsu-find $parent $var) (dsu-find $parent $var2))          
                True          
                (any-variable-in-same-set $parent $var $rest)))))    
  
;; ============================================================================  
;; COMPREHENSIVE TEST CASES  
;; ============================================================================  
    
;; Test functions - now using quoted patterns  

; (= (test_simple_disjoint) (dsu-are-disjoint (inheritance $x $y) (inheritance $z $w)))   
; (= (test_simple_connected) (dsu-are-disjoint (inheritance $x $y) (inheritance $y $z)))  
; (= (test_complex_disjoint) (dsu-are-disjoint (inheritance $a $b) (inheritance $c $d) (inheritance $e $f)))
; (= (test_complex_connected) (dsu-are-disjoint (inheritance $a $b) (inheritance $b $c) (inheritance $c $d)))   
; (= (test_circular_first_to_last) (dsu-are-disjoint (inheritance $a $b) (inheritance $c $d) (inheritance $d $a))) 
; (= (test_circular_last_to_first) (dsu-are-disjoint (inheritance $x $y) (inheritance $y $z) (inheritance $z $x)))   
; (= (test_circular_chain) (dsu-are-disjoint (inheritance $p $q) (inheritance $q $r) (inheritance $r $s) (inheritance $s $p)))   
; (= (test_transitive_indirect) (dsu-are-disjoint (inheritance $a $b) (inheritance $c $d) (inheritance $b $c)))  
; (= (test_transitive_multi_step) (dsu-are-disjoint (inheritance $w $x) (inheritance $y $z) (inheritance $x $y) (inheritance $z $w)))    
; (= (test_transitive_complex) (dsu-are-disjoint (inheritance $m $n) (inheritance $o $p) (inheritance $q $r) (inheritance $n $o) (inheritance $p $q)))   
; (= (test_empty_pattern) (dsu-are-disjoint (inheritance $x $y) ()))
; (= (test_single_variable) (dsu-are-disjoint (inheritance $x $x) (inheritance $y $z)))   
; (= (test_identical_patterns) (dsu-are-disjoint (inheritance $a $b) (inheritance $a $b)))   
; (= (test_large_disjoint) (dsu-are-disjoint (inheritance $a1 $b1) (inheritance $a2 $b2) (inheritance $a3 $b3) (inheritance $a4 $b4) (inheritance $a5 $b5)))  
; (= (test_large_connected) (dsu-are-disjoint (inheritance $v1 $v2) (inheritance $v2 $v3) (inheritance $v3 $v4) (inheritance $v4 $v5) (inheritance $v5 $v1)))   
; (= (test_mixed_partial) (dsu-are-disjoint (inheritance $p $q) (inheritance $r $s) (inheritance $q $r) (inheritance $t $u)))
; ;; ============================================================================  
;; TEST EXECUTION  
;; ============================================================================


;; Fixed test functions with proper list wrapping  
(= (test_simple_disjoint) (dsu-are-disjoint ((inheritance $x $y) (inheritance $z $w))))     
(= (test_simple_connected) (dsu-are-disjoint ((inheritance $x $y) (inheritance $y $z))))    
(= (test_complex_disjoint) (dsu-are-disjoint ((inheritance $a $b) (inheritance $c $d) (inheritance $e $f))))  
(= (test_complex_connected) (dsu-are-disjoint ((inheritance $a $b) (inheritance $b $c) (inheritance $c $d))))     
  
;; Add missing test function  
(= (test_mixed_multiple) (dsu-are-disjoint ((inheritance $p $q) (inheritance $r $s) (inheritance $q $r) (inheritance $t $u) (inheritance $v $w))))

    
! (println "=== DSU Pattern Disjointness Test Results ===")    
! (println "")    
    
! (println "1. Simple disjoint patterns:")    
! (println "   Expected: True, Got:" (test_simple_disjoint))    
    
! (println "2. Simple connected patterns:")    
! (println "   Expected: False, Got:" (test_simple_connected))    
    
! (println "3. Complex disjoint patterns:")    
! (println "   Expected: True, Got:" (test_complex_disjoint))    
    
! (println "4. Complex connected patterns:")    
! (println "   Expected: False, Got:" (test_complex_connected))    
    
! (println "5. Circular - First to Last:")    
! (println "   Expected: False, Got:" (test_circular_first_to_last))    
    
! (println "6. Circular - Last to First:")    
! (println "   Expected: False, Got:" (test_circular_last_to_first))    
    
! (println "7. Circular - Chain Connection:")    
! (println "   Expected: False, Got:" (test_circular_chain))    
    
! (println "8. Transitive - Indirect Connection:")    
! (println "   Expected: False, Got:" (test_transitive_indirect))    
    
! (println "9. Transitive - Multi-step:")    
! (println "   Expected: False, Got:" (test_transitive_multi_step))    
    
! (println "10. Transitive - Complex Chain:")    
! (println "    Expected: False, Got:" (test_transitive_complex))    
    
! (println "11. Empty pattern test:")    
! (println "    Expected: True, Got:" (test_empty_pattern))    
    
! (println "12. Single variable patterns:")    
! (println "    Expected: True, Got:" (test_single_variable))    
    
! (println "13. Identical patterns:")    
! (println "    Expected: False, Got:" (test_identical_patterns))    
    
! (println "14. Large disjoint set:")    
! (println "    Expected: True, Got:" (test_large_disjoint))    
    
! (println "15. Large connected set:")    
! (println "    Expected: False, Got:" (test_large_connected))    
    
! (println "16. Mixed - Partial Connection:")    
! (println "    Expected: False, Got:" (test_mixed_partial))    
    
! (println "17. Mixed - Multiple Components:")    
! (println "    Expected: False, Got:" (test_mixed_multiple))    
    
! (println "")    
! (println "=== Test Complete ===")