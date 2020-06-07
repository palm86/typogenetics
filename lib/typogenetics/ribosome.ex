defmodule Typogenetics.Ribosome do
  @codon_length 2

  @spec translate(Typogenetics.Strand.unbound_strand()) :: list(Typogenetics.Enzyme.enzyme())
  def translate(strand) do
    strand
    |> Enum.chunk_every(@codon_length, @codon_length, :discard)
    |> Enum.map(&do_translate/1)
    |> Enum.chunk_by(fn elem -> elem == :ter end)
    |> Enum.reject(&Enum.member?(&1, :ter))
  end

  defp do_translate([:A, :A]), do: :ter
  defp do_translate([:A, :C]), do: :cut
  defp do_translate([:A, :G]), do: :del
  defp do_translate([:A, :T]), do: :swi
  defp do_translate([:C, :A]), do: :mvr
  defp do_translate([:C, :C]), do: :mvl
  defp do_translate([:C, :G]), do: :cop
  defp do_translate([:C, :T]), do: :off
  defp do_translate([:G, :A]), do: :ina
  defp do_translate([:G, :C]), do: :inc
  defp do_translate([:G, :G]), do: :ing
  defp do_translate([:G, :T]), do: :int
  defp do_translate([:T, :A]), do: :rpy
  defp do_translate([:T, :C]), do: :rpu
  defp do_translate([:T, :G]), do: :lpy
  defp do_translate([:T, :T]), do: :lpu
end
