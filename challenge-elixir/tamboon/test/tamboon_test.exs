defmodule TamboonTest do
  use ExUnit.Case
  doctest Tamboon

  test "greets the world" do
    assert Tamboon.hello() == :world
  end
end
