defmodule IntCodeTest do
  use ExUnit.Case

  alias IntCode.{Computer, Memory}
  doctest IntCode

  describe "day 2" do
    test "part 1" do
      init_data =
        init_data(Path.expand("fixture/day-2.txt", __DIR__)) |> Map.merge(%{1 => 12, 2 => 3})

      assert {mem, :halt} = Computer.process(init_data, [])
      assert mem.memory[0] == 5_110_676
    end
  end

  describe "day 9" do
    test "part 1" do
      init_data = init_data(Path.expand("fixture/day-9.txt", __DIR__))

      assert {_mem, [2_377_080_455]} = Computer.process(init_data, [1], output_count: 1)
    end

    test "part 2" do
      init_data = init_data(Path.expand("fixture/day-9.txt", __DIR__))

      assert {_mem, [74917]} = Computer.process(init_data, [2], output_count: 1)
    end
  end

  defp init_data(path) do
    File.read!(path)
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new(fn {v, k} -> {k, v} end)
  end
end
