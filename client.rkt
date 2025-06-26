#lang racket/base

(require rackunit syntax/macro-testing)
(require "lambda-n.rkt")

; Regular lambda should remain essentially unharmed

(check-equal? ((lambda () 4)) 4)
(check-equal? ((lambda (x) x) 3) 3)
(check-equal? ((lambda (x y) (+ x y)) 3 4) 7)
(check-equal? ((lambda x (apply + x)) 1 2) 3)

; Now the fun begins…

;; Body-less functions (return void)

(check-pred void? ((lambda 0)))
(check-pred void? ((lambda 1) 42))
(check-pred void? ((lambda 3) 4 5 6))

;; Fun functions

(define thunky (lambda 0 42))

(check-equal? (thunky) 42)
(check-exn exn:fail:contract:arity? (λ () (thunky 1)))


(check-equal? ((lambda 1 (* $0 $0)) 5) 25)

(check-equal? ((lambda 1
                 'ignore
                 "ignore this too"
                 (+ $0 $0))
               10)
              20)

(define square (lambda 1 (* $0 $0)))

(check-equal? (square 4) 16)


(define hypotenuse
  (lambda 2
    (sqrt (+ (square $0)
             (square $1)))))

(check-equal? (hypotenuse 3 4) 5)


(define quadratic-root+
  (lambda 3
    (let ([-b (- $1)]
          [√b2-4ac (sqrt (- (* $1 $1) (* 4 $0 $2)))]
          [2a (* 2 $0)])
      (/ (+ -b √b2-4ac)
         2a))))

(check-equal? (quadratic-root+ 1 -1 -1) 1.618033988749895)

;; Check syntax errors
;; Mechanism borrowed from https://github.com/racket/racket/issues/2996 (thanks Sorawee!)

(check-exn
 #rx"parameter count needs to be a non-negative integer"
 (λ ()
   (convert-syntax-error
    (let ()
      (lambda 1.4)))))

(check-exn
 #rx"parameter count needs to be a non-negative integer"
 (λ ()
   (convert-syntax-error
    (let ()
      (lambda 3/2 1 2)))))
