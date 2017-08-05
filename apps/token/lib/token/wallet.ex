defmodule Token.Wallet do

  alias Token.{Wallet, Crypto}

  defstruct [
    :address,
    :public_key,
    :private_key
  ]

  def generate_wallet do
    {pub, priv} = generate_key_pair()
    %Wallet{
      address: Crypto.public_key_hash(pub),
      public_key: pub,
      private_key: priv
    }
  end

  defp generate_key_pair do
    {pub, priv} = :crypto.generate_key(:ecdh, :secp256k1)
    {Base.encode16(pub), Base.encode16(priv)}
  end

  # return hex signature
  def sign(msg, %Wallet{} = wallet) do
    Crypto.sign(wallet.private_key, msg)
  end

  def verify(msg, signature, %Wallet{} = wallet) do
    Crypto.verify_signature(wallet.public_key, msg, signature)
  end
end


# wallet can search all UTXO (unspent transaction output) for a given address in the blockchain
# need to have an iterator function on the chain
# wallet find all UTXO to satisfy an exact or superior amount of what must be spent. After there is the change
#
