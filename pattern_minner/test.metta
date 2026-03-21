!(register-module! ../../hyperon_minner)  
!(import! &self hyperon-miner:experiments:utils:common-utils)  
!(import! &self ./disjoint_conjuction)  
;; Test cases with console output  
!(println "Test 1 - DSU Find:")  
!(let* (($parent (($x $x) ($y $y) ($z $z)))  
       ($result (dsu-find $parent $x)))  
   $result)  
  
!(println "Test 2 - DSU Union:")  
!(let* (($parent (($x $x) ($y $y) ($z $z)))  
       ($rank (($x 0) ($y 0) ($z 0)))  
       ($result (dsu-union $parent $rank $x $y)))  
   $result)  
  
!(println "Test 3 - Disjoint patterns:")  
!(dsu-are-disjoint (Inheritance $x man) (Inheritance $y sodaDrinker))  
  
!(println "Test 4 - Non-disjoint patterns:")  
!(dsu-are-disjoint (Inheritance $x man) (Inheritance $x sodaDrinker))