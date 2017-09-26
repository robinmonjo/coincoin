# Coinstack

[![Build Status](https://travis-ci.org/robinmonjo/blockchain.svg?branch=master)](https://travis-ci.org/robinmonjo/blockchain)

A proof-of-concept cryptocurrency implemented in Elixir.

- use Elixir/OTP
- learn about blockchain and cryptocurrency tech

Lately I heard a lot about:

1. how Elixir is awesome and is the future of complex system / web development
2. how blockchain technology will be the next big thing

So what about building a proof-of-concept of a cryptocurrency written in Elixir ?

As I'm sure about **1**, I still have some doubts about **2** eventough tech behind cryptocurrency is exciting.

This project is an unbrella project that contains 3 apps:

- [`blockchain`](apps/blockchain/README.md): a minimal blockchain
- [`token`](apps/token/README.md): a dumb/incomplete cryptocurrency implemented on top of the blockchain
- [`blockchain_web`](apps/blockchain_web/README.md): a web interface to manage blockchain nodes

To setup a blockchain and store random data in it using the `iex` console checkout the [`blockchain` app](apps/blockchain/README.md). To do the same thing using a REST API, checkout the [`blockchain_web` app](apps/blockchain_web/README.md). And finally to play with a cryptocurrency and use the blockchain as a distributed ledger, checkout the [`token` app](apps/token/README.md).

Issues, suggestions and requests are very welcome 😊


- how the byzantine problem is solved (consensus on non trusted network) article on game theory https://blockgeeks.com/guides/cryptocurrency-game-theory/
- good separation of concerns (a cryptocurrency is not a blockchain ...)
