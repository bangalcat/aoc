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
    Operator.new(
      &get_value(&1.(memory), &2),
      &put_value(&1.(memory), &2, &3),
      &read_input(&1.(memory), &2),
      &print_output(&1, &2),
      &move(&1.(memory), &2),
      &adjust(&1.(memory), &2)
    )
    |> Operator.operate(Memory.get_instruction(memory))
    |> case do
      :halt ->
        {memory, :halt}

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

  defp get_value(memory, {offset, mode}) do
    Memory.get_value(memory, offset, mode)
  end

  defp put_value(memory, {offset, mode}, res) do
    Memory.put_value(memory, offset, res, mode)
  end

  defp read_input(%{inputs: []} = mem, _), do: {mem, :hold}

  defp read_input(memory, {offset, mode}) do
    {input, memory} = Memory.pop_input(memory)
    Memory.put_value(memory, offset, input, mode)
  end

  defp print_output(memory, output) do
    Memory.prepend_outputs(memory, output)
    |> then(&{&1, &1.outputs})
  end

  defp move({mem, :hold}, _), do: {mem, :hold}

  defp move(memory, {:goto, pointer}) do
    Memory.move_pointer(memory, pointer)
  end

  defp move(memory, offset) do
    Memory.move_pointer(memory, memory.pointer + offset)
  end

  defp adjust(memory, offset) do
    Memory.adjust_relative_base(memory, offset)
  end

  defp dec(:infinity), do: :infinity
  defp dec(n) when is_number(n), do: n - 1
end
