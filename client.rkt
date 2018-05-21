#lang racket

(require 2htdp/universe)
(require 2htdp/image)
(require "shared.rkt")

(define SERVER LOCALHOST)

;; World is just a string indicating state.
;; "CONNECTING" -- starting and trying to register.
;; "SORRY"      -- no available space on server.
;; "LOBBY"    -- registered and waiting for an opponent.
;; "ROSHAMBO"   -- Server waiting for choice.
;; "WAITING"
;; "ROCK"
;; "PAPER"
;; "SCISSORS"
;; "WON"        
;; "LOST"       
;; "TIE"

(define WIDTH 500)
(define HEIGHT 300)
(define MID-X (/ WIDTH 2))
(define PROMPT-Y (* HEIGHT (/ 2 3)))
(define SCENE (empty-scene WIDTH HEIGHT))
(define TEXT-SIZE 28)

(struct ui (txt bg-color))

(define status (hash
                "CONNECTING" (ui (string-join (list "Connecting to" SERVER "...")) "gold")
                "SORRY"      (ui (string-join (list "Connection rejected by" SERVER ".")) "red")
                "LOBBY"      (ui "Waiting for opponent to join." "pink")
                "ROSHAMBO"   (ui "Choose (r)ock, (p)aper or (s)cissors." "palegreen")
                "WON"        (ui "You won!" "hotpink")
                "LOST"       (ui "You lost." "skyblue")
                "TIE"        (ui "It is a tie." "wheat")
                "QUIT"   (ui "Game over.  Bye!" "gray")))

(define (get-status w)
  (cond [(member w (list "ROCK" "PAPER" "SCISSORS"))
                (ui (string-append "You chose " w) "plum")]
        [else (hash-ref status w)]))



;; is-r-p-s? :: (w :: String) -> Boolean
(define (is-over? w)
  (member w (list "WON" "LOST" "TIE")))

(define (draw-gui w)
  (define u (get-status w))
  (define st (overlay (text (ui-txt u) TEXT-SIZE "black")
                      (overlay (rectangle WIDTH HEIGHT "solid" (ui-bg-color u))SCENE)))
  (if (member w (list "WON" "LOST" "TIE"))
      (place-image (text"Rematch? (y/n)" TEXT-SIZE "black") MID-X PROMPT-Y st)
      st))

(define (key-event w key)
  (cond [(and (is-over? w) (string=? key "y")) (make-package w key)]
        [(and (is-over? w) (string=? key "n")) (make-package w key)]
        [(and (string=? w "ROSHAMBO") (is-valid-choice? key)) (make-package w key)]
        [else w]))

(define (msg-event w msg)
  msg)
  
(big-bang "CONNECTING"
  (to-draw draw-gui)
  (on-key key-event)
  (register SERVER)
  (on-receive msg-event))
  