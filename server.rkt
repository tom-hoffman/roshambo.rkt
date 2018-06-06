#lang racket

;; Roshambo server.
;; Networked rock, paper, scissors.
;;
;; After two clients register, they can choose
;; (r)ock, (p)aper or (s)cissors at their leisure.
;; The server returns the winner and each has the
;; option to play again.

(require 2htdp/universe)
(require test-engine/racket-tests)

;; The universe state is a pair (list) of players.
;; A player has an iWorld and a string indicating
;; their choice -- "r", "p", "s" or "" (no choice).
(struct player (iw choice) #:transparent) 

(define expand-choice (hash "r" "ROCK"
                            "p" "PAPER"
                            "s" "SCISSORS"))

(define VALID-CHOICES '("r" "p" "s"))
;; is-valid-choice? :: (choice :: String) -> Boolean
;; Only accept "r" "p" or "s".
(define (is-valid-choice? choice)
  (member choice VALID-CHOICES))

;; start-playing? :: (l :: List) -> Boolean
;; If we have two players we can start.
(define (start-playing? l)
  (= (length l) 2))

;; played? :: (Player) -> List/Boolean
;; Has this player chosen already?
(define (played? p)
  (is-valid-choice? (player-choice p)))

;; both-played :: (l :: List -> Boolean
;; Have both players chosen?
(define (both-played? l)
  (= (length (filter played? l)) 2))

;; mail-everyone :: (l :: List<Player>, msg :: String) -> List<Mail>
;; Prepares the same message to both players.
(define (mail-everyone l msg)
  (map (lambda (i)
         (make-mail (player-iw i) msg))
       l))

;; connect :: (l :: List<Player>, client :: IWorld) -> Bundle
;; Checks the current number of players and adds one if appropriate.
(define (connect l client)
  (define players (length l))
  (define new-l (cons (player client "") l))
  (cond [(= players 0)
         (make-bundle
          new-l
          (list (make-mail client "LOBBY"))
          '())]
        [(= players 1)
         (make-bundle
          new-l
          (mail-everyone new-l "ROSHAMBO")
          '())]
        [(> players 1) 
         (make-bundle
          l
          (list (make-mail client "SORRY"))
          (list client))]))

;; update-state :: (l :: List<Player, client :: IWorld, msg :: String -> State
;; Checks to see if the choice is valid,
;; then finds the right player based on the iWorld and sets the choice
;; if a choice has not already been made.
(define (update-state l client msg)
  (if (is-valid-choice? msg)
      (map (lambda (i)
             (if (and (iworld=? (player-iw i) client)
                      (string=? (player-choice i) ""))
                 (player client msg)
                 i))
           l)
      l))

;; bundle-results :: (winner :: Player, loser :: Player) -> Bundle
;; Prepare remove the players and announce the winner and loser.  
(define (bundle-results winner loser)
  (make-bundle
   '()
   (list (make-mail (player-iw winner) "WON")
         (make-mail (player-iw loser) "LOST"))
   empty))

;; resolve-match :: (l :: List<Player>) -> Bundle
;; Figure out who won.
(define (resolve-match l)
  (define p0 (list-ref l 0))
  (define p0-choice (player-choice p0))
  (define p1 (list-ref l 1))
  (define p1-choice (player-choice p1))
  (cond [(and (string=? p1-choice "r") (string=? p0-choice "s")) (bundle-results p1 p0)]
        [(and (string=? p1-choice "r") (string=? p0-choice "p")) (bundle-results p0 p1)]
        [(and (string=? p1-choice "p") (string=? p0-choice "r")) (bundle-results p1 p0)]
        [(and (string=? p1-choice "p") (string=? p0-choice "s")) (bundle-results p0 p1)]
        [(and (string=? p1-choice "s") (string=? p0-choice "p")) (bundle-results p1 p0)]
        [(and (string=? p1-choice "s") (string=? p0-choice "r")) (bundle-results p0 p1)]
        [else (make-bundle
               '()
               (mail-everyone l "TIE")
               empty)]))


;; handle-msg :: (l :: List<Player>, client :: IWorld, msg :: String) -> Bundle
;; Processes messages from clients once game has started.

(define (handle-msg l client msg)
  (define new-state (update-state l client msg))
  (cond
    ; if both have chosen, find the winner
    [(both-played? new-state) (resolve-match new-state)]
    ; if this is the first player, record his choice and mail it back to him.
    [(start-playing? l) (make-bundle
                         new-state
                         (list (make-mail client (hash-ref expand-choice msg)))
                         empty)]
    ; these "y" and "n" messages come in reply to the restart prompt
    [(and (not(start-playing? l)) (string=? msg "y")) (connect l client)]
    [(and (not(start-playing? l)) (string=? msg "n")) (make-bundle
                                                       l
                                                       (list (make-mail client "QUIT"))
                                                       empty)]
    ; or do nothing
    [else (make-bundle
           l
           empty
           empty)]))

      
(universe '()
          (on-new connect)
          (on-msg handle-msg))


;; Tests.

(check-expect (start-playing? (list (player iworld2 "") (player iworld1 "")))
              #t)
(check-expect (start-playing? (list (player iworld2 "")))
              #f)

(check-expect (played? (player iworld1 "")) #f)
(check-expect (played? (player iworld1 "r")) '("r" "p" "s"))

(check-expect (both-played? (list (player iworld2 "") (player iworld1 "")))
              #f)
(check-expect (both-played? (list (player iworld2 "r") (player iworld1 "")))
              #f)
(check-expect (both-played? (list (player iworld2 "r") (player iworld1 "j")))
              #f)
(check-expect (both-played? (list (player iworld2 "r") (player iworld1 "s")))
              #t)

(check-expect (update-state (list (player iworld2 "") (player iworld1 "")) iworld1 "r")
              (list (player iworld2 "") (player iworld1 "r")))
(check-expect (update-state (list (player iworld2 "s") (player iworld1 "")) iworld1 "r")
              (list (player iworld2 "s") (player iworld1 "r")))
(check-expect (update-state (list (player iworld2 "")) iworld1 "r")
              (list (player iworld2 "")))

(check-expect (resolve-match (list (player iworld2 "r") (player iworld1 "s")))
                             (bundle-results (player iworld2 "r") (player iworld1 "s")))
(check-expect (resolve-match (list (player iworld2 "r") (player iworld1 "p")))
                             (bundle-results (player iworld1 "p") (player iworld2 "r")))
(check-expect (resolve-match (list (player iworld2 "r") (player iworld1 "r")))
                             (make-bundle
                              '()
                              (list (make-mail iworld2 "TIE")
                                    (make-mail iworld1 "TIE"))
                              empty))

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

(check-expect (handle-msg (list (player iworld1 "") (player iworld2 "")) iworld2 "p")
              (make-bundle
               (update-state (list (player iworld1 "") (player iworld2 "")) iworld2 "p")
               (list (make-mail iworld2 "PAPER"))
               empty))
(check-expect (handle-msg (list (player iworld1 "")) iworld2 "p")
                          (make-bundle 
                           (list (player iworld1 ""))
                           empty
                           empty))

(test)