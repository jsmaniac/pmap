#lang info
(define collection "pmap")
(define deps '("base"
               "rackunit-lib"
               "reprovide-lang"))
(define build-deps '("scribble-lib"
                     "racket-doc"
                     "math-doc"))
(define scribblings '(("pmap.scrbl" ())))
(define pkg-desc "Parallel map")
(define version "1.0")
(define pkg-authors '(APOS80))
