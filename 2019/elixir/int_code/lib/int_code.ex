defmodule IntCode do
  @doc """

  ## Options

  * output_count: output_count 개수만큼 output 나오고 중지. {memory, outputs} 반환
                  output_count 없으면 halt될때까지 돌고 중지. {memory, :halt} 반환

  ## Example

  ```elixir
  iex> init_data = %{0 => 104, 1 => 100}
  iex> IntCode.process(init_data, [], output_count: 1)
  {%Memory{memory: init_data, outputs: [100], pointer: 2}, [100]}

  iex> init_data = %{0 => 99}
  iex> IntCode.process(init_data, [], output_count: 1)
  {%Memory{memory: init_data}, :halt}

  iex> init_data = %{0 => 99}
  iex> IntCode.process(init_data, [])
  {%Memory{memory: init_data}, :halt}

  iex> init_data = %{0 => 3}
  iex> IntCode.process(init_data, [])
  {%Memory{memory: init_data}, :hold}
  ```
  """
  defdelegate process(init_data, inputs, opts \\ []), to: IntCode.Computer

  @doc """
  ## Example

  ```elixir

  iex> init_data = %{0 => 104, 1 => 100}
  iex> IntCode.init_state(init_data, [])
  %Memory{memory: init_data}
  ```
  """
  defdelegate init_state(init_data, inputs \\ []), to: IntCode.Computer
end
