defmodule Blockchain.MerkleTree do
  @moduledoc "Module to work with merkle trees (not used yet)"

  alias Blockchain.{Crypto, BlockData}

  @spec build([BlockData.t()]) :: [String.t()]
  def build(chunks) do
    chunks
    |> Enum.map(&BlockData.hash(&1))
    |> build_tree()
  end

  @spec root([BlockData.t()]) :: String.t()
  def root(chunks) do
    chunks
    |> build()
    |> Enum.at(0)
  end

  @spec build_tree([String.t()], [String.t()]) :: [String.t()]
  defp build_tree(leaves, heap \\ [])
  defp build_tree([root], heap), do: [root | heap]

  defp build_tree(leaves, heap) do
    leaves
    |> Enum.chunk_every(2)
    |> Enum.reduce([], &(&2 ++ [concatenate_and_hash(&1)]))
    |> build_tree(leaves ++ heap)
  end

  @spec concatenate_and_hash([String.t()]) :: String.t()
  defp concatenate_and_hash([h]), do: concatenate_and_hash([h, ""])

  defp concatenate_and_hash([h1, h2]) do
    "#{h1}#{h2}"
    |> Crypto.hash(:sha256)
    |> Base.encode16()
  end
end
