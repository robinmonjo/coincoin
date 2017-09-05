# every kind of data that are incorporated in the blockchain must implement this protocol
defprotocol Blockchain.Data do
  def hash(data)
  def verify(verify)
end
