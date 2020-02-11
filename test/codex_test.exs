defmodule CodexTest do
  use ExUnit.Case
  doctest Codex

  test "greets the world" do
    assert Codex.hello() == :world
  end
end
