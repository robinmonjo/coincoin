# Blockchain

A "naive blockchain" implementation in Elixir inspired by [this JS implementation](https://github.com/lhartikk/naivechain)

**This is a work in progress**

Setting up a 3 nodes blockchain locally:

- node 1: `iex -S mix phx.server` (defaults: `PORT=4000 P2P_PORT=5000`)
- node 2: `PORT=4001 P2P_PORT=5001 iex -S mix phx.server`
- node 3: `PORT=4002 P2P_PORT=5002 iex -S mix phx.server`

Then connect the nodes using the API, for example:

```bash
curl -H 'Content-Type: application/json' localhost:4001/api/peers -X POST -d '{ "port": 5000}'  # connect node2 to node1

curl -H 'Content-Type: application/json' localhost:4002/api/peers -X POST -d '{ "port": 5001}'  # connect node3 to node2
```

## API:

```bash
# create a block
curl -H 'Content-Type: application/json' localhost:4000/api/blocks -X POST -d '{"data": "block data"}'

# show the blockchain
curl -H 'Content-Type: application/json' localhost:4000/api/blocks

# show connected peers
curl -H 'Content-Type: application/json' localhost:4000/api/peers

# connect to a peer
curl -H 'Content-Type: application/json' localhost:4002/api/peers -X POST -d '{ "port": 5001}'
```

# TODO

- [ ] allow remote host (only localhost for now)
- [ ] type spec and dyalizer
