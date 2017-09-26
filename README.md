# coinstack

[![Build Status](https://travis-ci.org/robinmonjo/blockchain.svg?branch=master)](https://travis-ci.org/robinmonjo/blockchain)

<img align="right" src="logo.png">

`coinstack` is a cryptocurrency proof-of-concept implemented in Elixir. It's an umbrella project that focuses on the 2 main components of (most of) the existing cryptocurrencies: the **blockchain** and **digital transactions**.

It's goal is to be as simple as possible but complete enough to technically understand what's going on behind Bitcoin or Ethereum for example. It's also a way do dive more into Elixir and OTP.

## Why coinstack ?

Lately I heard a lot about:

1. how Elixir is awesome and is the future of complex system / web development
2. how blockchain technology will be the next big thing

So what about building a cryptocurrency proof-of-concept in Elixir ?

As I'm sure about **1**, I still have some doubts about **2** eventough technologies behind cryptocurrency are exciting.

## What's in this repo ?

This is an unbrella project that contains 3 apps:

- [`blockchain`](apps/blockchain/README.md): a minimal blockchain
- [`token`](apps/token/README.md): a minimal cryptocurrency implemented on top of the blockchain
- [`blockchain_web`](apps/blockchain_web/README.md): a web interface to manage nodes of the blockchain

To setup a blockchain and store random data in it using the `iex` console checkout the [`blockchain` app](apps/blockchain/README.md). To do the same using a REST API, checkout the [`blockchain_web` app](apps/blockchain_web/README.md). And finally to play with a cryptocurrency and use the blockchain as a distributed ledger, checkout the [`token` app](apps/token/README.md).

## Final words

Issues, suggestions and requests are very welcome 😊
