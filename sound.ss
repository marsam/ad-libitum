(library (sound (1))
  (export start set-dsp! hush!)
  (import (chezscheme) (prefix (soundio) soundio:))
  (define (try thunk)
    (call/cc
     (lambda (k)
       (with-exception-handler
           (lambda (x) (k 0.0))
         thunk))))
  
  (define (safe-function f)
    (lambda args
      (try (lambda () (apply f args)))))
  
  (define (silence time channel) 0.0)
  
  (define *sound-out* (soundio:open-default-out-stream silence))
  
  (define (set-dsp! f)
    (soundio:sound-out-write-callback-set! *sound-out* (safe-function f)))
  
  (define (hush!) (set-dsp! silence))
  
  (define (start) (soundio:start-out-stream *sound-out*))
  )