#lang racket

;; Roshambo server.
;; Networked rock, paper, scissors.
;;
;; After two clients register, they can choose
;; (r)ock, (p)aper or (s)cissors at their leisure.
;; The server returns the winner and each has the
;; option to play again.

(require 2htdp/universe)
(require 2htdp/image)

;; Assumes we're just demoing this locally.
;; Replace with an IP if you're playing over
;; an actual network.
(define SERVER LOCALHOST)

;; "CONNECTING" -- starting and trying to register.
;; "SORRY"      -- no available space on server.
;; "LOBBY"      -- registered and waiting for an opponent.
;; "ROSHAMBO"   -- waiting for the local client to choose.
;; "ROCK"       -- chose rock, waiting for opponent.
;; "PAPER"      -- chose paper, waiting for opponent.
;; "SCISSORS"   -- chose scissors, waiting for opponent.
;; "WON"        -- You won!
;; "LOST"       -- You lost!
;; "TIE"        -- Tie.

;; For each state we make a ui struct with a message
;; and corresponding color.
(struct ui (txt bg-color))

;; hash table for building ui from world state
(define status (hash
                "CONNECTING" (ui (string-join (list "Connecting to" SERVER "...")) "gold")
                "SORRY"      (ui (string-join (list "Connection rejected by" SERVER ".")) "red")
                "LOBBY"      (ui "Waiting for opponent to join." "pink")
                "ROSHAMBO"   (ui "Choose (r)ock, (p)aper or (s)cissors." "palegreen")
                "WON"        (ui "You won!" "hotpink")
                "LOST"       (ui "You lost." "skyblue")
                "TIE"        (ui "It is a tie." "wheat")
                "QUIT"   (ui "Game over.  Bye!" "gray")))

;; Basic interface geometry.
(define WIDTH 500)
(define HEIGHT 300)
(define MID-X (/ WIDTH 2))
(define PROMPT-Y (* HEIGHT (/ 2 3)))
(define SCENE (empty-scene WIDTH HEIGHT))
(define TEXT-SIZE 28)

(define VALID-CHOICES '("r" "p" "s"))
;; is-valid-choice? :: (choice :: String) -> Boolean
;; Only accept "r" "p" or "s".
(define (is-valid-choice? choice)
  (member choice VALID-CHOICES))

;; get-status :: (w :: String) -> ui
;; Turns the status string into a ui struct.
(define (get-status w)
  (cond [(member w (list "ROCK" "PAPER" "SCISSORS"))
                (ui (string-append "You chose " w) "plum")]
        [else (hash-ref status w)]))

;; is-over? :: (w :: String) -> Boolean
;; Returns true if state is a game outcome.
(define (is-over? w)
  (member w (list "WON" "LOST" "TIE")))

;; draw-gui :: (w :: String) -> Image
;; Turns the status string into a ui struct.
;; Builds the ui window out of that,
;; placing the rematch prompt if the game is over.
(define (draw-gui w)
  (define u (get-status w))
  (define st (overlay (text (ui-txt u) TEXT-SIZE "black")
                      (overlay (rectangle WIDTH HEIGHT "solid" (ui-bg-color u))SCENE)))
  (if (is-over? w)
      (place-image (text"Rematch? (y/n)" TEXT-SIZE "black") MID-X PROMPT-Y st)
      st))

;; key-event :: (w :: String, key :: String) -> Package
;; In "ROSHAMBO" state, take r/p/s input.
;; If the match is over, take y/n to restart or quit.
;; Otherwise, no change.
(define (key-event w key)
  (cond [(and (string=? w "ROSHAMBO") (is-valid-choice? key)) (make-package w key)]
        [(and (is-over? w) (string=? key "y")) (make-package w key)]
        [(and (is-over? w) (string=? key "n")) (make-package w key)]
        [else w]))

;; msg-event :: (w :: String, msg :: String) -> String
;; The new client state is set to the server message.
(define (msg-event w msg)
  msg)

;; main :: (n :: String) -> String
;; Use this and launch-many-worlds to test in DrRacket.
(define (main n)
  (big-bang "CONNECTING"
    (name n)
    (to-draw draw-gui)
    (on-key key-event)
    (register SERVER)
    (on-receive msg-event)))

(big-bang "CONNECTING"
  (to-draw draw-gui)
  (on-key key-event)
  (register SERVER)
  (on-receive msg-event))
  