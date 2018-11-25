defmodule Sorting do
    @moduledoc """
    Main module of the program.
    """

    @doc """
    Sorts a list of filenames and a list of their dependencies.
    """
    def sort(list, deps) do
        createDeps(list, deps, [])
        |> Helper.get_rid_of(".h", ".c")
    end

    defp getDeps(_, []), do: []
    defp getDeps(file, [h|t]) do
        {file2, deps} = h
        case file2 == file do
            true -> deps
            _ -> getDeps(file, t)
        end
    end

    defp contains([], _), do: true
    defp contains([h|t], result) do
        case Enum.member?(result, h) do
            true -> contains(t, result)
            _ -> false
        end
    end

    defp createDeps([], _, result), do: result
    defp createDeps([h|t], dependencies, result) do
        deps = getDeps(h, dependencies)
        cond do
            h in result -> createDeps(t, dependencies, result)
            contains(deps, result) -> createDeps(t, dependencies, result ++ [h])
            true -> createDeps(t ++ [h], dependencies, result)
        end
    end
end
