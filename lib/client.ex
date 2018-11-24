defmodule Client do
  #Client API
  def run(_,nodes) do
    getNodes(nodes)
  end

  defp getNodes(nodes) do
    Enum.filter(nodes, fn x -> Node.ping(x) == :pong end)
    |> Enum.map(fn x -> Node.spawn(x,Worker,:boot,[x]) end)
  end  
end