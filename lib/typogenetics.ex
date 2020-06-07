defmodule Typogenetics do
  require Logger

  def run() do
    Typogenetics.Worker.start_link([])
  end

  defmodule Worker do
    use GenServer

    def start_link(init_arg) do
      GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
    end

    def init(args) do
      :timer.send_interval(200, :tick)
      do_init(args)
    end

    defp do_init([]) do
      {:ok, {init_strands(), []}}
    end

    defp do_init(strands) when is_list(strands) do
      {:ok, {strands, []}}
    end

    defp init_strands() do
      Stream.repeatedly(fn ->
        Enum.random([:A, :C, :G, :T])
      end)
      |> Stream.chunk_every(20)
      |> Stream.take(200)
      |> Enum.to_list()
    end

    def handle_info(:tick, {[], enzymes}) do
      Logger.info("No more strands to catalyse.")
      {:stop, :normal, {[], enzymes}}
    end
    def handle_info(:tick, {strands, enzymes}) do
      {:noreply, Typogenetics.Engine.tick({strands, enzymes})}
    end
  end

  defmodule Engine do
    def tick({strands, []}) do
      [strand | strands] = Enum.shuffle(strands)
      enzymes = Typogenetics.Ribosome.translate(strand)

      {strands, enzymes}
    end

    def tick({[strand | strands], [enzyme | enzymes]}) do
      Logger.info("Consumed: " <> Enum.join(strand, ""))
      {new_strands, unused_enzymes} = Typogenetics.Enzyme.execute(strand, enzyme)

      for new_strand <- new_strands do
        Logger.info("Produced: " <> Enum.join(new_strand, ""))
      end

      {strands ++ new_strands, enzymes ++ unused_enzymes}
    end
  end
end
