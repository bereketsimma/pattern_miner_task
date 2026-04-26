; ;; =============================================================================  
; ;; Function: checkInter  
; ;; -----------------------------------------------------------------------------  
; ;; Purpose:  
; ;;   Checks if element $x exists in accumulator list $acc using linear search.  
; ;;   Acts as a membership test to avoid duplicate variable entries.  
; ;;  
; ;; Parameters:  
; ;;   $x - The element to check for membership (any atom)  
;;   $acc - The list to search against (e.g., ($a $b $c))  
; ;;  
; ;; Returns:  
; ;;   True if $x is found in $acc, False otherwise  
; ;;  
; ;; Example:  
; ;;   (checkInter $x ($x $y $z)) → True  
; ;;   (checkInter $w ($x $y $z)) → False  
; ;; ============================================================================= 
(= (does-exist $unknown $storage)
    (
        if (== $storage ())
            False
            (
                let*
                    (
                        ($top (car-atom $storage))
                        ($leftExpression (cdr-atom $storage))
                    )
                    
                    (
                        if (== $top $unknown)
                            True
                            (does-exist $unknown $leftExpression)
                    )
            )
    )
)
!(= (checkInter $x $acc) (does-exist $x $acc))
 
; !(checkInter 1 ( 1 2 3 2 3 4 5 6 6 6 6 6 ))  ;; Should return True  
  
; !(println "Test - Element doesn't exist:")  
; !(checkInter 4 ( 1 2 3,5,5,5,6,6,6,6))  ;; Should return False


; ;; =============================================================================  
; ;; Function: is-variable  
; ;; -----------------------------------------------------------------------------  
; ;; Purpose:  
; ;;   Type check to determine if an atom is a variable type in MeTTa.  
; ;;  
; ;; Parameters:  
; ;;   $var - The atom to check type for  
; ;;  
; ;; Returns:  
; ;;   True if $var has Variable metatype, False otherwise  
; ;;  
; ;; Example:  
; ;;   (is-variable $x) → True  
; ;;   (is-variable Inheritance) → False  
; ;; =============================================================================  
(= (is-variable $var)       
   (== (get-metatype $var) Variable)) 



    ; !(let (($var2 20)) $var2) 
    ;    ! (let (($var3 (+ $var1 $var2)))  
    ;         ($var1 $var3))



  
; ;; =============================================================================  
; ;; Function: get-variables  
; ;; -----------------------------------------------------------------------------  
; ;; Purpose:  
; ;;   Recursively extracts all unique variables from a pattern expression.  
; ;;   Handles nested expressions and avoids duplicates using accumulator pattern.  
; ;;  
; ;; Parameters:  
; ;;   $pattern - The expression to scan (e.g., (P $x (Q $y $x)))  
; ;;   $acc - Accumulator list for variables (start with ())  
; ;;  
; ;; Returns:  
; ;;   List of unique variables found in $pattern (e.g., ($x $y))  
; ;;  
; ;; How it works:  
; ;;   1. Base Case: Returns $acc when $pattern is empty  
; ;;   2. Recursive Steps:  
; ;;      a. If head is Expression: recursively process both head and tail  
; ;;      b. If head is Variable and not in accumulator: add to accumulator  
; ;;      c. Otherwise: continue with tail  
; ;; =============================================================================  
(= (get-variables $pattern $acc)    
    (if (== $pattern ())    
        $acc     
        (let* (($head (car-atom $pattern))    
               ($tail (cdr-atom $pattern)))    
            (if (== (get-metatype $head) Expression)    
                ;; recurse into expression first
                (get-variables $tail (get-variables $head $acc))    
                (if (and (is-variable $head)    
                         (not (checkInter $head $acc)))    
                    ;; FIX: bind recursion result first
                    (let* (($updated (get-variables $tail $acc)))
                      (cons-atom $head $updated))    
                    (get-variables $tail $acc))))))


  
;  !(println "Test - Get Variables:") 
; !(get-variables (Inheritance) ())  

