defmodule Worker do
  @moduledoc """
  The Worker module, used by the nodes.
  """

  @doc """
  Starts a GenServer in a given node.
  """
  def boot(node) do
    GenServer.start_link(__MODULE__, [], name: {:global, Atom.to_string(node)})
  end

  def init(_) do
    {:ok, :ready}
  end

  @doc """
  When called to preprocess, returns the dependencies of a given file.
  """
  def handle_call({:preprocess, file}, _from, _) do
    result = Parser.file_deps(file)
		{:reply, result, result}
	end

  @doc """
  When called to compile, returns an object file from a given one.
  """
  def handle_call({:compile, file}, _from, _) do
    result = Compiler.compile(file)
		{:reply, result, result}
	end

  def terminate(_, _) do
		[]
	end

end