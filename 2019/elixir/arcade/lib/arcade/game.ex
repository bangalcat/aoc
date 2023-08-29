defmodule Arcade.Game do
	def init(init_data) do
		init_data
		|> put_coin()
		|> IntCode.process([], output_count: :infinity)
	end

	defp put_coin(init_data) do
		Map.put(init_data, 0, 2)
	end
end