;  !(get-variables (Inheritance $x human)  )  
; !(get-variables (Inheritance $x $y) ())  
; !(get-variables (Inheritance $x (Inheritance $y human) $z) ()) 
; !(get-variables ((Inheritance $x $y) (Inheritance $x $z) (Inheritance $a $b) (Inheritance $c $d) (Inheritance $e $f) (Inheritance $g $h)) ()) 





(= (get-patterns-variables $patterns $acc)  
    (if (== $patterns ())  
        $acc  
        (let* (
          (($head $tail)(decons-atom $patterns)) 
          ($new-acc (get-variables $head $acc))
        )
          (get-patterns-variables $tail $new-acc)
     )  
)
)
        ; !(get-patterns-variables ((Inheritance $x human) (Inheritance $x $y)) ())

; !(println "Test - Get Patterns Variables:")
; !(get-patterns-variables ((Inheritance $x human) (Iheritance $y $z) (Inheritance $a $b) (Inheritance $c $d) (Inheritance $e $f) (Inheritance $g $h)) ())
            ;; dsu intialize  


            ======================  
(= (dsu-initialize $variables)        
    (if (== $variables ())        
        (() ()   )    
        (let* (
            ($parent (map-atom $variables $v ($v $v)))         
            ($rank (map-atom $variables $v ($v 0)))  )
            ($parent $rank) 
            )  
         ) 
        )  
!(dsu-initialize ($a $b $c $d $e $f $g))
 
        ; ;; =============================================================================
; ;; Function: dsu-find
; ;; -----------------------------------------------------------------------------
; ;; Purpose:
; ;;   Finds the root representative of a variable in DSU.
; ;;   Uses path compression to flatten the structure for efficiency.
; ;;
; ;; Parameters:
; ;;   $x - The variable to find root for
; ;;   $parent - The parent map
; ;;
; ;; Returns:
; ;;   Root representative of $x
; ;; =============================================================================

 
(= (dsu-find $x $parent)
   (let* (($parent_x (get_value $x $parent)))
     (if (== $parent_x ())
         ($x $parent)   ;; root is itself, parent unchanged
         (if (== $parent_x $x)
             ($x $parent) ;; already root
             (let* ((($root $new-parent) (dsu-find $parent_x $parent))
                    ($updated-parent (update-parent-map $new-parent $x $root)))
               ($root $updated-parent))))))

(= (get_value $key $list)
    (if (== $list ())
        ()
        (let*
            (
                ((($temp1 $temp2) $tail) (decons-atom $list))


            )
            (
                if (== $key $temp1)
                    $temp2
                    (get_value $key $tail)
            )

        )
    )
)



; ;; =============================================================================
; ;; Function: update-parent-map
; ;; -----------------------------------------------------------------------------
; ;; Purpose:
; ;;   Updates the parent (or rank) map by replacing the value associated
; ;;   with a given key. If the key exists, its value is updated; if not,
; ;;   the recursion ensures the rest of the list is preserved.
; ;;
; ;; Parameters:
; ;;   $list  - Association list of pairs (e.g., (($a $a) ($b $b)))
; ;;   $key   - The key atom whose mapping should be updated
; ;;   $value - The new value to associate with $key
; ;;
; ;; Returns:
; ;;   A new association list with $key mapped to $value, preserving
; ;;   all other mappings unchanged.
; ;;
; ;; Example:
; ;;   (update-parent-map (($a $a) ($b $b) ($c $c)) $b $a)
; ;;   → (($a $a) ($b $a) ($c $c))
; ;; =============================================================================


(= (update-parent-map $list $key $value)  
    (if (== $list ())  
        (cons-atom ($key $value) ())  
        (let* (($pair (car-atom $list))  
               ($k (car-atom $pair))  
               ($rest (cdr-atom $list)))  
            (if (== $k $key)  
                ;; Update existing
                (cons-atom ($key $value) $rest)  
                ;; Compute recursion first, then cons
                (let* (($updated-rest (update-parent-map $rest $key $value)))  
                  (cons-atom $pair $updated-rest))))))

