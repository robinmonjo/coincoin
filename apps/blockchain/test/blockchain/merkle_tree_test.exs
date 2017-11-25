defmodule Blockchain.MerkleTreeTest do
  use ExUnit.Case, async: true

  alias Blockchain.MerkleTree

  setup do
    #        abdcefghi
    #
    #      abcdefgh     i
    #
    #    abcd     efgh      i
    #
    #  ab     cd    ef   gh    i
    #
    # a   b   c   d   e   f   g   h   i

    {:ok, leaves: ["a", "b", "c", "d", "e", "f", "g", "h", "i"]}
  end

  test "build a tree and access its root", %{leaves: leaves} do
    # this works because BitString implements Blockchain.BlockData
    tree = MerkleTree.build(leaves)
    assert length(tree) == 20

    root = "29D9F10AEFD064E2232A9B585D175366D72163E998D8E97F1AA7E6885664687C"
    assert MerkleTree.root(leaves) == root
  end
end
