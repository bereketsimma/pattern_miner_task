;; =============================================================================  
;; Function: checkInter  
;; -----------------------------------------------------------------------------  
;; Purpose:  
;;   Checks if element $x exists in accumulator list $acc using linear search.  
;;   Acts as a membership test to avoid duplicate variable entries.  
;;  
;; Parameters:  
;;   $x - The element to check for membership (any atom)  
;;   $acc - The list to search against (e.g., ($a $b $c))  
;;  
;; Returns:  
;;   True if $x is found in $acc, False otherwise  
;;  
;; Example:  
;;   (checkInter $x ($x $y $z)) → True  
;;   (checkInter $w ($x $y $z)) → False  
;; =============================================================================  
(= (checkInter $x $acc)  
    (if (== $acc ())  
        False  
        (if (== (car-atom $acc) $x)  
            True  
            (checkInter $x (cdr-atom $acc)))))  
  
;; =============================================================================  
;; Function: is-variable  
;; -----------------------------------------------------------------------------  
;; Purpose:  
;;   Type check to determine if an atom is a variable type in MeTTa.  
;;  
;; Parameters:  
;;   $var - The atom to check type for  
;;  
;; Returns:  
;;   True if $var has Variable metatype, False otherwise  
;;  
;; Example:  
;;   (is-variable $x) → True  
;;   (is-variable Inheritance) → False  
;; =============================================================================  
(= (is-variable $var)       
   (== (get-metatype $var) Variable))  
  
;; =============================================================================  
;; Function: get-variables  
;; -----------------------------------------------------------------------------  
;; Purpose:  
;;   Recursively extracts all unique variables from a pattern expression.  
;;   Handles nested expressions and avoids duplicates using accumulator pattern.  
;;  
;; Parameters:  
;;   $pattern - The expression to scan (e.g., (P $x (Q $y $x)))  
;;   $acc - Accumulator list for variables (start with ())  
;;  
;; Returns:  
;;   List of unique variables found in $pattern (e.g., ($x $y))  
;;  
;; How it works:  
;;   1. Base Case: Returns $acc when $pattern is empty  
;;   2. Recursive Steps:  
;;      a. If head is Expression: recursively process both head and tail  
;;      b. If head is Variable and not in accumulator: add to accumulator  
;;      c. Otherwise: continue with tail  
;; =============================================================================  
(= (get-variables $pattern $acc)    
    (if (== $pattern ())    
        $acc     
        (let* (($head (car-atom $pattern))    
               ($tail (cdr-atom $pattern)))    
            (if (== (get-metatype $head) Expression)    
                (get-variables $tail    
                    (get-variables $head $acc))    
                (if (and (is-variable $head)    
                         (not (checkInter $head $acc)))    
                    (get-variables $tail    
                        (cons-atom $head $acc))    
                    (get-variables $tail $acc))))))  
  
;; =============================================================================  
;; Function: get-patterns-variables  
;; -----------------------------------------------------------------------------  
;; Purpose:  
;;   Collects all unique variables from multiple patterns in a list.  
;;   Combines variables from each pattern into a single accumulator.  
;;  
;; Parameters:  
;;   $patterns - List of patterns to process (e.g., ((P $x) (Q $y $x)))  
;;   $acc - Accumulator for variables (start with ())  
;;  
;; Returns:  
;;   List of all unique variables across all patterns  
;;  
;; Example:  
;;   (get-patterns-variables ((Inheritance $x $y) (Inheritance $x $z)) ())  
;;   → ($x $y $z)  
;; =============================================================================  
(= (get-patterns-variables $patterns $acc)  
    (if (== $patterns ())  
        $acc  
        (let* (($head (car-atom $patterns))  
               ($tail (cdr-atom $patterns))  
               ($new-acc (get-variables $head $acc)))  
            (get-patterns-variables $tail $new-acc))))  
  
