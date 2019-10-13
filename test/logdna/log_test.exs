defmodule Logdna.LogTest do
  use ExUnit.Case

  test "creates a new log with valid data" do
    pid = self()
    printable_pid = inspect(pid)

    log = Logdna.Log.new({:error, "error", [pid: pid]})

    assert log.meta == %{pid: printable_pid}
    assert log.level == :error
    assert log.line == "error"
    assert log.env == "test"
    assert log.app == "app"
  end

  test "errors when creating a new log with invalid data" do
    assert_raise ArgumentError, fn ->
      Logdna.Log.new("log")
    end
  end
end