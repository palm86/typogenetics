defmodule Typogenetics.AminoAcidTest do
  use ExUnit.Case
  alias Typogenetics.AminoAcid, as: AA
  import Typogenetics.Strand, only: [sigil_B: 2]

  test "cut" do
    modes = [cuts: []]

    strands = ~B[A|]c
    assert AA.cut(strands, modes) == {:cont, ~B[A|]c, [{:cuts, [[]]}]}

    strands = ~B[A|T]c
    assert AA.cut(strands, modes) == {:cont, ~B[A|]c, [{:cuts, [[{:T, :A}]]}]}

    # Note that the top cutt offs are returned in reverse
    strands = ~B[A|TG]c

    assert AA.cut(strands, modes) ==
             {:cont, ~B[A|]c, [{:cuts, [[{:T, :A}, {:G, :C}]]}]}
  end

  test "del" do
    modes = []

    strands = ~B[TT|]c

    expected_result = ~B"""
    AA|
    T-|
    """

    assert AA.del(strands, modes) == {:halt, expected_result, modes}

    strands = ~B[T|T]c

    expected_result = ~B"""
    AA|
    -T|
    """

    assert AA.del(strands, modes) == {:cont, expected_result, modes}

    strands = ~B[T|TT]c

    expected_result = ~B"""
    AA|A
    -T|T
    """

    assert AA.del(strands, modes) == {:cont, expected_result, modes}
  end

  test "swi" do
    modes = []

    strands = ~B[A|]c
    assert AA.swi(strands, modes) == {:cont, ~B[T|]c, modes}

    strands = ~B[T|T]c
    assert AA.swi(strands, modes) == {:cont, ~B[AA|]c, modes}

    strands = ~B[T|TG]c
    assert AA.swi(strands, modes) == {:cont, ~B[CAA|]c, modes}

    strands = ~B[CAA|]c
    assert AA.swi(strands, modes) == {:cont, ~B[T|TG]c, modes}

    strands = ~B[A|]

    expected_strands = ~B"""
    A|
    -|
    """

    assert AA.swi(strands, modes) == {:halt, expected_strands, modes}
  end

  test "mvr" do
    modes = []

    strands = ~B[AA|]c
    assert AA.mvr(strands, modes) == {:halt, ~B[AA|]c, modes}

    strands = ~B[A|A]c
    assert AA.mvr(strands, modes) == {:cont, ~B[AA|]c, modes}

    strands = ~B[A|AA]c
    assert AA.mvr(strands, modes) == {:cont, ~B[AA|A]c, modes}
  end

  test "mvl" do
    modes = []

    strands = ~B[AA|]c
    assert AA.mvl(strands, modes) == {:cont, ~B[A|A]c, modes}

    strands = ~B[A|A]c
    assert AA.mvl(strands, modes) == {:halt, ~B[|AA]c, modes}

    strands = ~B[AA|AA]c
    assert AA.mvl(strands, modes) == {:cont, ~B[A|AAA]c, modes}

    strands = ~B[|AA]c
    assert AA.mvl(strands, modes) == {:halt, ~B[|AA]c, modes}
  end

  test "cop" do
    modes = []
    strands = ~B[A|]c
    assert AA.cop(strands, modes) == {:cont, strands, [copy: true]}

    modes = [copy: true]
    strands = ~B[A|]c
    assert AA.cop(strands, modes) == {:cont, strands, [copy: true]}
  end

  test "off" do
    modes = [copy: true]
    strands = ~B[A|]c
    assert AA.off(strands, modes) == {:cont, strands, [copy: false]}

    modes = []
    strands = ~B[A|]c
    assert AA.off(strands, modes) == {:cont, strands, [copy: false]}

    modes = [copy: false]
    strands = ~B[A|]c
    assert AA.off(strands, modes) == {:cont, strands, [copy: false]}
  end

  test "ina" do
    modes = []

    strands = ~B[A|]
    assert AA.ina(strands, modes) == {:cont, ~B[AA|], modes}
  end

  test "inc" do
    modes = []

    strands = ~B[A|]
    assert AA.inc(strands, modes) == {:cont, ~B[AC|], modes}
  end

  test "ing" do
    modes = []

    strands = ~B[AA|]c

    expected_strands = ~B"""
    TT-|
    AAG|
    """

    assert AA.ing(strands, modes) == {:cont, expected_strands, modes}

    strands = ~B[A|A]c

    expected_strands = ~B"""
    T-|T
    AG|A
    """

    assert AA.ing(strands, modes) == {:cont, expected_strands, modes}

    strands = ~B[A|AA]c

    expected_strands = ~B"""
    T-|TT
    AG|AA
    """

    assert AA.ing(strands, modes) == {:cont, expected_strands, modes}
  end

  test "int" do
    modes = []

    strands = ~B[A|]
    assert AA.int(strands, modes) == {:cont, ~B[AT|], modes}
  end

  test "rpy" do
    modes = []

    strands = ~B[A|GAAAATAAAA]
    assert AA.rpy(strands, modes) == {:cont, ~B[AGAAAAT|AAAA], modes}
  end

  test "rpu" do
    modes = []

    strands = ~B[TC|CCCCCGCCCC]
    assert AA.rpu(strands, modes) == {:cont, ~B[TCCCCCCG|CCCC], modes}
  end

  test "lpy" do
    modes = []

    strands = ~B[CCAAAAG|CCCC]
    assert AA.lpy(strands, modes) == {:cont, ~B[CC|AAAAGCCCC], modes}
  end

  test "lpu" do
    modes = []

    strands = ~B[GGTTTTC|GGGG]
    assert AA.lpu(strands, modes) == {:cont, ~B[GG|TTTTCGGGG], modes}
  end
end
