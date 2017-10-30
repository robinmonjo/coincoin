# Blockchain

A minimal blockchain implementation in Elixir inspired by [this JS implementation](https://github.com/lhartikk/naivechain)

## What is a blockchain ?

> Blockchain is a distributed database that maintains a continuously-growing list of records called blocks secured from tampering and revision. - Wikipedia

Basically, the 2 main properties of a blockchain are:

- decentralisation: there is no central authority
- immutability: data in the blockchain can't be modified. This is made possible by cryptographic hash functions and proof-of-work

This makes the blockchain a perfect fit to store cryptocurrencies transactions. However, it can also be used to store "any" kind of data. This simple implementation focuses on mechanisms behind a blockchain (see the [`token` app](../token/README.md) for a cryptocurrency implementation using this blockchain).

## Features / goals

- as simple as possible
- peer-to-peer communications
- blockchain logic
- proof-of-work
- in memory

## Usage

Setup a 3 nodes blockchain as explained in the [main readme](../../README.md#setup)

You can then add data to the blockchain (from any nodes):

```elixir
Blockchain.add("some data")
```

Data will be broadcasted on the network so nodes can start to mine it (i.e: compute the proof-of-work). Once a node comes up with the proof-of-work, it adds the block in the blockchain and forwards it to other peers.

## Configuring difficulty

**[This doc](docs/difficulty.md)** explains what is the difficulty and how to determine an appropriate **target** for your setup. You can then set this target into the `:blockchain > Blockchain.ProofOfWork > target` config in `config.exs`.

## API

```elixir
# connect to a peer (join the blockchain)
Blockchain.connect("host:port")

# list direct peers
Blockchain.list_peers()

# add data to the blockchain. It will appear once mined
Blockchain.add("some data")

# get all blocks in the chain
Blockchain.blocks()
```

## Resources

- [naive blockchain](https://github.com/lhartikk/naivechain) and its [medium post](https://medium.com/@lhartikk/a-blockchain-in-200-lines-of-code-963cc1cc0e54#.dttbm9afr5)
- [legion blockchain](https://github.com/aviaviavi/legion)
- [proof of work](https://en.bitcoin.it/wiki/Proof_of_work)
