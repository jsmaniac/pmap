#lang racket

(define worker-namespace
 (parameterize ((current-namespace (make-base-namespace)))
  (namespace-require 'racket)
   (namespace-require 'racket/flonum)
   (namespace-require 'racket/fixnum)
  (current-namespace)))
 
(eval 'force worker-namespace) ; -> #<procedure:force>

;(eval '(apply (lambda (x y)(* x y)) '(2 3)) worker-namespace)

(provide pmapp-worker)
 
(define (pmapp-worker place-ch)
  (let (
        [v (eval (place-channel-get place-ch) worker-namespace)])
        (place-channel-put place-ch v)
        
    ))