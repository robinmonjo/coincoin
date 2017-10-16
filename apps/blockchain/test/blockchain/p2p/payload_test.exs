defmodule Blockchain.P2P.PayloadTest do
  use ExUnit.Case, async: true

  alias Blockchain.{P2P.Payload}

  defmodule TestData do
    defstruct [:content, :hash, :timestamp]
  end

  test "encode and decode typed data on struct" do
    data = %TestData{
      content: "foo",
      hash: "1234DA3553676AC53CC20564D8E956D03A08F7747823439FDE74ABF8E7EADF60",
      timestamp: System.system_time(:second)
    }

    encoded_payload =
      data
      |> Payload.mining_request()
      |> Payload.encode!()

    assert {:ok, payload} = Payload.decode(encoded_payload)
    assert payload.data == data
  end

  test "encode and decode typed data on basic types" do
    data = [42, "foobar"]

    encoded_payload =
      data
      |> Payload.mining_request()
      |> Payload.encode!()

    assert {:ok, payload} = Payload.decode(encoded_payload)
    assert payload.data == data
  end
end
