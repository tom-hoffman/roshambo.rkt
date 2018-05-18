#lang racket

(provide is-valid-choice?)

(define VALID-CHOICES '("r" "p" "s"))

(define (is-valid-choice? choice)
  (member choice VALID-CHOICES))

