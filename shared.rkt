#lang racket

(provide is-valid-choice?)

(define VALID-CHOICES '("r" "p" "s"))

;; is-valid-choice? :: (choice :: String) -> Boolean
(define (is-valid-choice? choice)
  (member choice VALID-CHOICES))

