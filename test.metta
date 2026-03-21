! (import! &self ../disjoint_conjuction.metta)

;; =============================================================================  
;; COMPREHENSIVE TEST DATA  
;; =============================================================================  
  
;; Create a rich test space with various inheritance patterns  
!(bind! &test-space (new-space))  
  
;; People and their properties  
!(add-atom &test-space (Inheritance Abe human))  
!(add-atom &test-space (Inheritance Abe man))  
!(add-atom &test-space (Inheritance Abe ugly))  
!(add-atom &test-space (Inheritance Abe sodaDrinker))  
  
!(add-atom &test-space (Inheritance Lily human))  
!(add-atom &test-space (Inheritance Lily woman))  
!(add-atom &test-space (Inheritance Lily beautiful))  
!(add-atom &test-space (Inheritance Lily teaDrinker))  
  
!(add-atom &test-space (Inheritance John human))  
!(add-atom &test-space (Inheritance John man))  
!(add-atom &test-space (Inheritance John tall))  
!(add-atom &test-space (Inheritance John coffeeDrinker))  
  
!(add-atom &test-space (Inheritance Mary human))  
!(add-atom &test-space (Inheritance Mary woman))  
!(add-atom &test-space (Inheritance Mary smart))  
!(add-atom &test-space (Inheritance Mary sodaDrinker))  
  
!(add-atom &test-space (Inheritance Bob human))  
!(add-atom &test-space (Inheritance Bob man))  
!(add-atom &test-space (Inheritance Bob strong))  
!(add-atom &test-space (Inheritance Bob waterDrinker))  
  
!(add-atom &test-space (Inheritance Alice human))  
!(add-atom &test-space (Inheritance Alice woman))  
!(add-atom &test-space (Inheritance Alice kind))  
!(add-atom &test-space (Inheritance Alice juiceDrinker))  
  
;; Relationships between people  
!(add-atom &test-space (Friendship Abe Lily))  
!(add-atom &test-space (Friendship John Mary))  
!(add-atom &test-space (Friendship Bob Alice))  
!(add-atom &test-space (Friendship Abe John))  
  
!(add-atom &test-space (Parent Abe John))  
!(add-atom &test-space (Parent Lily Mary))  
!(add-atom &test-space (Parent Bob Alice))  
  
;; =============================================================================  
;; TEST FUNCTIONS  
;; =============================================================================  
  
;; Basic DSU Operations Tests  
(=(test_dsu_initialization)(  
    let* (($dsu (dsu-initialize ($x $y $z)))  
           ($parent (car-atom $dsu))  
           ($rank (cadr-atom $dsu)))  
    (list $parent $rank)  
))  
  
(=(test_dsu_find)(  
    let* (($dsu (dsu-initialize ($x $y)))  
           ($parent (car-atom $dsu)))  
    (dsu-find $parent $x)  
))  
  
(=(test_dsu_union)(  
    let* (($dsu (dsu-initialize ($x $y)))  
           ($parent (car-atom $dsu))  
           ($rank (cadr-atom $dsu))  
           ($result (dsu-union $parent $rank $x $y))  
           ($new-parent (car-atom $result)))  
    (dsu-find $new-parent $x)  
))  
  
;; Variable Extraction Tests  
(=(test_get_variables_simple)(  
    (get-variables (Inheritance $x human))  
)  )
  
(=(test_get_variables_complex)(  
    (get-variables (, (Inheritance $x human) (Inheritance $y man)))  
)  
)
(=(test_get_variables_duplicate)(  
    (get-variables (, (Inheritance $x human) (Inheritance $x man)))  
)  
)
;; Disjointness Tests - Basic Patterns  
(=(test_disjoint_simple)(  
    (dsu-are-disjoint (Inheritance $x human) (Inheritance $y man))  
)  )
  
(=(test_connected_simple)(  
    (dsu-are-disjoint (Inheritance $x human) (Inheritance $x man))  
)  
)
;; Disjointness Tests - Complex Patterns  
(=(test_disjoint_complex)(  
    (dsu-are-disjoint   
        (, (Inheritance $x human) (Inheritance $y man))   
        (, (Inheritance $z sodaDrinker) (Inheritance $w ugly)))  
)  )
  
(=(test_connected_complex)(  
    (dsu-are-disjoint   
        (, (Inheritance $x human) (Inheritance $y man))   
        (, (Inheritance $x sodaDrinker) (Inheritance $y ugly)))  
)  )
  
;; Edge Cases  
(=(test_empty_pattern_1)(  
    (dsu-are-disjoint () (Inheritance $x human))  
)  
)
(=(test_empty_pattern_2)(  
    (dsu-are-disjoint (Inheritance $x human) ())  
)  )
  
(=(test_both_empty)(  
    (dsu-are-disjoint () ())  
)  
)
;; Real-world pattern tests based on test data  
(=(test_real_disjoint)(  
    (dsu-are-disjoint   
        (, (Inheritance $x man) (Inheritance $x ugly))  
        (, (Inheritance $y woman) (Inheritance $y beautiful)))  
)  )
  
(=(test_real_connected)(  
    (dsu-are-disjoint   
        (, (Inheritance $x human) (Inheritance $x sodaDrinker))  
          (, (Inheritance $x man) (Inheritance $x ugly)))  
)  )
  
;; =============================================================================  
;; TEST EXECUTION  
;; =============================================================================  
  
! (println "=== DSU Disjointness Checker - Comprehensive Test Suite ===")  
  
! (println "--- Basic DSU Operations ---")  
! (println "DSU Initialization:" (test_dsu_initialization))  
! (println "DSU Find:" (test_dsu_find))  
! (println "DSU Union:" (test_dsu_union))  
  
! (println "--- Variable Extraction ---")  
! (println "Simple pattern variables:" (test_get_variables_simple))  
! (println "Complex pattern variables:" (test_get_variables_complex))  
! (println "Duplicate handling:" (test_get_variables_duplicate))  
  
! (println "--- Basic Disjointness Tests ---")  
! (println "Disjoint simple patterns:" (test_disjoint_simple))  
! (println "Connected simple patterns:" (test_connected_simple))  
  
! (println "--- Complex Disjointness Tests ---")  
! (println "Disjoint complex patterns:" (test_disjoint_complex))  
! (println "Connected complex patterns:" (test_connected_complex))  
  
! (println "--- Edge Cases ---")  
! (println "Empty pattern 1:" (test_empty_pattern_1))  
! (println "Empty pattern 2:" (test_empty_pattern_2))  
! (println "Both empty:" (test_both_empty))  
  
! (println "--- Real-world Pattern Tests ---")  
! (println "Real disjoint patterns:" (test_real_disjoint))  
! (println "Real connected patterns:" (test_real_connected))  
  
! (println "=== Test Suite Complete ===")