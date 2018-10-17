defmodule NeuroticTest do
  use ExUnit.Case
  doctest Neurotic

  test "greets the world" do
    assert Neurotic.hello() == :world
  end
end
