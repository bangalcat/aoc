defmodule IntCode.Computer do
  alias IntCode.{Memory, Operator}

  @type option :: {:output_count, integer() | :infinity}
  @type options :: [option]

  @spec init_state(map(), list()) :: %Memory{}
  def init_state(data, inputs \\ []) do
    Memory.new(data: data, inputs: inputs)
  end

  @spec process(%Memory{} | map(), options()) ::
          {%Memory{}, :halt} | {%Memory{}, :hold} | {%Memory{}, list(integer())}
  def process(memory, inputs, opts \\ []) do
    output_count = Keyword.get(opts, :output_count, :infinity)

    Memory.new(data: memory, inputs: inputs)
    |> compute(output_count)
  end

  @spec compute(%Memory{}, integer()) ::
          {%Memory{}, :halt} | {%Memory{}, :hold} | {%Memory{}, list()}
  def compute(memory, output_count) do
    Memory.get_instruction(memory)
    |> Operator.new()
    |> case do
      %_{op_code: :halt} ->
        {memory, :halt}

      op ->
        move_operation(op, memory)
        |> case do
          {memory, :hold} ->
            {memory, :hold}

          {memory, outputs} when output_count <= 1 ->
            {memory, outputs}

          {memory, _outputs} ->
            compute(memory, dec(output_count))

          memory ->
            compute(memory, output_count)
        end
    end
  end

  defp move_operation(%Operator{op_code: op_code, params: {p1, p2, p3}}, memory)
       when op_code in [:add, :mul] do
    v1 = Memory.get_value(memory, 1, p1)
    v2 = Memory.get_value(memory, 2, p2)
    res = calc(op_code).(v1, v2)

    next_pointer = memory.pointer + 4

    Memory.put_value(memory, 3, res, p3)
    |> Memory.move_pointer(next_pointer)
  end

  defp move_operation(%Operator{op_code: :read}, %{inputs: []} = memory) do
    {memory, :hold}
  end

  defp move_operation(%Operator{op_code: :read, params: {p1, _, _}}, memory) do
    {input, memory} = Memory.pop_input(memory)

    next_pointer = memory.pointer + 2

    Memory.put_value(memory, 1, input, p1)
    |> Memory.move_pointer(next_pointer)
  end

  defp move_operation(%Operator{op_code: :print, params: {p1, _, _}}, memory) do
    output = Memory.get_value(memory, 1, p1)
    next_pointer = memory.pointer + 2

    Memory.prepend_outputs(memory, output)
    |> Memory.move_pointer(next_pointer)
    |> then(&{&1, &1.outputs})
  end

  defp move_operation(%Operator{op_code: :jump_neq, params: {p1, p2, _}}, memory) do
    predicate = Memory.get_value(memory, 1, p1)
    goto = Memory.get_value(memory, 2, p2)

    next_pointer = if predicate != 0, do: goto, else: memory.pointer + 3
    Memory.move_pointer(memory, next_pointer)
  end

  defp move_operation(%Operator{op_code: :jump_eq, params: {p1, p2, _}}, memory) do
    predicate = Memory.get_value(memory, 1, p1)
    goto = Memory.get_value(memory, 2, p2)

    next_pointer = if predicate == 0, do: goto, else: memory.pointer + 3
    Memory.move_pointer(memory, next_pointer)
  end

  defp move_operation(%Operator{op_code: :comp_lt, params: {p1, p2, p3}}, memory) do
    v1 = Memory.get_value(memory, 1, p1)
    v2 = Memory.get_value(memory, 2, p2)
    value = if v1 < v2, do: 1, else: 0
    next_pointer = memory.pointer + 4

    Memory.put_value(memory, 3, value, p3)
    |> Memory.move_pointer(next_pointer)
  end

  defp move_operation(%Operator{op_code: :comp_eq, params: {p1, p2, p3}}, memory) do
    v1 = Memory.get_value(memory, 1, p1)
    v2 = Memory.get_value(memory, 2, p2)
    value = if v1 == v2, do: 1, else: 0
    next_pointer = memory.pointer + 4

    Memory.put_value(memory, 3, value, p3)
    |> Memory.move_pointer(next_pointer)
  end

  defp move_operation(%Operator{op_code: :adj_rb, params: {p1, _, _}}, memory) do
    v = Memory.get_value(memory, 1, p1)

    Memory.adjust_relative_base(memory, v)
    |> Memory.move_pointer(memory.pointer + 2)
  end

  defp calc(:add), do: &Kernel.+/2
  defp calc(:mul), do: &Kernel.*/2

  defp dec(:infinity), do: :infinity
  defp dec(n) when is_number(n), do: n - 1
end
