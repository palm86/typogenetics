defmodule Typogenetics.AminoAcid do
  @purines [:A, :G]
  @pyrimidines [:T, :C]

  def cut({left, right}, modes) do
    cuts = Keyword.get(modes, :cuts, [])
    {:cont, {left, []}, Keyword.put(modes, :cuts, [right | cuts])}
  end

  def del({[{_this, that} | l_rest], []}, modes) do
    {:halt, {[{nil, that} | l_rest], []}, modes}
  end

  def del({[{_this, that} | l_rest], [r_head | r_rest]}, modes) do
    {:cont, {[r_head | [{nil, that} | l_rest]], r_rest}, modes}
  end

  def swi({left, right}, modes) do
    that_and_this = fn {this, that} -> {that, this} end

    {Enum.map(right, that_and_this), Enum.map(left, that_and_this)}
    |> case do
      {left, [{nil, that} | r_rest]} -> {:halt, {[{nil, that} | left], r_rest}, modes}
      {left, [r_head | r_rest]} -> {:cont, {[r_head | left], r_rest}, modes}
    end
  end

  def mvr({left, []}, modes) do
    {:halt, {left, []}, modes}
  end

  def mvr({[{this, that} | l_rest], [r_head | r_rest]}, modes) do
    this_that =
      if modes[:copy] do
        {this, Typogenetics.Base.complement(this)}
      else
        {this, that}
      end

    {[r_head | [this_that | l_rest]], r_rest}
    |> case do
      {[{nil, _that} | _l_rest], _right} = strands -> {:halt, strands, modes}
      strands -> {:cont, strands, modes}
    end
  end

  def mvl({[], right}, modes) do
    {:halt, {[], right}, modes}
  end

  def mvl({[{this, that} | l_rest], right}, modes) do
    this_and_that =
      if modes[:copy] do
        {this, Typogenetics.Base.complement(this)}
      else
        {this, that}
      end

    {l_rest, [this_and_that | right]}
    |> case do
      {[], _right} = strands -> {:halt, strands, modes}
      {[{nil, _that} | _l_rest], _right} = strands -> {:halt, strands, modes}
      strands -> {:cont, strands, modes}
    end
  end

  def cop(strands, modes) do
    {:cont, strands, Keyword.put(modes, :copy, true)}
  end

  def off(strands, modes) do
    {:cont, strands, Keyword.put(modes, :copy, false)}
  end

  def ina(strands, modes) do
    do_inx(:A, strands, modes)
  end

  def inc(strands, modes) do
    do_inx(:C, strands, modes)
  end

  def ing(strands, modes) do
    do_inx(:G, strands, modes)
  end

  def int(strands, modes) do
    do_inx(:T, strands, modes)
  end

  defp do_inx(base, {left, right}, modes) when base in [:A, :C, :G, :T] do
    this_and_that =
      if modes[:copy] do
        {base, Typogenetics.Base.complement(base)}
      else
        {base, nil}
      end

    {:cont, {[this_and_that | left], right}, modes}
  end

  def rpy(strands, modes) do
    do_xpy(:mvr, strands, modes)
  end

  def lpy(strands, modes) do
    do_xpy(:mvl, strands, modes)
  end

  defp do_xpy(mvr_or_mvl, strands, modes) when mvr_or_mvl in [:mvr, :mvl] do
    case apply(__MODULE__, mvr_or_mvl, [strands, modes]) do
      {:halt, strands, modes} ->
        {:halt, strands, modes}

      {:cont, {[{this, that} | l_rest], right}, modes}
      when this in @pyrimidines ->
        {:cont, {[{this, that} | l_rest], right}, modes}

      {:cont, strands, modes} ->
        do_xpy(mvr_or_mvl, strands, modes)
    end
  end

  def rpu(strands, modes) do
    do_xpu(:mvr, strands, modes)
  end

  def lpu(strands, modes) do
    do_xpu(:mvl, strands, modes)
  end

  defp do_xpu(mvr_or_mvl, strands, modes) when mvr_or_mvl in [:mvr, :mvl] do
    case apply(__MODULE__, mvr_or_mvl, [strands, modes]) do
      {:halt, strands, modes} ->
        {:halt, strands, modes}

      {:cont, {[{this, that} | l_rest], right}, modes}
      when this in @purines ->
        {:cont, {[{this, that} | l_rest], right}, modes}

      {:cont, strands, modes} ->
        do_xpu(mvr_or_mvl, strands, modes)
    end
  end

  def kink(:cut), do: :straight
  def kink(:del), do: :straight
  def kink(:swi), do: :right
  def kink(:mvr), do: :straight
  def kink(:mvl), do: :straight
  def kink(:cop), do: :right
  def kink(:off), do: :left
  def kink(:ina), do: :straight
  def kink(:inc), do: :right
  def kink(:ing), do: :right
  def kink(:int), do: :left
  def kink(:rpy), do: :right
  def kink(:rpu), do: :left
  def kink(:lpy), do: :left
  def kink(:lpu), do: :left
end
