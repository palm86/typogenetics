defmodule Typogenetics.EnzymeTest do
  use ExUnit.Case

  test "determine_binding_preference" do
#     enzyme = ~w(rpu inc cop mvr mvl swi lpy int)a
#     assert Typogenetics.Enzyme.determine_binding_preference(enzyme) == :G

    enzyme = ~w(rpy ina rpu mvr int mvl cut swi cop)a
    assert Typogenetics.Enzyme.determine_binding_preference(enzyme) == :C
  end

  test "execute" do
    string_strand = "A|TTACCA"
    enzyme = ~w(cop rpu rpy rpu mvl)a
    assert ["ATTACCA", "TGGTAAT"] == Typogenetics.Enzyme.execute(string_strand, enzyme)
  end
end