;; =============================================================================  
;; Function: dsu-initialize  
;; -----------------------------------------------------------------------------  
;; Purpose:  
;;   Initializes Disjoint Set Union data structure with given variables.  
;;   Each variable starts as its own parent (root) with rank 0.  
;;  
;; Parameters:  
;;   $variables - List of variables to initialize (e.g., ($x $y $z))  
;;  
;; Returns:  
;;   Tuple: (parent-map rank-map)  
;;   - parent-map: Association list where each variable maps to itself  
;;   - rank-map: Association list where each variable maps to rank 0  
;;  
;; Example:  
;;   (dsu-initialize ($x $y))  
;;   → ((($x $x) ($y $y)) (($x 0) ($y 0)))  
;; =============================================================================  
(= (dsu-initialize $variables)      
    (if (== $variables ())      
        (() ())      
        (let* (($p (map-atom $variables $v ($v $v)))       
               ($rank (map-atom $variables $v ($v 0))))          
            ($p $rank))))  
  
;; =============================================================================  
;; Function: get_value  
;; -----------------------------------------------------------------------------  
;; Purpose:  
;;   Association list lookup to find value associated with key.  
;;   Searches through list of (key value) pairs.  
;;  
;; Parameters:  
;;   $key - The key to search for  
;;   $list - Association list of (key value) pairs  
;;  
;; Returns:  
;;   Value associated with key, or empty list () if not found 

(= (get_value $key $list)
    (if (== $list ())
        ()
        (if (== $key (let $temp (car-atom $list) (car-atom $temp)))
            (let $temp2 (car-atom $list) (cdr-atom $temp2))
            (get_value $key (cdr-atom $list)))
    )
)

!(let* ($parent $rank) (dsu-initialize ($a $b $c)))  
!(get_value $a $parent)  
!(get_value $b $parent)  
!(get_value $c $parent)  



;; =============================================================================  
;; Function: store_var_value  
;; -----------------------------------------------------------------------------  
;; Purpose:  
;;   Stores a key-value pair in an association list.  
;;   If key already exists, does nothing (no update).  
;;  
;; Parameters:  
;;   $list - The association list to store in  
;;   $key - The key to store  
;;   $value - The value to associate with the key  
;;  
;; Returns:  
;;   Updated association list with new key-value pair (if key was new)  
;;  
;; Example:  
;;   (store_var_value (($x 1)) $y 2) → (($y 2) ($x 1))  
;; =============================================================================  
(= (store_var_value $list $key $value)    
    (let* (($result (get_value $key $list))    
           ($key_pair (cons-atom $key $value)))    
        (if (== $result ())    
            (cons-atom $key_pair $list)    
            $list))) 
;; =============================================================================  
;; Function: dsu-find  
;; -----------------------------------------------------------------------------  
;; Purpose:  
;;   Finds the root (representative) of element $x in the Disjoint Set Union.  
;;   Implements path compression to optimize future find operations.  
;;  
;; Parameters:  
;;   $parent - Association list mapping elements to their parents  
;;   $x - The element to find the root of  
;;  
;; Returns:  
;;   The root element of $x (without returning updated parent map)  
;;  
;; How it works:  
;;   1. Look up parent of $x using get_value  
;;   2. If $x has no parent (empty list), $x is its own root  
;;   3. If $x is its own parent, $x is a root element  
;;   4. Otherwise, recursively find root of parent and apply path compression  
;;  
;; Example:  
;;   (dsu-find (($x $x) ($y $x)) $y) → $x  
;; =============================================================================  
(= (dsu-find $parent $x)    
    (let* (($parent_x (get_value $x $parent)))    
        (if (== $parent_x ())    
            $x    
            (if (== $parent_x $x)    
                $x    
                (let* (($root (dsu-find $parent $parent_x)))    
                    (let* (($new_parent (store_var_value $parent $x $root)))    
                        $root))))))  

