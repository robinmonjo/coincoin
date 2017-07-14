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
      address: generate_address(pub),
      public_key: pub,
      private_key: priv
    }
  end

  defp generate_key_pair do
    :crypto.generate_key(:ecdh, :secp256k1)
  end

  # address is a simplified version of the bitcoin address:
  # https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses
  defp generate_address(pub) do
    pub
    |> Crypto.hash(:sha256)
    |> Crypto.hash(:ripemd160)
    |> Base.encode16()
  end

  # return hex signature
  def sign(%Wallet{} = wallet, msg) do
    signature = :crypto.sign(:ecdsa, :sha256, msg, [wallet.private_key, :secp256k1])
    Base.encode16(signature)
  end

  def verify(%Wallet{} = wallet, msg, signature) do
    :crypto.verify(:ecdsa, :sha256, msg, Base.decode16!(signature), [wallet.public_key, :secp256k1])
  end
end
