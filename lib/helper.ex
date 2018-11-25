defmodule Helper do
    @moduledoc """
    An auxiliar module, Helper.
    """

    @doc """
    Opens a given file in binary mode to read all of its contents in binary mode.

    Returns a tuple of the file name and said content.
    """
    def get_binary(name) do
        {:ok, io} = File.open(name, [:binary, :read])
        binary_file = IO.binread(io, :all)
        File.close(io)
        {name, binary_file}
    end
    
    @doc """
    Returns a new list of files from a given one excluding those that don't contain 'replacement' 
    """
    def get_rid_of(files, str, replacement) do
        to_get_rid_of = 
            Enum.filter(files, fn x -> String.contains?(x, str) end)
            |> Enum.map(fn x -> String.replace_suffix(x, str, replacement) end)
        Enum.filter(files, fn x -> not Enum.member?(to_get_rid_of, x) end)
    end

    @doc """
    Saves a file in a directory.
    """
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

    @doc """
    Returns the first tuple that contains a given filename.
    """
    def getTuple(_, []), do: raise NotFoundException
    def getTuple(file, [{file, bin}|_]), do: {file, bin}
    def getTuple(file, [_|t]), do: getTuple(file, t)    
end