defmodule Logdna do
  @moduledoc false

  @behaviour :gen_event

  defstruct format: nil,
            level: nil,
            metadata: nil,
            ref: nil

  ###
  # Init
  ###

  def init(:logdna) do
    config = Application.get_env(:logger, :logdna)
    {:ok, config}
  end

  ###
  # Configuration
  ###

  def handle_call({:configure, options}, state) do
    {:ok, :ok, state}
  end

  ###
  # Events
  ###

  # def handle_event({level, _gl, _data, state}) when invalid_level?(level, state) do
  #   {:ok, state}
  # end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, %{ref: nil} = state) do
    {:ok, ingest(level, msg, ts, md, state)}
  end

  def handle_event(:flush, state), do: {:ok, state}
  def handle_event(_, state), do: {:ok, state}

  ###
  # Termination
  ###

  def terminate(_reason, _state), do: :ok

  ###
  # Private
  ###

  defp ingest(level, msg, ts, md, state) do
    IO.inspect("hello #{msg}")
    state
  end
end
