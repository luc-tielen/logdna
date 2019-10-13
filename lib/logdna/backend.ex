defmodule Logdna.Backend do
  @moduledoc false
  @behaviour :gen_event

  defstruct level: nil, format: nil, metadata: [], buffer: nil

  alias Logdna.{Log, Buffer}

  ###
  # Init
  ###

  def init(__MODULE__) do
    state =
      :logger
      |> Application.get_env(:logdna)
      |> init_state()

    {:ok, state}
  end

  ###
  # Configuration
  ###

  def handle_call({:configure, options}, _state) do
    config =
      :logger
      |> Application.get_env(:logdna)
      |> Keyword.merge(options)

    Application.put_env(:logger, :logdna, config)

    state = init_state(config)
    {:ok, :ok, state}
  end

  ###
  # Events
  ###

  def handle_event({_level, gl, {Logger, _, _, _}}, state) when node(gl) != node(), do: {:ok, state}

  def handle_event({level, _gl, {Logger, msg, _ts, md}}, %__MODULE__{buffer: current_buffer} = state) do
    log = Log.new({level, msg, md})
    buffer = Buffer.push(current_buffer, log)

    buffer_maxed? = Buffer.maxed?(buffer)
    configured_level? = Logger.compare_levels(level, state.level) == :gt

    cond do
      configured_level? ->
        {:ok, state}
      buffer_maxed? ->
        flushed_buffer = flush(buffer)
        {:ok, %__MODULE__{state | buffer: flushed_buffer}}
      true ->
        {:ok, %__MODULE__{state | buffer: buffer}}
    end
  end

  def handle_event(:flush, %__MODULE__{buffer: current_buffer} = state) do
    buffer = flush(current_buffer)
    {:ok, %__MODULE__{state | buffer: buffer}}
  end

  def handle_event(_unknown, state), do: {:ok, state}

  def handle_info(_term, state) do
    {:ok, state}
  end

  ###
  # Termination
  ###

  def terminate(_reason, _state), do: :ok

  ###
  # Private
  ###

  defp init_state(config) do
    level = Keyword.get(config, :level)
    metadata = Keyword.get(config, :metadata, [])
    max_buffer = Keyword.get(config, :max_buffer, 10)
    format = Logger.Formatter.compile(Keyword.get(config, :format))

    %__MODULE__{
      level: level,
      format: format,
      metadata: metadata,
      buffer: Buffer.new(max_buffer)
    }
  end

  defp flush(%Buffer{data: data, max_size: max_size} = buffer) do
    response = Logdna.API.ingest(data)

    case response do
      {:ok, _response} ->
        Buffer.new(max_size)
      {:error, _error} ->
        buffer
    end
  end
end
