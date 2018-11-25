defmodule Client do
  #Client API
  def run(names, nodes) do
    files = Enum.map(names, fn x -> Parser.get_binary(x) end)
    getNodes(nodes)
    Process.sleep(1000)
    deps = preprocess(nodes, files,[],[])
    Sorting.sort(names,deps)
  end

  defp getNodes(nodes) do
    Enum.filter(nodes, fn x -> Node.ping(x) == :pong end)
    |> Enum.map(fn x -> Node.spawn(x, Worker, :boot, [x]) end)
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
end