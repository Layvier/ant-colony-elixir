defmodule AntColonySupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, {:ok, opts[:graph], opts[:n]}, opts)
  end

  def init({:ok, graph, n}) do
    IO.puts("booting processes")

    pheromons = SymetricGraph.new(n, 1/(n - 1))

    # n = 3
    # graph = for a <- 0..(n - 1), b <- 0..(n - 1), a <= b, into: SymetricGraph.new do
    #   {{a, b}, 1}
    # end
    pheromons = for a <- 0..(n - 1), b <- 0..(n - 1), a <= b, into: SymetricGraph.new do
      {{a, b}, 1/3}
    end

    initial_state = %{
      graph: graph,
      pheromons: pheromons,
      n: n
    }
    children = [
      {PheromonTrails, name: PheromonTrails, state: initial_state},
      {Colony, name: Colony, state: initial_state},
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
