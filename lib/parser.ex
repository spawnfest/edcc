defmodule Parser do
  def parse(_) do
  end

  def getDeps(file) when is_bitstring(file) do
    {:ok, io} = File.open(file, [:binary, :read])
    getDeps({file, IO.binread(io, :all)})
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
    case IO.read(iodev, :line) |> :string.find("#") do
      :nomatch -> 
        IO.inspect list
        list
      str -> 
        case :string.prefix(str, "#include") do
          :nomatch -> get_only_includes(iodev, list)
          s -> 
            tmp = :string.trim s
            case :string.prefix(tmp, "\"") do
              :nomatch -> get_only_includes(iodev, list)
              s2 ->
                get_only_includes(iodev, 
                  list ++ [:string.slice(s2, 0, :string.length(s2) - 1)])
          end
        end
    end
  end

end