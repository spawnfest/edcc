defmodule Linker do
  @moduledoc """
  Linker module.
  """
  
  @doc """
  Links a list of object files (.o) 
  together under the "main" name.

  Returns the tuple {:ok, :files_linked_successfully} in that case.
  """
  def link(files) do
    Enum.map(files, fn x -> Helper.save_file_in(x, ".") end)
    file_names = Enum.map(files, fn {name, _binary} -> name end)
    case System.cmd("gcc", ["-o", "main"] ++ file_names) do
        {_, 0} -> {:ok, :files_linked_successfully}
        {_, n} -> raise RuntimeError, message: "Could not link the files (exit code: #{n})."
    end
  end

end