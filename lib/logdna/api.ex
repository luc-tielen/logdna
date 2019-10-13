defmodule Logdna.API do
  @base_url "https://logs.logdna.com/logs/ingest"

  def ingest(lines) when is_list(lines) do
    %{ lines: lines }
    |> Jason.encode!()
    |> trigger_ingestion()
  end

  ###
  # Private
  ###

  defp headers() do
    ["Content-Type": "application/json; charset=UTF-8"]
  end

  defp add_authentication(url) do
    config = Application.get_env(:logdna, :config)

    hostname = Keyword.get(config, :hostname)
    ingestion_key = Keyword.get(config, :ingestion_key)

    "#{url}?apikey=#{ingestion_key}&hostname=#{hostname}"
  end

  defp trigger_ingestion(data) do
    headers = headers()

    response =
      @base_url
      |> add_authentication()
      |> HTTPoison.post(data, headers)
    
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}
      {:ok, %HTTPoison.Response{status_code: _error_code, body: body}} ->
        {:error, Jason.decode!(body)}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end