defmodule Logdna.BufferTest do
  use ExUnit.Case

  setup_all do
    log = Logdna.Log.new({:info, "testing", [pid: self()]})
    {:ok, %{log: log}}
  end

  test "creates a new buffer with valid data" do
    buffer = Logdna.Buffer.new(3)

    assert buffer.size == 0
    assert buffer.data == []
    assert buffer.max_size == 3
  end

  test "errors when creating a new buffer with invalid data" do
    assert_raise ArgumentError, fn ->
      Logdna.Buffer.new(0)
    end

    assert_raise ArgumentError, fn ->
      Logdna.Buffer.new("0")
    end
  end

  test "pushes valid log to buffer", %{log: log} do
    buffer =
      Logdna.Buffer.new(3)
      |> Logdna.Buffer.push(log)
      |> Logdna.Buffer.push(log)
    
    assert buffer.size == 2
    assert buffer.max_size == 3
    assert buffer.data == [log, log]
    refute Logdna.Buffer.maxed?(buffer)
  end

  test "errors when pushing an invalid log to buffer" do
    assert_raise ArgumentError, fn ->
      3 |> Logdna.Buffer.new() |> Logdna.Buffer.push(nil)
    end
  end

  test "returns true if buffer is maxed", %{log: log} do
    buffer =
      Logdna.Buffer.new(3)
      |> Logdna.Buffer.push(log)
      |> Logdna.Buffer.push(log)
      |> Logdna.Buffer.push(log)
    
    assert buffer.size == 3
    assert buffer.max_size == 3
    assert Logdna.Buffer.maxed?(buffer)
  end
end