# Blockchain.Web

Web interface built with Phoenix to control a node of the blockchain. At the moment there is only a simple JSON API.

## Usage

Setup a blockchain as explained in the [main readme](../../README.md#setup) and skip the "connecting nodes" section. We are doing it using the REST API (note that nodes are idenfied by their HTTP port):

```bash
$> curl -H 'Content-Type: application/json' localhost:4001/api/peers -X POST -d '{ "uri": "localhost:5000"}'  # connect node2 to node1
[{"port":5000,"address":"127.0.0.1"}]

$> curl -H 'Content-Type: application/json' localhost:4002/api/peers -X POST -d '{ "uri": "localhost:5001"}'  # connect node3 to node2
[{"port":5001,"address":"127.0.0.1"}]
```

And finally you can add data to the blockchain:

```bash
# add data to the blockchain (from node1)
$> curl -H 'Content-Type: application/json' localhost:4000/api/blocks -X POST -d '{"data": "block data"}'
# output the current blockchain (note the newly created block won't appear until its mined by one node of the network)

# wait a bit until the block get mined ... then query all the blockchain
# from node1
$> curl -H 'Content-Type: application/json' localhost:4000/api/blocks

# from node2
$> curl -H 'Content-Type: application/json' localhost:4001/api/blocks

# you should see a block containing the newly added data
```

## API

```bash
# create a block (will appear in the blockchain once a miner creates it)
curl -H 'Content-Type: application/json' localhost:4000/api/blocks -X POST -d '{"data": "block data"}'

# show the blockchain
curl -H 'Content-Type: application/json' localhost:4000/api/blocks

# show connected peers
curl -H 'Content-Type: application/json' localhost:4000/api/peers

# connect to a peer
curl -H 'Content-Type: application/json' localhost:4002/api/peers -X POST -d '{ "uri": "localhost:5001"}'
```

## TODOs

This part is a work in progress. There is plenty of things to do such as:
- [ ] user interface
- [ ] support the token system