;; =============================================================================  
;; Function: dsu-union (Version 1 - Simple)  
;; -----------------------------------------------------------------------------  
;; Purpose:  
;;   Merges two sets containing elements $x and $y using union by rank.  
;;   Simple version that doesn't return updated parent map from find operations.  
;;  
;; Parameters:  
;;   $parent - Association list of parent mappings  
;;   $rank - Association list of rank values for each root  
;;   $x - First element to union  
;;   $y - Second element to union  
;;  
;; Returns:  
;;   Tuple: (updated-parent updated-rank)  
;;  
;; Union Strategy:  
;;   - Find roots of both elements  
;;   - If same root, already connected - return unchanged  
;;   - Attach shorter tree to taller tree (union by rank)  
;;   - If same rank, attach $y to $x and increment $x's rank  
;; =============================================================================  
(= (dsu-union $parent $rank $x $y)    
    (let* (($root_x (dsu-find $parent $x))    
           ($root_y (dsu-find $parent $y)))    
        (if (== $root_x $root_y)    
            ($parent $rank)    
            (let* (($rank_x (get_value $root_x $rank))    
                   ($rank_y (get_value $root_y $rank)))    
                (if (> $rank_x $rank_y)    
                    (let* (($new_parent (store_var_value $parent $root_y $root_x)))    
                        ($new_parent $rank))    
                    (if (< $rank_x $rank_y)    
                        (let* (($new_parent (store_var_value $parent $root_x $root_y)))    
                            ($new_parent $rank))    
                        (let* (($new_parent (store_var_value $parent $root_y $root_x))    
                               ($new_rank (store_var_value $rank $root_x (+ $rank_x 1))))    
                            ($new_parent $new_rank))))))))  
  


!(dsu-find $new_parent2 $a)  
!(dsu-find $new_parent2 $c)


!(let* (($parent (($x $x) ($y $y)))  
        ($rank (($x 0) ($y 0))))  
    (dsu-union $parent $rank $x $y))  

!(let* (($parent (($x $x) ($y $x)))  
        ($rank (($x 0) ($y 0))))  
    (dsu-union $parent $rank $x $y))  
  
;; =============================================================================  
;; Function: union-var-pairs  
;; -----------------------------------------------------------------------------  
;; Purpose:  
;;   Unions all consecutive pairs of variables in a list.  
;;   Processes variables in pairs: (v1,v2), (v2,v3), (v3,v4), etc.  
;;  
;; Parameters:  
;;   $vars - List of variables to union in pairs  
;;   $parent - Current parent mapping  
;;   $rank - Current rank mapping  
;;  
;; Returns:  
;;   Tuple: (updated-parent updated-rank)  
;;  
;; Example:  
;;   (union-var-pairs ($x $y $z) $parent $rank)  
;;   → unions ($x,$y) then ($y,$z)  
;; =============================================================================  
(= (union-var-pairs $vars $parent $rank)  
    (if (== $vars ())  
        ($parent $rank)  
        (let $tail (cdr-atom $vars)  
            (if (== $tail ())  
                ($parent $rank)  
                (let* (($result (dsu-union $parent $rank (car-atom $vars) (car-atom $tail)))  
                       ($p2 (car-atom $result))  
                       ($r2 (car-atom (cdr-atom $result))))  
                    (union-var-pairs $tail $p2 $r2))))))  
  
;; =============================================================================  
;; Function: union-patterns  
;; -----------------------------------------------------------------------------  
;; Purpose:  
;;   Unions all variables within each pattern in a list of patterns.  
;;   For each pattern, unions all its variables together.  
;;  
;; Parameters:  
;;   $patterns - List of patterns to process  
;;   $parent - Current parent mapping  
;;   $rank - Current rank mapping  
;;  
;; Returns:  
;;   Tuple: (updated-parent updated-rank)  
;;  
;; Process:  
;;   For each pattern: extract variables → union them in pairs → continue  
;; =============================================================================  
(= (union-patterns $patterns $parent $rank)  
    (if (== $patterns ())  
        ($parent $rank)  
        (let* (($vars (get-variables (car-atom $patterns) ()))     
               ($result (union-var-pairs $vars $parent $rank))     
               ($p2 (car-atom $result))  
               ($r2 (car-atom (cdr-atom $result))))  
            (union-patterns (cdr-atom $patterns) $p2 $r2))))  
  
