defmodule IntCode.Operator do
  defstruct [:params, :op_code]

  @type t :: %__MODULE__{params: {integer(), integer(), integer()}, op_code: atom()}

  @spec new(integer()) :: t()
  def new(instruction) do
    op_code = rem(instruction, 100)
    params = get_parameters(instruction)

    %__MODULE__{
      op_code: op_code(op_code),
      params: params
    }
  end

  def new(instruction) do
    op_code = rem(instruction, 100)
    params = get_parameters(instruction)

    %__MODULE__{
      op_code: op_code(op_code),
      params: params
    }
  end

  defp get_parameters(instruction) do
    {
      instruction |> div(100) |> rem(10),
      instruction |> div(1_000) |> rem(10),
      instruction |> div(10_000) |> rem(10)
    }
  end

  defp op_code(1), do: :add
  defp op_code(2), do: :mul
  defp op_code(3), do: :read
  defp op_code(4), do: :print
  defp op_code(5), do: :jump_neq
  defp op_code(6), do: :jump_eq
  defp op_code(7), do: :comp_lt
  defp op_code(8), do: :comp_eq
  defp op_code(9), do: :adj_rb
  defp op_code(99), do: :halt
end
