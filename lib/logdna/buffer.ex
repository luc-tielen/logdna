defmodule Logdna.Buffer do
  defstruct data: [], size: 0, max_size: 1

  def new(0) do
    raise ArgumentError, "max_size must be greater than 0"
  end
  def new(max_size) when not is_integer(max_size) do
    raise ArgumentError, "max_size must be an integer"
  end
  def new(max_size) do
    struct(__MODULE__, %{max_size: max_size})
  end

  def push(%__MODULE__{data: current_data, size: current_size} = buffer, %Logdna.Log{} = entry) do
    size = current_size + 1
    index = Enum.count(current_data)
    data = List.insert_at(current_data, index, entry)

    %__MODULE__{buffer | size: size, data: data}
  end
  def push(_buffer, _invalid_entry) do
    raise ArgumentError, "entry must be a Log"
  end

  def maxed?(%__MODULE__{size: size, max_size: max_size}) do 
    size >= max_size
  end 
end