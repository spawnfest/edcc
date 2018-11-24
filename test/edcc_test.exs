defmodule EdccTest do
  use ExUnit.Case
  doctest Edcc

  test "greets the world" do
    assert Edcc.hello() == :world
  end
end
