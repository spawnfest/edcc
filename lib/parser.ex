defmodule Parser do
  def parse(_) do
    ["main.c","foo.c","foo.h"]
  end

  def file_deps({name, binary_file}) do
    {name, formatDeps({name, binary_file})}
  end

  def get_binary(name) do
    {:ok, io} = File.open(name, [:binary, :read])
    binary_file = IO.binread(io, :all)
    File.close(io)
    {name, binary_file}
  end

  def formatDeps({name, binary_file}) do
    working_dir = Path.dirname(name)
    getDeps(binary_file)         # since this is a proof of concept we will only be considering header (.h) files
    |> Enum.filter(fn x -> String.contains?(x, ".h") end)
    |> Enum.filter(fn x -> Path.join(working_dir, x) |> File.exists?() end)
  end

  def getDeps(binary_file) do
    String.split(binary_file, "\n")
    |> Enum.filter(fn x -> String.contains?(x, "\"") end)
    |> Enum.map(fn x -> String.replace(x, " ", "") end)
    |> Enum.map(fn x -> String.replace_prefix(x, "#include", "") end)
    |> Enum.map(fn x -> String.replace(x, "\"", "") end)
  end
end