defmodule AntColonySupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, {:ok, opts[:graph], opts[:n]}, opts)
  end

  def init({:ok, graph, n}) do
    pheromons = SymetricGraph.new(n, 1/(n - 1))

    initial_state = %{
      graph: graph,
      pheromons: pheromons,
      n: n,
      nb_ants: 5
    }
    children = [
      {PheromonTrails, name: PheromonTrails, state: initial_state},
      {Colony, name: Colony, state: initial_state},
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
