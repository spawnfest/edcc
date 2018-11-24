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
  def init(makefile, workers), do: Parser.parse(makefile) |> Client.run(workers)

end
