defmodule Blockchain.MiningTest do
  use ExUnit.Case, async: false

  alias Blockchain.{MiningPool, Block}

  test "handle_call mine_data add data to pool and start mining" do
    data = "foo"
    {:reply, response, new_state} = MiningPool.handle_call({:mine, data}, nil, {[], {}})
    assert response == :ok
    {pool, {ref, pid, block}} = new_state
    Process.monitor(pid)
    assert pool == [data]
    assert block.data == data
    receive do
      mess ->
        assert {:DOWN, ^ref, :process, ^pid, :normal} = mess
    end
  end

  test "handle_call mine_data do not change state if data already in pool" do
    data = "foo"
    state = {[data], {}}
    {:reply, response, new_state} = MiningPool.handle_call({:mine, data}, nil, state)
    assert response == {:error, :already_in_pool}
    assert new_state == state
  end

  test "handle_call mine_data only add to pool if mining in progress" do
    data = "foo"
    pool = ["bar"]
    mining = {"some_ref", "some_pid", "block_candidate"}
    {:reply, response, new_state} = MiningPool.handle_call({:mine, data}, nil, {pool, mining})
    assert response == :ok
    assert new_state == {pool ++ [data], mining}
  end

  test "handle_call block_mined remove mined block data from the pool" do
    data = "foo"
    pool = ["bar", data]
    b = Block.generate_next_block(data)
    {:reply, response, new_state} = MiningPool.handle_call({:block_mined, b}, nil, {pool, {}})
    assert response == :ok
    {pool, {}} = new_state
    assert pool == ["bar"]
  end

  test "handle_call block_mined stop block mining if block number matches" do
    data = "foobar"
    {:reply, :ok, {[^data], {ref, pid, block} = mining} = state} = MiningPool.handle_call({:mine, data}, nil, {[], {}})
    mref = Process.monitor(pid)
    {:reply, response, new_state} = MiningPool.handle_call({:block_mined, block}, nil, state)
    assert response == :ok
    assert new_state == {[], mining}
    for r <- [mref, ref] do
      receive do
        mess ->
          assert {:DOWN, ^r, :process, ^pid, :killed} = mess
      end
    end
  end

  test "handle_info DOWN clean up mining state" do
    data = "foobar"
    {:reply, :ok, {[^data], {ref, pid, _block}} = state} = MiningPool.handle_call({:mine, data}, nil, {[], {}})
    {:noreply, {_pool, mining}} = MiningPool.handle_info({:DOWN, ref, :process, pid, :normal}, state)
    assert mining == {}
  end

  test "handle_info DOWN start mining next block in pool" do
    data1 = "foobar1"
    data2 = "foobar2"
    {:reply, :ok, {[^data1], {ref, pid, _block}} = state} = MiningPool.handle_call({:mine, data1}, nil, {[], {}})
    {:reply, :ok, {[^data1, ^data2], {_ref, _pid, _block}} = state} = MiningPool.handle_call({:mine, data2}, nil, state)

    {:noreply, {_pool, mining}} = MiningPool.handle_info({:DOWN, ref, :process, pid, :normal}, state)
    assert {_ref, _pid, %Block{data: ^data2}} = mining
  end
end
