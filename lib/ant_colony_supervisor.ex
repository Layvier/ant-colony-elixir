defmodule AntColonySupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    IO.puts("booting processes")
    # TODO : Get graph from file
    graph = [
      [1,2,1],
      [2,1,2],
      [3,2,1]
    ]
    pheromons = [
      [1/3,1/3,1/3],
      [1/3,1/3,1/3],
      [1/3,1/3,1/3],
    ]
    initial_state = %{
      graph: graph,
      pheromons: pheromons
    }
    children = [
      {PheromonTrails, name: PheromonTrails, state: initial_state},
      {Colony, name: Colony, state: initial_state},
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
