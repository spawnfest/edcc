defmodule Client do
  @moduledoc """
  The Client module.
  """

  @doc """
  Gets the work done.
  First it gets the available nodes from a list and uses them to preprocess 
  the required files and later compile them (after sorting the dependencies of every file).
  After that it links the object files obtained from the nodes.
  """
  def run(names, nodes) do
    files = Enum.map(names, fn x -> Helper.get_binary(x) end)
    nodes = getNodes(nodes)
    Process.sleep(1000)
    deps = preprocess(nodes, files, [], [])
    headers = 
      Enum.filter(names, fn x -> String.contains?(x, ".h") end)
      |> Enum.map(fn x -> Helper.get_binary(x) end)
    fin = 
      Sorting.sort(names, deps)
      |> setWork(files, deps)
      |> compile(nodes, [], headers)
      |> Linker.link()
    stop_workers(nodes)
    fin
  end

  defp compile([], _, [], compiled), do: compiled
  defp compile([], _, [ht|tt], compiled) do
    {:ok, {_, result}} = Task.yield(ht, :infinity)
    compile([], [], tt , compiled ++ [result])
  end
  defp compile([hf|tf], [], [ht|tt], compiled) do
    {:ok, {node, result}} = Task.yield(ht, :infinity)
    try do
      file = setCompileFile(hf, compiled ++ [result])
      task = Task.async(fn -> {node, GenServer.call({:global, Atom.to_string(node)}, {:compile, file})} end)
      compile(tf, [], tt ++ [task], compiled ++ [result])
    rescue
      NotFoundException -> [h1|t1] = tf
      compile([h1|[hf|t1]], [node], tt, compiled)
    end
  end
  defp compile([hf|tf], [hn|tn], [], compiled) do
    try do
      file = setCompileFile(hf, compiled)
      task = Task.async(fn -> {hn, GenServer.call({:global, Atom.to_string(hn)}, {:compile, file})} end)
      compile(tf, tn, [task], compiled)
    rescue
      NotFoundException -> [h1|t1] = tf
      compile([h1|[hf|t1]], [hn|tn], [], compiled)
    end
  end
  defp compile([hf|tf], [hn|tn], [ht|tt], compiled) do
    try do
      file = setCompileFile(hf, compiled)
      task = Task.async(fn -> {hn, GenServer.call({:global, Atom.to_string(hn)}, {:compile, file})} end)
             compile(tf, tn, [ht|tt] ++ [task], compiled)
    rescue
      NotFoundException -> {:ok, {node, result}} = Task.yield(ht, :infinity)
      compile([hf|tf], [hn|tn] ++ [node], tt, compiled ++ [result])
    end
  end

  defp setCompileFile({{name, bin}, []}, _) do
    filec = 
      String.replace_suffix(name, ".h", ".c")
      |> Helper.get_binary()
    {filec, [{name, bin}]}
  end
  defp setCompileFile({file, list}, deps) do
    {file, Enum.map(list, fn x -> Helper.getTuple(x, deps) end) ++
           Enum.map(list, fn x -> Helper.getTuple(String.replace_suffix(x, ".h", ".o"), deps) end)}
  end

  defp setWork(order, files, deps) do
    Enum.map(order, fn x -> 
      {_, dep_list} = Helper.getTuple(x, deps)
      {Helper.getTuple(x, files), dep_list} 
    end)
  end

  defp getNodes(nodes) do
    result = Enum.filter(nodes, fn x -> Node.ping(x) == :pong end)
    case result do
      [] -> raise NotFoundException, message: "No nodes were found."
      _ ->  
        Enum.map(result, fn x -> Node.spawn(x, Worker, :boot, [x]) end)
        result
    end

  end

  defp preprocess(_, [], [], deps), do: deps
  defp preprocess(_, [], [ht|tt], deps) do
    {:ok, {_, dep}} = Task.yield(ht, :infinity)
    preprocess([], [], tt, deps ++ [dep])
  end
  defp preprocess([], [hf|tf], [ht|tt], deps) do
    {:ok, {node, dep}} = Task.yield(ht, :infinity)
    task = Task.async(fn -> {node, GenServer.call({:global, Atom.to_string(node)}, {:preprocess, hf})} end)
    preprocess([], tf, tt ++ [task], deps ++ [dep])
  end
  defp preprocess([hn|tn], [hf|tf], tasks, deps) do
    task = Task.async(fn -> {hn, GenServer.call({:global, Atom.to_string(hn)}, {:preprocess, hf})} end)
    preprocess(tn, tf, tasks ++ [task], deps)
  end

  defp stop_workers(nodes), do: Enum.map(nodes, fn x -> GenServer.stop({:global, Atom.to_string(x)}) end)
end