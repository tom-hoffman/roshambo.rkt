# roshambo.rkt

## A simple Rock, Paper, Scissors server using Racket and 2htdp/universe.

There are not many examples on the internet of networked games using
Racket, big-bang and universe from the
[universe.rkt teachpack](https://docs.racket-lang.org/teachpack/2htdpuniverse.html).

The best reference overall is the *Realm of Racket* book *plus*
[the annotated source code on github](https://github.com/racket/realm).

I wrote a simple game to get the feel of how the worlds (clients)
communicate with the universe (server).  Since there aren't a lot of other easily
findable examples using universe online, I thought I'd post my take as a hopefully
useful example to others.  This is a first try, so the style and execution
is probably not ideal, but hopefully helpful to another beginner.

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

You can also run a server and launch multiple worlds from the interactions window in DrRacket:
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
The client's state is
mostly directly set by messages from the server.  That is, the client's
**on-receive** handler simply sets the new client state to the value of the
received message.

Possible client states are:
```racket
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
```

When a client takes a key input it checks to see if the input is relevant
and if so, sends the server a package made up of the client world state and
a message containing the key pressed.

The server then processes the package and creates a bundle containing its
new state, a list of mail messages to send to the clients and a list of
any clients to drop.  I kept each of these bundle constructors split across
three lines which helps to understand their three parts.

The universe state is a pair (list) of players.  A player is made up of an iWorld
and a string indicating their choice -- "r", "p", "s", "y", "n" or "" (no choice).

Again the message sent to the client is a string containing its new state.

Hope this helps!