!(update-parent-map (($a $a) ($b $b) ($c $c)) $b $a)


            
=====================  
;; -----------------------------------------------------------------------------  
; ;; =============================================================================
; ;; Function: dsu-union
; ;; -----------------------------------------------------------------------------
; ;; Purpose:
; ;;   Merges two sets if they are disjoint.
; ;;   Uses union by rank to keep trees shallow.
; ;;
; ;; Parameters:
; ;;   $x, $y - Variables to union
; ;;   $parent - Parent map
; ;;   $rank - Rank map
; ;;
; ;; Returns:
; ;;   Updated ($parent $rank)
; ;; =============================================================================


(= (dsu-union $x $y $parent $rank)
   (let* (
          (($rootX $parent1)  (dsu-find $x $parent))
          (($rootY $parent2)  (dsu-find $y $parent))
         )
    ;; check if already connected
     (if (== $rootX $rootY)
         ($parent $rank)  ;; already connected

        ;  else?
         (let* (
                ($rankX (get_value $x $rank))
                ($rankY (get_value $y $rank))
               )
           ;; compare ranks
           (if (< $rankX $rankY)
               ;; attach X under Y
               (let* (($new-parent (update-parent-map $parent $rootX $rootY)))
                 ($new-parent $rank))
               (if (> $rankX $rankY)
                   ;; attach Y under X
                   (let* (($new-parent (update-parent-map $parent $rootY $rootX)))
                     ($new-parent $rank))
                   ;; equal ranks: attach Y under X and increment X’s rank
                   (let* (
                          ($new-parent (update-parent-map $parent $rootY $rootX))
                          ($new-rank   (update-parent-map $rank $rootX (+ $rankX 1)))
                         )
                    ($new-parent $new-rank)
                    )
                    
                    

                    )
                )
            )   
                    
                    )
    
    ))                   
 !(dsu-union $a $b (($a $a) ($b $b) ($c $c)) (($a 0) ($b 0) ($c 0)))



   ; ;; =============================================================================
; ;; Function: safe-union
; ;; -----------------------------------------------------------------------------
; ;; Purpose:
; ;;   Sequentially unions variables in a list using DSU. Ensures that
; ;;   pairwise unions are applied safely without breaking when the list
; ;;   is empty or has only one element.
; ;;
; ;; Parameters:
; ;;   $vars   - List of variables to union (e.g., ($a $b $c))
; ;;   $parent - Current parent map
; ;;   $rank   - Current rank map
; ;;
; ;; Returns:
; ;;   Updated ($parent $rank) after applying unions.
; ;;
; ;; Example:
; ;;   (safe-union ($a $b $c) (($a $a) ($b $b) ($c $c)) (($a 0) ($b 0) ($c 0)))
; ;;   → Updated parent and rank maps
; ;; =============================================================================

            



(= (safe-union $vars $parent $rank)
   (if (== $vars ())
       ;; Case 0: empty list
       ($parent $rank)
        (let* (($oneatom (car-atom $vars)) 
                ($rest (cdr-atom $vars)  )  )
       (if (== $rest ())
           ($parent $rank)
            (let* (
                 ($first (car-atom $vars))
                  ($inner  (cdr-atom $vars))
                  ($second (car-atom $inner))
                  (
    ($parent1 $rank1) (dsu-union $first $second $parent $rank))

                 )
             (safe-union $inner $parent1 $rank1)
            ))  ) ))
          
!(safe-union ($a  $b $c $d) (($a $a) ($b $b) ($c $c) ($d $d) ) (($a 0) ($b 0) ($c 0) ($d 0)))


; ;; =============================================================================
; ;; Function: union-patterns
; ;; -----------------------------------------------------------------------------
; ;; Purpose:
; ;;   Applies safe-union to each pattern in a list. Extracts variables
; ;;   from each pattern, unions them, and recurses through all patterns.
; ;;
; ;; Parameters:
; ;;   $patterns - List of pattern expressions
; ;;   $parent   - Current parent map
; ;;   $rank     - Current rank map
; ;;
; ;; Returns:
; ;;   Updated ($parent $rank) after unions across all patterns.
; ;;
; ;; Example:
; ;;   (union-patterns ((Inheritance $x $y) (Inheritance $z $w))
; ;;                   (($x $x) ($y $y) ($z $z) ($w $w))
; ;;                   (($x 0) ($y 0) ($z 0) ($w 0)))
; ;;   → Updated parent and rank maps
; ;; =============================================================================

