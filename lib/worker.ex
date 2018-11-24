defmodule Worker do
  #Client API
  def boot(node) do
    GenServer.start_link(__MODULE__, [], name: {:global, node})
  end

  #GenServer API
  def init(_) do
    {:ok,[]}
  end

  def terminate(_,_) do
		[]
	end

end