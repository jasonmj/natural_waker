defmodule NaturalWakerTest do
  use ExUnit.Case
  doctest NaturalWaker

  test "greets the world" do
    assert NaturalWaker.hello() == :world
  end
end
