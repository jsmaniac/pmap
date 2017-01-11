#lang racket

(require racket/place)
(require racket/runtime-path)

(define-runtime-path worker "pmapp_worker.rkt")
;(define pa (build-path (current-directory) "pmapp_worker.rkt"))

(provide pmapp-quoted pmapp)

(define (transpose lists) ; columns to rows!
  (apply map list lists))

(define (pmapp-quoted func . args) ;start places, give work, collect results, stop places.
  
  (define jlist (transpose args))
  ;(display jlist)

  (let* ([pls (for/list ([i (in-range (length jlist))])
                (dynamic-place worker 'pmapp-worker))]
         [wpls (for/list ([j pls] [w jlist])
                 (place-channel-put j (cons func w)))]         
         [rlist (for/list ([v pls]) (place-channel-get v))]
         [stop (map place-wait pls)])
     rlist
     ))

(define-syntax (pmapp stx)
  (syntax-case stx ()
    [(_ func . args)
     (quasisyntax/loc stx
       (pmapp-quoted #,(syntax/loc #'func 'func) . args))]))