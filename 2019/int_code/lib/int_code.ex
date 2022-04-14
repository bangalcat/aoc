defmodule IntCode do
  defdelegate process(init_data, inputs, opts), to: IntCode.Computer
end