;; =============================================================================  
;; Function: any-connected  
;; -----------------------------------------------------------------------------  
;; Purpose:  
;;   Checks if any variable from vars1 is connected to any variable from vars2.  
;;   Two variables are connected if they share the same root in the DSU.  
;;  
;; Parameters:  
;;   $parent - Current parent mapping  
;;   $vars1 - First set of variables  
;;   $vars2 - Second set of variables  
;;  
;; Returns:  
;;   True if any connection exists, False otherwise  
;;  
;; Strategy:  
;;   For each variable in vars1: find its root → check if any var in vars2 shares root  
;; =============================================================================  
(= (any-connected $parent $vars1 $vars2)  
    (if (== $vars1 ())  
        False  
        (let* (($v1 (car-atom $vars1))             
               ($rest1 (cdr-atom $vars1))          
               ($f1 (dsu-find $parent $v1))        
               ($root1 (car-atom $f1))             
               ($p2 (car-atom (cdr-atom $f1))))    
            (if (any-same-root $p2 $root1 $vars2)     
                True  
                (any-connected $p2 $rest1 $vars2)))))  
  
;; =============================================================================  
;; Function: any-same-root  
;; -----------------------------------------------------------------------------  
;; Purpose:  
;;   Helper function to check if any variable in a list has a specific root.  
;;  
;; Parameters:  
;;   $parent - Current parent mapping  
;;   $root - The root to check for  
;;   $vars - List of variables to check  
;;  
;; Returns:  
;;   True if any variable has the given root, False otherwise  
;; =============================================================================  
(= (any-same-root $parent $root $vars)  
    (if (== $vars ())  
        False  
        (let* (($v2 (car-atom $vars))              
               ($rest (cdr-atom $vars))            
               ($f2 (dsu-find $parent $v2))        
               ($root2 (car-atom $f2))             
               ($p2 (car-atom (cdr-atom $f2))))    
            (if (== $root $root2)                  
                True  
                (any-same-root $p2 $root $rest)))))  
  
;; =============================================================================  
;; Function: dsu-are-disjoint  
;; -----------------------------------------------------------------------------  
;; Purpose:  
;;   Main function to determine if patterns are pairwise disjoint.  
;;   Patterns are disjoint if no variable from one pattern appears in another.  
;;  
;; Parameters:  
;;   $patterns - List of patterns to check for disjointness  
;;  
;; Returns:  
;;   True if patterns are disjoint, False if any variables are shared  
;;  
;; Algorithm:  
;;   1. Extract all variables from all patterns  
;;   2. Initialize DSU with each variable as its own set  
;;   3. Union variables within each pattern (variables in same pattern are connected)  
;;   4. Check if any variables from first pattern connect to variables from other patterns  
;;   5. Return negation (disjoint = NOT connected)  
;;  
;; Example:  
;;   (dsu-are-disjoint ((Inheritance $x $y) (Inheritance $z $w))) → True  
;;   (dsu-are-disjoint ((Inheritance $x $y) (Inheritance $y $z))) → False  
;; =============================================================================  
(= (dsu-are-disjoint $patterns)  
    (if (or (== $patterns ()) (== $patterns (,)))  
        True                  
        (let $rest (cdr-atom $patterns)  
            (if (== $rest ())  
                True             
                (let* (  
                    ($all-vars (get-patterns-variables $patterns ()))  
                    ($init (dsu-initialize $all-vars))  
                    ($parent (car-atom $init))  
                    ($init-tail (cdr-atom $init))      
                    ($rank (car-atom $init-tail)) )     
  
                    ($after-union (union-patterns $patterns $parent $rank))  
                    ($parent2 (car-atom $after-union))  
                    ($rank2 (car-atom (cdr-atom $after-union)))  
  
                    ($vars1 (get-variables (car-atom $patterns) ()))  
                    ($vars2 (get-patterns-variables $rest ())))  
  
                    (not (any-connected $parent2 $vars1 $vars2))))))
   !(dsu-are-disjoint ((Inheritance $x $y) (Inheritance $z $w))) 
!(dsu-are-disjoint ((Inheritance $x $y) (Inheritance $y $z))) 