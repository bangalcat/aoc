defmodule IntCode.Memory do
  @addr_mode 0
  @inc_mode 1
  @relative_mode 2

  defstruct memory: %{}, inputs: [], outputs: [], pointer: 0, relative_base: 0

  @doc """

  ## Example

  ```elixir
  iex> data = %{0 => 1, 1 => 0, 2 => 3, 3 => 4}
  iex> new(data: data, inputs: [1])
  %Memory{memory: data, inputs: [1], outputs: [], pointer: 0, relative_base: 0}

  iex> data = %{0 => 1, 1 => 0, 2 => 3, 3 => 4}
  iex> prev = new(data: data, inputs: [1])
  iex> prev = %{prev | outputs: [1], pointer: 99, relative_base: 3}
  iex> new(data: prev, inputs: [0])
  %Memory{memory: data, inputs: [1, 0], outputs: [], pointer: 99, relative_base: 3}
  ```
  """
  def new(
        data: %__MODULE__{memory: map, inputs: prev_inputs, pointer: pointer, relative_base: rb},
        inputs: inputs
      ),
      do: %__MODULE__{
        memory: map,
        inputs: prev_inputs ++ inputs,
        pointer: pointer,
        relative_base: rb
      }

  def new(data: map, inputs: inputs) do
    %__MODULE__{memory: map, inputs: inputs}
  end

  @doc """

  ## Example

  ```elixir
  iex> mem = %Memory{memory: %{3 => 1001}, pointer: 3}
  iex> get_instruction(mem)
  1001
  ```
  """
  def get_instruction(%__MODULE__{memory: map, pointer: pointer}), do: map[pointer]

  @doc """

  ## Example

  ```elixir
  iex> mem = %Memory{memory: %{0 => 1, 1 => 2, 2 => 3, 3 => 4}, pointer: 0, relative_base: 1}
  iex> get_value(mem, 1, 1)
  2
  iex> get_value(mem, 1, 0)
  3
  iex> get_value(mem, 1, 2)
  4
  ```
  """
  def get_value(%__MODULE__{memory: map, pointer: p}, offset, @inc_mode), do: map[p + offset] || 0

  def get_value(%__MODULE__{memory: map, pointer: p}, offset, @addr_mode),
    do: map[map[p + offset]] || 0

  def get_value(%__MODULE__{memory: map, pointer: p, relative_base: rb}, offset, @relative_mode),
    do: map[rb + map[p + offset]] || 0

  @doc """


  ## Example

  ```elixir
  iex> mem = %Memory{memory: %{0 => 1, 1 => 2, 2 => 3, 3 => 4}, pointer: 0, relative_base: 1}
  iex> put_value(mem, 1, 100, 0)
  %Memory{memory: %{0 => 1, 1 => 2, 2 => 100, 3 => 4}, pointer: 0, relative_base: 1}

  iex> mem = %Memory{memory: %{0 => 1, 1 => 2, 2 => 3, 3 => 4}, pointer: 0, relative_base: 1}
  iex> put_value(mem, 1, 100, 2)
  %Memory{memory: %{0 => 1, 1 => 2, 2 => 3, 3 => 100}, pointer: 0, relative_base: 1}
  ```
  """
  def put_value(%__MODULE__{memory: map, pointer: p} = s, offset, value, @addr_mode),
    do: %{s | memory: Map.put(map, map[p + offset], value)}

  def put_value(
        %__MODULE__{memory: map, pointer: p, relative_base: rb} = s,
        offset,
        value,
        @relative_mode
      ),
      do: %{s | memory: Map.put(map, rb + map[p + offset], value)}

  @doc """

  ## Example

  ```elixir
  iex> mem = %Memory{memory: %{}, pointer: 0, relative_base: 1, outputs: [1]}
  iex> prepend_outputs(mem, 2)
  %Memory{memory: %{}, outputs: [2, 1], relative_base: 1}
  ```
  """
  def prepend_outputs(memory, output), do: %{memory | outputs: [output | memory.outputs]}

  @doc """

  ## Example

  ```elixir
  iex> mem = %Memory{memory: %{}, pointer: 1}
  iex> move_pointer(mem, 10)
  %Memory{pointer: 10}
  ```
  """
  def move_pointer(memory, next_ptr), do: %{memory | pointer: next_ptr}

  @doc """

  ## Example

  ```elixir
  iex> mem = %Memory{inputs: [1, 0]}
  iex> pop_input(mem)
  {1, %Memory{inputs: [0]}}

  iex> mem = %Memory{inputs: []}
  iex> pop_input(mem)
  {:error, mem}
  ```
  """
  def pop_input(%__MODULE__{inputs: [input | rest]} = memory),
    do: {input, %{memory | inputs: rest}}

  def pop_input(memory), do: {:error, memory}

  @doc """

  ## Example

  ```elixir
  iex> mem = %Memory{inputs: [0]}
  iex> put_inputs(mem, [1, 2])
  %Memory{inputs: [0, 1, 2]}
  ```
  """
  def put_inputs(memory, inputs), do: %{memory | inputs: memory.inputs ++ inputs}

  @doc """

  ## Example

  ```elixir
  iex> mem = %Memory{relative_base: 1}
  iex> adjust_relative_base(mem, 3)
  %Memory{relative_base: 4}
  ```
  """
  def adjust_relative_base(memory, offset),
    do: %{memory | relative_base: memory.relative_base + offset}
end
