(library (ad-libitum midi (1))
  (export start stop set-note-on! set-note-off! set-cc!)
  (import (chezscheme)
          (prefix (ad-libitum scheduler) scheduler:)
          (prefix (portmidi) pm:))
  ;; (define (try thunk default)
  ;;   (call/cc
  ;;    (lambda (k)
  ;;      (with-exception-handler
  ;;          (lambda (x) (k default))
  ;;        thunk))))
  
  (define-syntax try
    (syntax-rules ()
      [(_ default e1 e2 ...)
       (guard (x [else default]) e1 e2 ...)]))
  
  (define (*on-note-on* timestamp data1 data2 channel)
    (printf "~s:~s:~s:~s\r\n" timestamp data1 data2 channel))
  
  (define (*on-note-off* timestamp data1 data2 channel)
    (printf "~s:~s:~s:~s\r\n" timestamp data1 data2 channel))
  
  (define (*on-cc* timestamp data1 data2 channel)
    (printf "~s:~s:~s:~s\r\n" timestamp data1 data2 channel))
  
  (define (set-note-on! f) (set! *on-note-on* f))
  (define (set-note-off! f) (set! *on-note-off* f))
  (define (set-cc! f) (set! *on-cc* f))
  
  (define *polling-cycle* 5e-3)
  
  (define *stream* #f)
  (define *scheduler* #f)
  
  (define (process-event timestamp type data1 data2 channel)
    (cond
      [(= type pm:*midi-note-on*) (*on-note-on* timestamp data1 data2 channel)]
      [(= type pm:*midi-note-off*) (*on-note-off* timestamp data1 data2 channel)]
      [(= type pm:*midi-cc*) (*on-cc* timestamp data1 data2 channel)]
      [else (printf "Unsupported event type: ~s\r\n" type)]))
  
  (define (make-safe-process-event timestamp)
    (lambda args
      (try #f (apply process-event timestamp args))))
  
  (define (process-events)
    (let ([timestamp (scheduler:now *scheduler*)])
      (pm:read *stream* (make-safe-process-event timestamp))
      (scheduler:schedule *scheduler*
                          (+ timestamp *polling-cycle*)
                          process-events)))
  
  (define (start now)
    (pm:init)
    (set! *stream* (pm:open-input 0))
    (set! *scheduler* (scheduler:simple-scheduler now))
    (scheduler:start-scheduler *scheduler*)
    (process-events))
  
  (define (stop)
    (scheduler:stop-scheduler *scheduler*)
    (pm:close *stream*)
    (pm:terminate))
  )