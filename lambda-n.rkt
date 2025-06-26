#lang racket

(provide [rename-out (lambda-n lambda)])
(require [for-syntax racket])

(define-syntax (lambda-n stx)
  (syntax-case stx ()
    [(_ n-args)
     (let ([n (syntax->datum #'n-args)])
       (if (and (integer? n) (>= n 0))
           #'(lambda-n n-args (void))
           (raise-syntax-error #f "parameter count needs to be a non-negative integer" stx)))]
    [(_ n-args body ...)
     (let ([n (syntax->datum #'n-args)])
       (if (number? n)
           (if (and (integer? n) (>= n 0))

               (with-syntax ([(args ...) (datum->syntax stx (make-names n))])
                 #'(lambda (args ...) body ...))
               
               (raise-syntax-error #f "parameter count needs to be a non-negative integer" stx))
           #'(lambda n-args body ...)))]))

(define-for-syntax (make-names n)
  (for/list ([i (range 0 n)])
    (string->symbol (string-append "$" (number->string i)))))
