#lang racket

;; Simple roshambo game.
;; Local version rock, paper, scissors.
;; Not too exciting but useful for planning
;; the more interesting networked version.

(require 2htdp/universe)
(require 2htdp/image)
(require "shared.rkt")

(define P1-WINS "Player 1 wins!")
(define P2-WINS "Player 2 wins!")

(define BACKGROUND
  (overlay 
   (rectangle 400 300 "solid" "pink")
   (empty-scene 400 300)))

(define (print-message message)
  (text message 48 "black"))

(define (pick-winner choices)
  (define p1 (list-ref choices 1))
  (define p2 (list-ref choices 0))
  (cond [(and (string=? p1 "r") (string=? p2 "s")) P1-WINS]
        [(and (string=? p1 "r") (string=? p2 "p")) P2-WINS]
        [(and (string=? p1 "p") (string=? p2 "r")) P1-WINS]
        [(and (string=? p1 "p") (string=? p2 "s")) P2-WINS]
        [(and (string=? p1 "s") (string=? p2 "p")) P1-WINS]
        [(and (string=? p1 "s") (string=? p2 "r")) P2-WINS]
        [else "It is a tie."]))

(define (draw-gui choices)
  (define state (length choices))
  (define message 
   (cond
     [(= state 0) (print-message "Player 1")]
     [(= state 1) (print-message "Player 2")]
     [(= state 2) (print-message (pick-winner choices))]))
  (overlay message BACKGROUND))

(define (key-event choices choice)
  (if
   (and
    (< (length choices) 3)
    is-valid-choice?)
   (cons choice choices)
   choices))

(define (game-over choices)
  (= (length choices) 3))

(big-bang empty
  (to-draw draw-gui)
  (on-key key-event)
  (stop-when game-over))
  