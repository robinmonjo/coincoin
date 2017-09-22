# Blockchain

A minimal blockchain implementation in Elixir inspired by [this JS implementation](https://github.com/lhartikk/naivechain)

## Features / goals

- as simple as possible
- peer-to-peer communications
- blockchain logic
- proof-of-work
- in memory

## Usage

Setting up a 3 nodes blockchain locally:

- node1: `iex -S mix` (default: `P2P_PORT=5000`)
- node2: `P2P_PORT=5001 iex -S mix`
- node3: `P2P_PORT=5002 iex -S mix`

Then connect the nodes to create a P2P network:

```elixir
$node2> Blockchain.connect(5000) # connect node2 to node1

$node3> Blockchain.connect(5001) # connect node3 to node2
```

This will setup a simple network: 

```
node1 <--> node2 <--> node3
```

You can then add data to the blockchain (from any nodes):

```elixir
Blockchain.add("some data")
```

Data will be broadcasted on the network so nodes can start to mine it (i.e: compute the proof-of-work). Once a node comes up with the proof-of-work,
it will add the block in the blockchain and forward it to other peers. Proof-of-work difficulty can be modified in `config.exs`

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

# directly mine a block, without letting other nodes a chance to mine the block (mostly used for testing)
Blockchain.mine("some data")    
```

## Resources

- [naive blockchain](https://github.com/lhartikk/naivechain) and its [medium post](https://medium.com/@lhartikk/a-blockchain-in-200-lines-of-code-963cc1cc0e54#.dttbm9afr5)
- [legion blockchain](https://github.com/aviaviavi/legion)
- [proof of work](https://en.bitcoin.it/wiki/Proof_of_work)
