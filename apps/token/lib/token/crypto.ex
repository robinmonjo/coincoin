defmodule Token.Crypto do
  @moduledoc """
  Functions to perform cryptographic computations
  """

  @type hash_algorithms :: :md5 | :ripemd160 | :sha | :sha224 | :sha256 | :sha384 | :sha512

  @spec hash(iodata, hash_algorithms) :: String.t()
  def hash(data, algo), do: :crypto.hash(algo, data)

  # simplified version of the bitcoin address, known has the Public Key Hash (no base58)
  # https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses
  @spec public_key_hash(String.t()) :: String.t()
  def public_key_hash(pk) do
    pk
    |> hash(:sha256)
    |> hash(:ripemd160)
    |> Base.encode16()
  end

  @spec generate_key_pair() :: {String.t(), String.t()}
  def generate_key_pair do
    {pub, priv} = :crypto.generate_key(:ecdh, :secp256k1)
    {Base.encode16(pub), Base.encode16(priv)}
  end

  @spec sign(String.t(), iodata) :: String.t()
  def sign(private_key, msg) do
    signature = :crypto.sign(:ecdsa, :sha256, msg, [Base.decode16!(private_key), :secp256k1])
    Base.encode16(signature)
  end

  @spec verify_signature(String.t(), String.t(), String.t()) :: boolean
  def verify_signature(public_key, msg, signature) do
    sig = Base.decode16!(signature)
    pk = Base.decode16!(public_key)
    :crypto.verify(:ecdsa, :sha256, msg, sig, [pk, :secp256k1])
  end
end
