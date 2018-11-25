defmodule Linker do
  def link(files) do
    Enum.map(files, fn x -> Helper.save_file_in(x, ".") end)
    #files = guardar los binaries con los nombres.
    file_names = Enum.map(files, fn {name, _binary} -> name end)
    System.cmd("gcc", ["-o", "main"] ++ file_names)
  end

end