defmodule Logdna.APITest do
  use ExUnit.Case

  import Mock

  @http_error {:error, %HTTPoison.Error{reason: :http_error}}

  @ok_body Jason.encode!(%{ok: "all_good"})
  @ok_response {:ok, %HTTPoison.Response{status_code: 200, body: @ok_body}}

  @not_found_body Jason.encode!(%{ok: "not_found"})
  @not_found_response {:ok, %HTTPoison.Response{status_code: 404, body: @not_found_body}}

  setup_all do
    pid = self()

    logs_data = [
      {:info, "log1", [pid: pid]},
      {:info, "log2", [pid: pid]},
      {:info, "log3", [pid: pid]}
    ]

    logs = Enum.map(logs_data, &Logdna.Log.new/1)
    {:ok, %{logs: logs}}
  end

  test "ingests a valid list of logs", %{logs: logs} do
    with_mock HTTPoison, [post: fn(_url, _body, _headers) -> @ok_response end] do
      {:ok, response} = Logdna.API.ingest(logs)
      assert response == %{"ok" => "all_good"}
    end
  end

  test "errors when http request fails with 404 status code", %{logs: logs} do
    with_mock HTTPoison, [post: fn(_url, _body, _headers) -> @not_found_response end] do
      {:error, response} = Logdna.API.ingest(logs)
      assert response == %{"ok" => "not_found"}
    end
  end

  test "errors when http request fails", %{logs: logs} do
    with_mock HTTPoison, [post: fn(_url, _body, _headers) -> @http_error end] do
      {:error, response} = Logdna.API.ingest(logs)
      assert response == :http_error
    end
  end

  test "errors when creating a new log with invalid data" do
    assert_raise FunctionClauseError, fn ->
      Logdna.API.ingest(:logs)
    end
  end
end