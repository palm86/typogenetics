defmodule Typogenetics.Enzyme do
  require Logger

  @type amino_acid ::
          :cut
          | :del
          | :swi
          | :mvr
          | :mvl
          | :cop
          | :off
          | :ina
          | :inc
          | :ing
          | :int
          | :rpy
          | :rpu
          | :lpy
          | :lpu
  @type enzyme :: list(amino_acid)
  @type base :: :A | :C | :G | :T

  @spec determine_binding_preference(enzyme) :: base
  defp determine_binding_preference(enzyme) do
    inner_amino_acids =
      enzyme
      |> tl()
      |> Enum.reverse()
      |> case do
        [] ->
          []

        otherwise ->
          otherwise
          |> tl()
          |> Enum.reverse()
      end

    Enum.reduce(inner_amino_acids, :A, fn amino_acid, acc ->
      case {acc, Typogenetics.AminoAcid.kink(amino_acid)} do
        {x, :straight} -> x
        {:C, :left} -> :T
        {:C, :right} -> :A
        {:A, :left} -> :C
        {:A, :right} -> :G
        {:T, :left} -> :G
        {:T, :right} -> :C
        {:G, :left} -> :A
        {:G, :right} -> :T
      end
    end)
  end

  # TODO, this raises if the preference is not present in the strand
  defp choose_random_binding_site(strand, preference) do
    strand
    |> Enum.with_index()
    |> Enum.filter(fn {base, _index} -> base == preference end)
    |> Enum.random()
    |> case do
      {_base, index} -> index
    end
  end

  @spec execute(Typogenetics.Strand.unbound_strand(), enzyme) ::
          {list(Typogenetics.Strand.unbound_strand()), list(enzyme)}
  def execute(strand, enzyme) do
    modes = [copy: false, cuts: []]

    binding_preference = determine_binding_preference(enzyme)

    if binding_preference in strand do
      binding_site = choose_random_binding_site(strand, binding_preference)
      bound_strands = Typogenetics.Strand.bind(strand, binding_site)

      {bound_strands, modes} =
        enzyme
        |> Enum.reduce_while({bound_strands, modes}, fn amino_acid, {strands, modes} ->
          case apply(Typogenetics.AminoAcid, amino_acid, [strands, modes]) do
            {cont_or_halt, strands, modes} -> {cont_or_halt, {strands, modes}}
          end
        end)

      unbound_strands = Typogenetics.Strand.unbind(bound_strands)

      unbound_strands_from_cuts =
        modes[:cuts]
        |> Enum.flat_map(&Typogenetics.Strand.unbind/1)

      # return all the produced strands, but consume the enzyme
      {unbound_strands ++ unbound_strands_from_cuts, []}
    else
      Logger.info("Returned: " <> Enum.join(strand, ""))
      {[strand], [enzyme]}
    end
  end
end
