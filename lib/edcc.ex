defmodule Edcc do
  @moduledoc """
  Main module of the program.
  """

  @doc """
  It simply launches the command sequence that makes everything work.
  """
  def init(dir, workers), do: 
    File.cd!(dir, fn -> Parser.parse_actual_dir |> Client.run(workers) end)

end
