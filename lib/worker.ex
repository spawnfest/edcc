defmodule Worker do
  #Client API
  def boot(node) do
    GenServer.start_link(__MODULE__, [], name: {:global, Atom.to_string(node)})
  end

  #GenServer API
  def init(_) do
    {:ok, :ready}
  end

  def handle_call(:getstate, _from, state) do
		{:reply, state, state}
	end

  def handle_call({:preprocess, file}, _from, state) do
		{:reply, Parser.file_deps(file), state}
	end

  def handle_cast({:preprocess, file}, _) do
    result = Parser.file_deps(file)
    {:noreply, {:finished, result}}
  end

  def terminate(_,_) do
		[]
	end

end