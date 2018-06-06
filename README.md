# roshambo.rkt

## A simple Rock, Paper, Scissors server using Racket and 2htdp/universe.

There are not many examples of or explanation of networked games using
Racket, big-bang and universe from the
[universe.rkt teachpack](https://docs.racket-lang.org/teachpack/2htdpuniverse.html).

The best reference overall is the *Realm of Racket* book *plus*
[the annotated source code on github](https://github.com/racket/realm).

Nonetheless, I find the style in *Realm of Racket* a bit difficult to understand so
I needed to write a simple game myself to get the feel of how the worlds (clients)
communicate with the universe (server).  Since there aren't a lot of other easily
findable examples using universe online, I thought I'd post my take as a hopefully
useful example to others.

## Gameplay

For demonstration purposes, you can run the server and clients on one computer with
[Racket](http://racket-lang.org/) and roshambo.rkt installed.  To play on multiple
computers, they all have to have Racket and roshambo.rkt installed, and the clients
have to be configured with the server IP address.  You can run the server and
clients from DrRacket or the command line with:

```
racket server.py
racket client.py
```

You can also launch multiple worlds from the interactions window in DrRacket:
```
(launch-many-worlds (main "a") (main "b") (main "c"))
```
The game itself should be self-explanatory if you've played Rock Paper Scissors, aka
Roshambo.

## A few notes on using universe and worlds.

Assuming you've already done world programming using big-bang, the main thing
you need to get used to in universe programming is passing messages and bundles
between the client and server, and keeping straight the idea that the state of
the server and the state of the client are completely different.

In this case, the state of each client is a single string indicating its state.
Each time the client recieves a message from the server.  The client's state is
mostly directly set by messages from the server.  That is, the client's
**on-receive** handler simply sets the new client state to the value of the
received message.

Possible client states are:
```racket
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
```


