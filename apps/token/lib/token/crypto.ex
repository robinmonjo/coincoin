defmodule Token.Crypto do
  @moduledoc "Crypto module"

  def hash(data, algo), do: :crypto.hash(algo, data)

  # simplified version of the bitcoin address, known has the Public Key Hash (no base58)
  # https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses
  def public_key_hash(pk) do
    pk
    |> hash(:sha256)
    |> hash(:ripemd160)
    |> Base.encode16()
  end

  def sign(private_key, msg) do
    signature = :crypto.sign(:ecdsa, :sha256, msg, [Base.decode16!(private_key), :secp256k1])
    Base.encode16(signature)
  end

  def verify_signature(public_key, msg, signature) do
    :crypto.verify(:ecdsa, :sha256, msg, Base.decode16!(signature), [Base.decode16!(public_key), :secp256k1])
  end

end
