defmodule Parser do
  def parse(_) do
  end

  def getDeps(file) when is_bitstring(file) do
    {:ok, io} = File.open(file, [:binary, :read])
    to_filter = get_ignored_libs()
    filered_dependencies = 
    getDeps({file, IO.binread(io, :all)})
    |> Enum.filter(fn x -> not Enum.member?(to_filter, x) end)
    #IO.inspect filtered_dependencies
  end
  def getDeps({name, binary_file}) do
    File.mkdir("tmp")
    fixedName = "tmp/" <> Path.basename(name)
    {:ok, deps} = case File.open fixedName, [:write] do
      {:ok, iodev} -> 
        IO.binwrite(iodev, binary_file)
        File.close(iodev)
        {:ok, iodv} = File.open(fixedName, [:binary, :read])
        deps = get_only_includes(iodv, [])
        File.close(iodv)
        File.close(iodev)
        File.rm(fixedName)
        {:ok, deps}
      e -> e
    end
    File.rmdir("tmp")
    deps
  end

  defp get_only_includes(iodev, list) do
    case 
    IO.read(iodev, :line)
    |> :string.find("#") do
      :nomatch -> 
        #IO.inspect list
        list
      str -> 
        case :string.prefix(str, "#include") do
          :nomatch -> get_only_includes(iodev, list)
          s -> tmp = :string.trim s
          get_only_includes(iodev, 
            list ++ [:string.slice(tmp, 1, :string.length(tmp) - 2)])
        end
    end
  end

  def get_ignored_libs() do
    {:ok, ignored_libs} = File.open("extras/ignored_libs.txt", [:binary, :read])
    ignored = get_ignored_libs(ignored_libs, [])
    File.close(ignored_libs)
    ignored
  end
  def get_ignored_libs(iodev, list) do
    case IO.read(iodev, :line) do
      :eof -> list
      str -> get_ignored_libs(iodev, list ++ [:string.slice(str, 0, :string.length(str) - 1)])
    end
  end

end