defmodule Token.Crypto do
  @moduledoc """
  Functions to perform cryptographic computations
  """

  def hash(data, algo), do: :crypto.hash(algo, data)

  # simplified version of the bitcoin address, known has the Public Key Hash (no base58)
  # https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses
  def public_key_hash(pk) do
    pk
    |> hash(:sha256)
    |> hash(:ripemd160)
    |> Base.encode16()
  end

  def generate_key_pair do
    {pub, priv} = :crypto.generate_key(:ecdh, :secp256k1)
    {Base.encode16(pub), Base.encode16(priv)}
  end

  def sign(private_key, msg) do
    signature = :crypto.sign(:ecdsa, :sha256, msg, [Base.decode16!(private_key), :secp256k1])
    Base.encode16(signature)
  end

  def verify_signature(public_key, msg, signature) do
    sig = Base.decode16!(signature)
    pk = Base.decode16!(public_key)
    :crypto.verify(:ecdsa, :sha256, msg, sig, [pk, :secp256k1])
  end
end
