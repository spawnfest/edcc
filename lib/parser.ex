defmodule Parser do
  def parse_actual_dir() do
    ["shell.c","list.c","list.h"]
  end

  def file_deps({name, binary_file}) do
    {name, formatDeps({name, binary_file})}
  end

  defp formatDeps({_name, binary_file}) do
    getDeps(binary_file)         # since this is a proof of concept we will only be considering header (.h) files
    |> Enum.filter(fn x -> String.contains?(x, ".h") end)
    # |> Enum.filter(fn x -> File.exists?(x) end)
  end

  defp getDeps(binary_file) do
    String.split(binary_file, "\n")
    |> Enum.filter(fn x -> String.contains?(x, "\"") end)
    |> Enum.map(fn x -> String.replace(x, " ", "") end)
    |> Enum.map(fn x -> String.replace_prefix(x, "#include", "") end)
    |> Enum.map(fn x -> String.replace(x, "\"", "") end)
  end
end