defmodule ContaTest do
  use ExUnit.Case
  doctest Conta

  test "greets the world" do
    assert Conta.hello() == :world
  end
end
