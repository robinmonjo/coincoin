# Blockchain

[![Build Status](https://travis-ci.org/robinmonjo/blockchain.svg?branch=master)](https://travis-ci.org/robinmonjo/blockchain)

A minimal cryptocurrency implemented in Elixir. This project has two main goals:

- discover Elixir/OTP
- learn about blockchain and cryptocurrency tech

Lately I heard a lot about:

1. how Elixir is awesome and is the future of complex system / web development
2. how blockchain technology will be the next big thing

So what about building a proof-of-concept of a cryptocurrency written in Elixir ?

As I'm sure about **1**, I still have some doubts about **2** eventough tech behind cryptocurrency is exciting.

In this repo you will find an unbrella project that contains 3 apps:

- `blockchain`: a minimal blockchain 
- `token`: a dumb/incomplete crypto currency implemented on top of the blockchain
- `blockchain_web`: a web interface to manage blockchain nodes

To setup a blockchain and store random data in it using the `iex` console checkout the `blockchain` app. To do the same thing using a REST API, checkout the `blockchain_web` app. And finally to play with a cryptocurrency and use the blockchain as a distributed ledger, checkout the `token` app.

Issues, suggestions and requests are very welcome 😊