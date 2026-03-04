(= (length Nil) 0)
(= (length (Cons $x $xs)) (+ 1 (length $xs)))

(= (is-member $x Nil) False)
(= (is-member $x (Cons $x $xs)) True)
(= (is-member $x (Cons $y $xs)) (is-member $x $xs))

(= (max-value (Cons $x Nil)) $x)
(= (max-value (Cons $x $xs)) 
   (let $m (max-value $xs) (if (> $x $m) $x $m)))

(= (remove-element $x Nil) Nil)
(= (remove-element $x (Cons $x $xs)) (remove-element $x $xs))
(= (remove-element $x (Cons $y $xs)) (Cons $y (remove-element $x $xs)))

(= (remove-duplicate Nil) Nil)
(= (remove-duplicate (Cons $x $xs))
   (Cons $x (remove-duplicate (remove-element $x $xs))))

(= (append Nil $list2) $list2)
(= (append (Cons $x $xs) $list2) (Cons $x (append $xs $list2)))

(= (sort Nil) Nil)
(= (sort (Cons $x $xs)) (insert $x (sort $xs)))

(= (insert $x Nil) (Cons $x Nil))
(= (insert $x (Cons $y $ys))
   (if (<= $x $y) (Cons $x (Cons $y $ys)) (Cons $y (insert $x $ys))))

(= (reverse Nil) Nil)
(= (reverse (Cons $x $xs)) (append (reverse $xs) (Cons $x Nil)))

!(length (Cons 3 (Cons 1 (Cons 5 (Cons 1 (Cons 2 Nil))))))
!(is-member 5 (Cons 3 (Cons 1 (Cons 5 (Cons 1 (Cons 2 Nil))))))
!(max-value (Cons 3 (Cons 1 (Cons 5 (Cons 1 (Cons 2 Nil))))))
!(remove-duplicate (Cons 3 (Cons 1 (Cons 5 (Cons 1 (Cons 2 Nil))))))
!(sort (Cons 3 (Cons 1 (Cons 5 (Cons 1 (Cons 2 Nil))))))
!(reverse (Cons 3 (Cons 1 (Cons 5 (Cons 1 (Cons 2 Nil))))))


(parent chandler john) 
(parent chandler pam)
(parent monica john)  
(parent monica pam)  
(parent monica adam)  
(parent monica jane)  
(parent john bob)
(parent  pam tim) 
(parent  jane joe)
(parent   adam eve)
(parent  pam kim)

(gender chandler male)
(gender monica female)
(gender john male)
(gender adam male)
(gender pam female)
(gender jane female)
(gender kim female)
(gender eve female)
(gender bob male)
(gender tim male)
(gender joey male)






;!(match &self (parent chandler john)  (chandler is john’s father))
;!(match &self (parent chandler pam)  (chandler is pam’s father))

;!(match &self (parent monica john)  (monica is john’s mother))
;!(match &self (parent monica pam)  (monica is pam’s mother))

!(match &self (parent $x john) $x)
(= (get-mother $x)  (match &self (parent $y $x)  (match &self (gender $y female) $y )))
(= (get-sibling $x)  (match &self (parent  $y $x)  (match &self (parent $y $z) $z )))
(= (get-uncle  $x)  (match &self (parent $y $x)  (match &self (gender $y female) $y )))

(= (get-uncle  $x)  
(match &self (parent  $y $x) 

(match &self (sibling $y $z)) 

(match &self (gender $z male))
$z))


(= (get-nephew $x)
   (match &self 
      (match &self (Parent $gp $x)        
        match &self (Parent $gp $p)       
        match &self (distinct $x $p)       
        match &self (Parent $p $c)        
       match &self  (Gender $c Male))      
      $c))

!(get-mother tim)
!(get-sibling pam) 
!(get-uncle tim) 
!(get-nephew john)



; (= (get-unlce $x)  (match &self (father $z $x)  (= (get-sibling $b)  (match &self (mother $y $x)  (match &self (mother $y $z) $z  )))))
; (= (get-unlce $x)  (match &self (mother $z $x)  (match &self (mother $z $y) $y )))

; ;SISTER OUTPUT
; !(get-sibling tim)  

; !(get-unlce pam)


; (parent john bob)
; (parent  pam tim) 
; (parent  pam kim)

; ;second children
; !(match &self (parent john bob)  (john is bob’s father))
; !(match &self (parent  pam tim)  (pam is tim’s mother))
; !(match &self (parent  pam kim)  (pam is kim’s mother))


; (parent monica adam)
; (parent monica jane)  

; !(match &self (parent monica adam)  (monica is adam’s mother))
; !(match &self (parent monica jane)  (monica is jane’s mother))

;  (parent adam eve)
;  (parent jane joey)


; !(match &self (parent adam eve)  (adam is eve’s father))
; !(match &self (parent jane joey)  (jane is joey’s mother))


