(= (union-patterns $patterns $parent $rank)
   (if (== $patterns ())
       ($parent $rank)
       (let* (
              ($vars (get-variables (car-atom $patterns) ()))
              (($parent1 $rank1) (safe-union $vars $parent $rank))
             )
         (union-patterns (cdr-atom $patterns) $parent1 $rank1))))


 (= (dsu-are-disjoint $patterns)
   (let* (
          ;; collect all variables from all patterns
          ($all-vars (get-patterns-variables $patterns ()))
          (($parent $rank) (dsu-initialize $all-vars))

          ;; union variables inside each pattern
          (($parent-final $rank-final)
          (union-patterns $patterns $parent $rank))



;           ;; pick representatives (first variable from each pattern)
        ($roots (map-atom $patterns $p
           (let* (($vars (get-variables $p ())))
             (if (== $vars ())
                 ()              ;; skip if no variables
                 (car-atom $vars)))))
 )
(all-same-root $roots $parent-final)  

))

; ;; =============================================================================
; ;; Function: all-same-root
; ;; -----------------------------------------------------------------------------
; ;; Purpose:
; ;;   Checks if all variables in a list share the same DSU root.
; ;;   Returns True if they are all connected (conjunct), False otherwise (disjoint).
; ;;
; ;; Parameters:
; ;;   $vars   - List of variables to check
; ;;   $parent - Parent map from DSU
; ;;
; ;; Returns:
; ;;   True if all variables share the same root, False otherwise
; ;; =============================================================================
(= (all-same-root $vars $parent)    
    (if (== $vars ())    
        True   ;; Empty list: vacuously true    
        (if (== (cdr-atom $vars) ())    
            True   ;; Single element: trivially true    
            (let* (($first-var (car-atom $vars))    
                   (($first-root $new-parent) (dsu-find $first-var $parent))    
                   ($rest-vars (cdr-atom $vars)))    
                (all-same-root-helper $rest-vars $first-root $new-parent)))))    

    
; ;; =============================================================================
; ;; Function: all-same-root-helper
; ;; -----------------------------------------------------------------------------
; ;; Purpose:
; ;;   Recursively checks if each variable in the list has the same root
; ;;   as the target root. Returns True if all match, False otherwise.
; ;;
; ;; Parameters:
; ;;   $vars        - Remaining variables to check
; ;;   $target-root - Root to compare against
; ;;   $parent      - Parent map from DSU
; ;;
; ;; Returns:
; ;;   True if all variables match the target root, False otherwise
; ;; =============================================================================
(= (all-same-root-helper $vars $target-root $parent)    
    (if (== $vars ())    
        True   ;; All elements matched    
        (let* (($current-var (car-atom $vars))    
               (($current-root $new-parent) (dsu-find $current-var $parent))    
               ($rest-vars (cdr-atom $vars)))    
            (if (== $current-root $target-root)    
                (all-same-root-helper $rest-vars $target-root $new-parent)    
                False))))  




;    ;; Return the final DSU structure for debugging
!(dsu-are-disjoint
   ((Inheritance $x $y)
    (Inheritance $z $w)
    (Inheritance $x $w)))
; ;; → "Conjunct"

!(dsu-are-disjoint
   ((Inheritance $x $y)
    (Inheritance $a $b)
    (Inheritance $c $d)))
; ;; → "Disjoint"


!(dsu-are-disjoint
   ((Relation $x $y $z)
    (Relation $z $w $u)))
;; Expected: "conjunct" (shared $z links them)

!(dsu-are-disjoint
   ((Relation $x $y $z)
    (Relation $a $b $c)))
;; Expected: "disjoint" (no overlap)


!(dsu-are-disjoint
   ((Inheritance $x human)
    (Inheritance $y human)))
;; Expected: "disjoint" (different variables, same constant)

!(dsu-are-disjoint
   ((Inheritance $x human)
    (Inheritance $x animal)))
;; Expected: "conjunct" (same variable $x links them)



    
