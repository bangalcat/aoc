defmodule IntCode.Operator do
  @add 1
  @mul 2
  @read 3
  @print 4
  @jump_neq 5
  @jump_eq 6
  @comp_lt 7
  @comp_eq 8
  @adj 9
  @halt 99

  defstruct [:get_fn, :put_fn, :read_fn, :print_fn, :move_fn, :adj_fn]

  @type param :: {1 | 2 | 3, 0 | 1 | 2}

  @type t :: %__MODULE__{
          get_fn: ((map -> map), param -> map),
          put_fn: ((map -> map), param, integer -> map),
          read_fn: ((map -> map), param -> map | {map, :hold}),
          print_fn: ((map -> map), param -> {map, [integer]}),
          move_fn: ((map -> map), param | integer -> map),
          adj_fn: ((map -> map), integer -> map)
        }

  @ident_fn &Function.identity/1

  @spec new(fun(), fun(), fun(), fun(), fun(), fun()) :: t()
  def new(get_fn, put_fn, read_fn, print_fn, move_fn, adj_fn) do
    %__MODULE__{
      get_fn: get_fn,
      put_fn: put_fn,
      read_fn: read_fn,
      print_fn: print_fn,
      move_fn: move_fn,
      adj_fn: adj_fn
    }
  end

  @spec operate(t(), integer()) :: map() | {map, :hold} | {map, [integer]} | :halt
  def operate(%__MODULE__{} = operator, instruction) do
    op_code = rem(instruction, 100)
    {p1, p2, p3} = get_parameters(instruction)

    do_operate( op_code, {{1, p1}, {2, p2}, {3, p3}}, operator)
  end

  defp do_operate(@add, {p1, p2, p3}, %__MODULE__{get_fn: get_fn, put_fn: put_fn, move_fn: move_fn}) do
    res = get_fn.(@ident_fn, p1) + get_fn.(@ident_fn, p2)

    mem = put_fn.(@ident_fn, p3, res)
    move_fn.(fn _ -> mem end, 4)
  end

  defp do_operate(@mul, {p1, p2, p3}, %__MODULE__{get_fn: get_fn, put_fn: put_fn, move_fn: move_fn}) do
    res = get_fn.(@ident_fn, p1) * get_fn.(@ident_fn, p2)

    put_fn.(@ident_fn, p3, res)
    |> then(&move_fn.(fn _ -> &1 end, 4))
  end

  defp do_operate(@read, {p1, _p2, _p3}, %__MODULE__{read_fn: read_fn, move_fn: move_fn}) do
    read_fn.(@ident_fn, p1)
    |> then(&move_fn.(fn _ -> &1 end, 2))
  end

  defp do_operate(@print, {p1, _p2, _p3}, %__MODULE__{get_fn: get_fn, print_fn: print_fn, move_fn: move_fn}) do
    output = get_fn.(@ident_fn, p1)

    move_fn.(@ident_fn, 2)
    |> print_fn.(output)
  end

  defp do_operate(@jump_neq, {p1, p2, _}, %__MODULE__{get_fn: get_fn, move_fn: move_fn}) do
    predicate = get_fn.(@ident_fn, p1)
    goto = if predicate != 0, do: {:goto, get_fn.(@ident_fn, p2)}, else: 3
    move_fn.(&Function.identity/1, goto)
  end

  defp do_operate(@jump_eq, {p1, p2, _}, %__MODULE__{get_fn: get_fn, move_fn: move_fn}) do
    predicate = get_fn.(@ident_fn, p1)
    goto = if predicate == 0, do: {:goto, get_fn.(@ident_fn, p2)}, else: 3
    move_fn.(@ident_fn, goto)
  end

  defp do_operate(@comp_lt, {p1, p2, p3}, %__MODULE__{get_fn: get_fn, put_fn: put_fn, move_fn: move_fn}) do
    v1 = get_fn.(@ident_fn, p1)
    v2 = get_fn.(@ident_fn, p2)
    res = if v1 < v2, do: 1, else: 0

    mem = put_fn.(@ident_fn, p3, res)
    move_fn.(fn _ -> mem end, 4)
  end

  defp do_operate(@comp_eq, {p1, p2, p3}, %__MODULE__{get_fn: get_fn, put_fn: put_fn, move_fn: move_fn}) do
    v1 = get_fn.(@ident_fn, p1)
    v2 = get_fn.(@ident_fn, p2)
    res = if v1 == v2, do: 1, else: 0

    mem = put_fn.(@ident_fn, p3, res)
    move_fn.(fn _ -> mem end, 4)
  end

  defp do_operate(@adj, {p1, _p2, _p3}, %__MODULE__{get_fn: get_fn, adj_fn: adj_fn, move_fn: move_fn}) do
    get_fn.(@ident_fn, p1)
    |> then(&adj_fn.(@ident_fn, &1))
    |> then(&move_fn.(fn _ -> &1 end, 2))
  end

  defp do_operate(@halt, _, _) do
    :halt
  end

  defp get_parameters(instruction) do
    {
      instruction |> div(100) |> rem(10),
      instruction |> div(1_000) |> rem(10),
      instruction |> div(10_000) |> rem(10)
    }
  end
end
