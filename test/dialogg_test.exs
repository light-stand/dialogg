defmodule DialoggTest do
  use ExUnit.Case
  doctest Dialogg

  test "greets the world" do
    assert Dialogg.hello() == :world
  end
end
