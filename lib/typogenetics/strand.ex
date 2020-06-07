defmodule Typogenetics.Strand do
  @type unbound_strand :: list(Typogenetics.Base.base())
  @type bound_strand ::
          {list({Typogenetics.Base.base() | nil, Typogenetics.Base.base() | nil}),
           list({Typogenetics.Base.base() | nil, Typogenetics.Base.base() | nil})}
  @doc """
  Converts string representation of a strand to a duo of lists.

  The first list represents the bases left of the current position.
  It's head is the current position. The second list represents
  the bases right of the current position. The current position
  is indicated with a `|` in the string.

  Each element of both lists represents a 2-tuple of bases, one on
  the current strand and one on the complementary strand.

  If no options are provided, the complementary strand is taken to be all
  empty (represented by `nil` atoms). If the `c` option is
  provided, the complementary strand is assumed to be populated by the
  complement of the current strand.

  ## Examples

  iex> import Typogenetics.Strand
  iex> ~B[AC|TG]c
  {[{:C, :G}, {:A, :T}], [{:T, :A}, {:G, :C}]}

  iex> import Typogenetics.Strand
  iex> ~B[AC|TG]
  {[{:C, nil}, {:A, nil}], [{:T, nil}, {:G, nil}]}
  """
  def sigil_B(input, mod) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn strand ->
      strand
      |> String.split("|")
      |> Enum.map(fn half ->
        half
        |> String.split("", trim: true)
        |> Enum.map(&String.to_atom/1)
        |> Enum.map(fn
          :- -> nil
          x -> x
        end)
      end)
    end)
    |> case do
      # Only bottom strand provided, treat as complement if c
      # option provided, nils otherwise
      [[bottom_left, bottom_right]] ->
        if ?c in mod do
          {Enum.zip(
             bottom_left,
             Enum.map(bottom_left, fn x -> Typogenetics.Base.complement(x) end)
           ),
           Enum.zip(
             bottom_right,
             Enum.map(bottom_right, fn x -> Typogenetics.Base.complement(x) end)
           )}
        else
          {Enum.zip(bottom_left, Enum.map(bottom_left, fn _ -> nil end)),
           Enum.zip(bottom_right, Enum.map(bottom_right, fn _ -> nil end))}
        end

      # Top and bottom strands provided
      [[top_left, top_right], [bottom_left, bottom_right]] ->
        {Enum.zip(bottom_left, top_left), Enum.zip(bottom_right, top_right)}
    end
    |> case do
      {left, right} -> {Enum.reverse(left), right}
    end
  end

  def bind(strand_list, index) do
    strand_list
    |> Enum.split(index + 1)
    |> case do
      {left, right} ->
        {Enum.zip(left, Enum.map(left, fn _ -> nil end)),
         Enum.zip(right, Enum.map(right, fn _ -> nil end))}
    end
    |> case do
      {left, right} -> {Enum.reverse(left), right}
    end
  end

  @doc """
  Converts a pair of strands to a list of strings.

  ## Examples

    iex> import Typogenetics.Strand
    iex> strands_to_strings(~B\"""
    ...> T-|-TC
    ...> AA|AAG
    ...> \""")
    ["AAAAG", "CT", "T"]
  """
  def strands_to_strings(strands) do
    strands
    |> case do
      {left, right} -> Enum.reverse(left) ++ right
    end
    |> Enum.unzip()
    |> case do
      {bottom, top} -> [bottom, Enum.reverse(top)]
    end
    |> Enum.flat_map(fn list ->
      list
      |> Enum.chunk_by(fn aa -> aa == nil end)
      |> Enum.reject(&Enum.member?(&1, nil))
      |> Enum.map(fn list ->
        list
        |> Enum.map(&Atom.to_string/1)
        |> Enum.join("")
      end)
    end)
  end

  def unbind(strands) do
    strands
    |> case do
      {left, right} -> Enum.reverse(left) ++ right
      otherwise -> otherwise
    end
    |> Enum.unzip()
    |> case do
      {bottom, top} -> [bottom, Enum.reverse(top)]
    end
    |> Enum.flat_map(fn list ->
      list
      |> Enum.chunk_by(fn aa -> aa == nil end)
      |> Enum.reject(&Enum.member?(&1, nil))
    end)
  end
end
