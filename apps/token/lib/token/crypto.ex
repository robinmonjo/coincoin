defmodule Token.Crypto do
  @moduledoc "wrappers around erlang's :crypto for easy piping."

  def hash(data, algo), do: :crypto.hash(algo, data)
end
