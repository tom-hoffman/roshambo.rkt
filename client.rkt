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
;; "WON"        
;; "LOST"       
;; "TIE"        

(struct ui (txt bg-color))
(define status (hash
                "CONNECTING" (ui (string-join (list "Connecting to" SERVER "...")) "gold")
                "SORRY"      (ui (string-join (list "Connection rejected by" SERVER ".")) "red")
                "LOBBY"      (ui "Waiting for opponent to join." "pink")
                "ROSHAMBO"   (ui "Choose (r)ock, (p)aper or (s)cissors." "palegreen")))
                
(define WIDTH 500)
(define HEIGHT 300)
(define SCENE (empty-scene WIDTH HEIGHT))
(define TEXT-SIZE 28)

(define (draw-gui w)
  (define u (hash-ref status w))
  (overlay (text (ui-txt u) TEXT-SIZE "black")
           (overlay (rectangle WIDTH HEIGHT "solid" (ui-bg-color u)) SCENE)))

(define (key-event w key)
  w)

(define (msg-event w msg)
  msg)
  
(big-bang "CONNECTING"
  (to-draw draw-gui)
  (on-key key-event)
  (register SERVER)
  (on-receive msg-event))
  