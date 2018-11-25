defmodule Edcc do
  @moduledoc """
  Documentation for Edcc.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Edcc.hello()
      :world

  """
  def init(dir, workers), do: 
    File.cd!(dir, fn -> Parser.parse_actual_dir |> Client.run(workers) end)

end
