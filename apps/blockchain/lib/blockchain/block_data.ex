# every data that are incorporated in the blockchain must implement this protocol
defprotocol Blockchain.BlockData do
  @spec hash(t) :: String.t()
  def hash(data)

  @spec verify(t, [Blockchain.Block.t()]) :: :ok | {:error, String.t()}
  def verify(data, chain)
end

# implement the protocol for bit string
defimpl Blockchain.BlockData, for: BitString do
  def hash(string) do
    string
    |> Blockchain.Crypto.hash(:sha256)
    |> Base.encode16()
  end

  def verify(_string, _chain), do: :ok
end
