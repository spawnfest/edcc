defmodule Worker do
  #Client API
  def boot(node) do
    GenServer.start_link(__MODULE__, [], name: {:global, Atom.to_string(node)})
  end

  #GenServer API
  def init(_) do
    {:ok, :ready}
  end

  def handle_call({:preprocess, file}, _from, _) do
    result = Parser.file_deps(file)
		{:reply, result, result}
	end

  def handle_call({:compile, file}, _from, _) do
    result = Compiler.compile(file)
		{:reply, result, result}
	end

  def terminate(_, _) do
		[]
	end

end