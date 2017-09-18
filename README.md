# Blockchain

[![Build Status](https://travis-ci.org/robinmonjo/blockchain.svg?branch=master)](https://travis-ci.org/robinmonjo/blockchain)

A minimal blockchain implementation in Elixir inspired by [this JS implementation](https://github.com/lhartikk/naivechain)
This is an umbrella project that provides the blockchain core and a REST API built with Phoenix.
It provides peer-to-peer communications, blockchain logic and Proof of Work.

## Usage

Setting up a 3 nodes blockchain locally:

- node 1: `iex -S mix phx.server` (defaults: `PORT=4000 P2P_PORT=5000`)
- node 2: `PORT=4001 P2P_PORT=5001 iex -S mix phx.server`
- node 3: `PORT=4002 P2P_PORT=5002 iex -S mix phx.server`

Then connect the nodes using the REST API, for example:

```bash
curl -H 'Content-Type: application/json' localhost:4001/api/peers -X POST -d '{ "uri": "localhost:5000"}'  # connect node2 to node1

curl -H 'Content-Type: application/json' localhost:4002/api/peers -X POST -d '{ "uri": "localhost:5001"}'  # connect node3 to node2
```

or directly in the `iex` console:

```elixir
$node2> Blockchain.connect("localhost:5000") # connect node2 to node1

$node3> Blockchain.connect("localhost:5001") # connect node3 to node2
```

You can then mine blocks using the REST API or directly in the `iex` console.

## iex

Interaction with the blockchain in the `iex` console:

```elixir
Blockchain.connect("host:port") # connect to a peer
Blockchain.list_peers() # list direct peers
Blockchain.add("some data") # add data to the blockchain. It will appear once mined
Blockchain.blocks() # get all blocks in the chain
```

## REST API

Interaction with the blockchain with the REST API:

```bash
# create a block (will appear in the blockchain once miner create it)
curl -H 'Content-Type: application/json' localhost:4000/api/blocks -X POST -d '{"data": "block data"}'

# show the blockchain
curl -H 'Content-Type: application/json' localhost:4000/api/blocks

# show connected peers
curl -H 'Content-Type: application/json' localhost:4000/api/peers

# connect to a peer
curl -H 'Content-Type: application/json' localhost:4002/api/peers -X POST -d '{ "uri": "localhost:5001"}'
```

## Motivations / next steps

The goal of this project is to understand basic mechanisms behind the blockchain and to use Elixir and OTP. It has been designed to be modular and extensible.

I'm currently working on a "naive" cryptocurrency implementation on top of this blockchain. More to come later

Issues and pull requests are very welcome 😊

## Resources

- [naive blockchain](https://github.com/lhartikk/naivechain) and its [medium post](https://medium.com/@lhartikk/a-blockchain-in-200-lines-of-code-963cc1cc0e54#.dttbm9afr5)
- [legion blockchain](https://github.com/aviaviavi/legion)
- [proof of work](https://en.bitcoin.it/wiki/Proof_of_work)

For future improvements:

- [minimum viable blockchain](https://www.igvita.com/2014/05/05/minimum-viable-block-chain/)
- [minimum viable blockchain Go implementation](https://github.com/izqui/blockchain)

## TODOs

- [ ] test transactions (verify)
- [ ] one README per app with a main README
