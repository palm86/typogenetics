defmodule Typogenetics.StrandTest do
  use ExUnit.Case
  doctest Typogenetics.Strand

  import Typogenetics.Strand, only: [sigil_B: 2]

  test "sigil_B" do
    assert ~B"""
           -|--
           A|TG
           """ == {[{:A, nil}], [{:T, nil}, {:G, nil}]}

    assert ~B"""
           A|TG
           """c == {[{:A, :T}], [{:T, :A}, {:G, :C}]}

    assert ~B"""
           A|TG
           """ == {[{:A, nil}], [{:T, nil}, {:G, nil}]}
  end
end
