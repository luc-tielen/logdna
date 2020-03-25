defmodule Logdna.Log do
  @derive Jason.Encoder
  @enforce_keys [:meta, :line, :level]
  defstruct [
      app: nil,
      env: nil,
      meta: [],
      line: nil,
      level: nil
  ]

  def new({level, line, metadata}) do
    meta = transform_metadata(metadata)

    params = %{
      app: app(),
      env: env(),
      meta: meta,
      line: line,
      level: level
    }

    struct!(__MODULE__, params)
  end
  def new(_invalid_param) do
    raise ArgumentError, "invalid params"
  end

  ###
  # Private
  ###

  defp app do
    :logdna
    |> Application.get_env(:config)
    |> Keyword.get(:app)
  end

  defp env do
    System.get_env("MIX_ENV")
  end

  defp transform_metadata(metadata) do
    Enum.reduce(metadata, %{}, &aggregate/2)
  end

  defp aggregate({key, pid}, aggregation) when key in [:pid, :gl, :mfa, :module] do
    value = inspect(pid)
    Map.put(aggregation, key, value)
  end
  defp aggregate({key, value}, aggregation) do
    Map.put(aggregation, key, value)
  end
end
