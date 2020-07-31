defmodule WokeTest do
  use ExUnit.Case
  doctest Woke

  test "greets the world" do
    assert Woke.hello() == :world
  end
end
