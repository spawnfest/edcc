defmodule Helper do
    def get_binary(name) do
        {:ok, io} = File.open(name, [:binary, :read])
        binary_file = IO.binread(io, :all)
        File.close(io)
        {name, binary_file}
    end
    
    def get_rid_of(files, str) do
        to_get_rid_of = 
        Enum.filter(files, fn x -> String.contains?(x, ".h") end)
        |> Enum.map(fn x -> String.replace_suffix(x, ".h", str) end)
        Enum.filter(files, fn x -> not Enum.member?(to_get_rid_of, x) end)
    end

    def save_file_in({name, binary_file}, dir) do
        file_name = Path.join(dir, Path.basename(name))
        case File.open file_name, [:write] do
          {:ok, iodev} ->
            IO.binwrite iodev, binary_file
            File.close iodev
            {:ok, :created}
          e -> e        
        end
    end

    def getTuple(file, []), do: []
    def getTuple(file, [{file, bin}|_]), do: {file, bin}
    def getTuple(file, [_|t]), do: getTuple(file, t)    
end