defmodule Typogenetics.Base do
  @type base :: :A | :C | :G | :T

  @spec complement(base) :: base
  def complement(:A), do: :T
  def complement(:T), do: :A
  def complement(:C), do: :G
  def complement(:G), do: :C
end
