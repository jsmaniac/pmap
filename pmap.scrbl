#lang scribble/manual

@require[scribble/example
         @for-label[pmap
                    racket/base
                    racket/future
                    racket/place
                    ]]

@title{pmap : Parallel map}
@author{APOS80}

@defmodule[pmap]

@(define make-evaluator (make-eval-factory '(pmap)))

@defproc[(pmapf [proc procedure?] [lst list?] ...+) list?]{
 The @racket[pmapf] function works as @racket[map] but applies the function to
 every item in the list or lists in parallel, using futures.

 Its restrictions is the same as for futures and map in general in Racket.

 @examples[#:eval (make-evaluator)
           (eval:check (pmapf + '(1 2 3) '(1 2 3)) '(2 4 6))]

 If the function being applied is too simple, @racket[pmap] might perform worse
 than @racket[map] because of the overhead a future generates.
}

@defproc[(pmapp [top-level-form any/c] [lst list?] ...+) list?]{
 The @racket[pmapp] function works almost like @racket[map] and applies the
 function to every item in the list or lists in parallel, using places.

 It expects the quoted form of the function to be executed, e.g. @racket['add1]
 instead of @racket[add1].

 Places have some restrictions and these have an impact on the implementation
 in several ways, @bold{read on!}

 On creation of a place, a @tt{.rkt} file is loaded into the new place,
 and one function defined within that file gets executed.

 The current implementation of @racket[pmapp] loads a file,
 @filepath{pmapp_worker.rkt}, which receives the quoted function, the
 arguments for an iteration, and @racket[eval]s the function with these
 arguments.
   
 This means that the bindings available are limited to those which are
 @racket[require]d by @filepath{pmapp_worker.rkt}. For now, this includes
 @racketmodname[racket], @racketmodname[racket/fixnum] and @racketmodname[math].

 Since @filepath{pmapp_worker.rkt} is part of this package, it is not easy to
 change these without modifying the package. It should however be possible,
 within the body of the quoted function, to use @racket[dynamic-require].

 @racket[pmapp] shows it strength in heavier calculations like approximating the
 Mandelbrot set, see the comparison section!

@examples[#:eval (make-evaluator)
          (eval:check (pmapp '(lambda (x y) (+ x y))
                             '(1 2 3)
                             '(1 2 3))
                      '(2 4 6))
          (eval:check (pmapp '(lambda (x y) (fl+ x y))
                             '(1.0 2.0 3.0)
                             '(1.0 2.0 3.0))
                      '(2.0 4.0 6.0))]
}

@section{Comparison}

We compare here running the core of a Mandelbrot-set computation, using the
code described in
@secref["effective-futures" #:doc '(lib "scribblings/guide/guide.scrbl")].

An comparison calling @racket[mandelbrot-iterations], twice:
@racketblock[
 "(10000001 10000001) (4976.39990234375 ms)" (code:comment "map")
 "(10000001 10000001) (4196.400146484375 ms)"(code:comment "pmapf")
 "(10000001 10000001) (1840.7998046875 ms)"  (code:comment "pmapp")
]

An comparison calling @racket[mandelbrot-iterations], four times, with
@tech["flonum" #:doc '(lib "scribblings/guide/guide.scrbl")]:
@racketblock[
 "(10000001 10000001 10000001 10000001) (9752.256591796875 ms)" (code:comment "map")
 "(10000001 10000001 10000001 10000001) (8613.47607421875 ms)"  (code:comment "pmapf")
 "(10000001 10000001 10000001 10000001) (1887.66064453125 ms)"  (code:comment "pmapp")
]
