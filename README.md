# Blockchain

A "naive blockchain" implementation in Elixir inspired by [this JS implementation](https://github.com/lhartikk/naivechain)

**This is a work in progress**

Setting up a 3 nodes blockchain locally:

- node 1: `iex -S mix phx.server` (defaults: `PORT=4000 P2P_PORT=5000`)
- node 2: `PORT=4001 P2P_PORT=5001 iex -S mix phx.server`
- node 3: `PORT=4002 P2P_PORT=5002 iex -S mix phx.server`

Then connect the nodes in the `iex` console, for example:

```elixir
$node2> Blockchain.connect_to_peer(4000) # connect node2 to node1

$note3> Blockchain.connect_to_peer(4001) # connect node3 to node2
```

# TODO

- [ ] allow remote host (only localhost for now)
- [ ] more commands in the Blockchain module
- [ ] http interface using phoenix (umbrella project)
