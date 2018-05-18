#lang racket

;; Roshambo server.
;; Networked rock, paper, scissors.

(require 2htdp/universe)
(require test-engine/racket-tests)
(require "shared.rkt")

;; The universe state is a list of (two) players.
(struct player (iw choice) #:transparent) 

;; connect :: (l :: List<player>, client :: IWorld) -> Bundle

(define (connect l client)
  (define p (length l))
  (define new-l (cons (player client "") l))
  (cond [(= p 0)
         (make-bundle
          new-l
          (list (make-mail client "LOBBY"))
          '())]
        [(= p 1)
         (make-bundle
          new-l
          (map (lambda (i)
                 (make-mail (player-iw i) "ROSHAMBO"))
               new-l)
          '())]
        [(> p 1)
         (make-bundle
          l
          (list (make-mail client "SORRY"))
          (list client))]))

;; handle-msg :: (l :: List<player>, client :: IWorld, msg :: String
(define (handle-msg l client msg)
  (make-bundle l empty empty))


(universe '()
          (on-new connect)
          (on-msg handle-msg))


(check-expect (connect empty iworld1)
              (make-bundle
               (cons (player iworld1 "") empty)
               (list (make-mail iworld1 "LOBBY"))
               '()))
(check-expect (connect (list (player iworld1 "")) iworld2)
              (make-bundle
               (cons (player iworld2 "") (list (player iworld1 "")))
               (list  (make-mail iworld2 "ROSHAMBO") (make-mail iworld1 "ROSHAMBO"))
               '()))
(check-expect (connect (list (player iworld2 "") (player iworld1 "")) iworld3)
              (make-bundle
               (list (player iworld2 "") (player iworld1 ""))
               (list (make-mail iworld3 "SORRY"))
               (list iworld3)))

(test)