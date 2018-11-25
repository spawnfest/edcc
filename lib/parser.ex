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
    |> Enum.map(fn x -> Path.join(working_dir, x) end)
    |> Enum.filter(fn x -> File.exists?(x) end)
  end

  def getDeps(binary_file) do
    String.split(binary_file, "\n")
    |> Enum.filter(fn x -> String.contains?(x, "\"") end)
    |> Enum.map(fn x -> String.replace(x, " ", "") end)
    |> Enum.map(fn x -> String.replace_prefix(x, "#include", "") end)
    |> Enum.map(fn x -> String.replace(x, "\"", "") end)
  end

  def get_rid_of(files, str) do
    to_get_rid_of = 
    Enum.filter(files, fn x -> String.contains?(x, ".h") end)
    |> Enum.map(fn x -> String.replace_suffix(x, ".h", str) end)
    Enum.filter(files, fn x -> not Enum.member?(to_get_rid_of, x) end)
  end
  
end