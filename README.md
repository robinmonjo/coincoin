# coincoin

[![Build Status](https://travis-ci.org/robinmonjo/coincoin.svg?branch=master)](https://travis-ci.org/robinmonjo/blockchain)

<img align="right" src="logo.png" width="128px">

`coincoin` is a cryptocurrency proof-of-concept implemented in Elixir. It's an umbrella project that focuses on the 2 main components of (most of) the existing cryptocurrencies: the **blockchain** and **digital transactions**.

It's goal is to be **as simple as possible** but complete enough to technically understand what's going on behind Bitcoin or Ethereum for example. It's also a way do dive more into Elixir and OTP.

## Setup

Blockchains are P2P softwares. To start using `coincoin`, we need to setup multiple nodes and connect them together.

You need [Elixir](https://elixir-lang.org/install.html) installed. Clone this repository and go to the root of the project.

Then pull the dependencies using `mix deps.get`

To setup a 3 nodes blockchain, spawn 3 tabs in your terminal (node1, node2 and node3) and run:

- node1: `iex -S mix phx.server` (defaults: `PORT=4000 P2P_PORT=5000`)
- node2: `PORT=4001 P2P_PORT=5001 iex -S mix phx.server`
- node3: `PORT=4002 P2P_PORT=5002 iex -S mix phx.server`

Then connect the nodes to create a P2P network:

```elixir
$node2> Blockchain.connect("localhost:5000") # connect node2 to node1

$node3> Blockchain.connect("localhost:5001") # connect node3 to node2
```

This will setup a simple network:

```
node1 <--> node2 <--> node3
```

You can also use the `robinmonjo/coincoin` docker image available on the [docker hub](https://hub.docker.com/r/robinmonjo/coincoin/):

```bash
docker run -it robinmonjo/coincoin
```

If you use Docker, in the `Blockchain.connect/1` call make sure to pass your container IP address and that this address is reachable.

**Notes:**

- if you don't want to interact with the REST API, you can skip the `PORT` env var and use `iex -S mix` instead of `iex -S mix phx.server`
- `Blockchain.connect(5000)` is equivalent to `Blockchain.connect("localhost:5000")`
- for releases use `make release`

## Usage

When started, `coincoin` will start 3 apps:

- [`blockchain`](apps/blockchain/README.md): a minimal blockchain
- [`token`](apps/token/README.md): a minimal cryptocurrency implemented on top of the blockchain
- [`blockchain_web`](apps/blockchain_web/README.md): a web interface to manage nodes of the blockchain

To manipulate the blockchain and store random data in it using the `iex` console checkout the [`blockchain` app](apps/blockchain/README.md). To do the same using a REST API, checkout the [`blockchain_web` app](apps/blockchain_web/README.md). And finally to play with a cryptocurrency and use the blockchain as a distributed ledger, checkout the [`token` app](apps/token/README.md).

## Why coincoin ?

Lately I heard a lot about:

1. how Elixir is awesome and is the future of complex system / web development
2. how blockchain technology will be the next big thing

So what about building a cryptocurrency proof-of-concept in Elixir ?

As I'm sure about **1**, I still have some doubts about **2** eventough technologies behind cryptocurrencies are exciting.

> Also "coin-coin" in french is the noise of a duck (hence Scrooge McDuck)

## Final words

Issues, suggestions and pull requests are very welcome 😊
