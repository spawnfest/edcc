defmodule Edcc do
  @moduledoc """
  Main module of the program.
  """

  @doc """
  It simply launches the command sequence that makes everything work.
  """
  def init(dir, workers), do: 
    File.cd!(dir, fn -> Parser.parse_actual_dir |> Client.run(workers) end)

  def help, do:
    IO.puts("Edcc.init(\"path_to_dir\", [:node_1@Node_1, :node_2@Node_2, ..., :node_n@Node_n])")

end
