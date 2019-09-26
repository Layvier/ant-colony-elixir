defmodule Colony do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, {:ok, opts[:state]}, opts)
  end

  def init({:ok, state}) do
    IO.inspect(state)
    children = [
      %{
        id: 1,
        start: {Ant, :start_link, [[name: String.to_atom("ant_1"), state: state]]}
      },
      %{
        id: 2,
        start: {Ant, :start_link, [[name: String.to_atom("ant_2"), state: state]]}
      },
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

  def handle_call({:pheromons_updated, pheromons}, state) do
    IO.puts("received")
    IO.inspect(state)
  end

  def cast_new_pheromon_trails(pheromons) do
    IO.puts("cast colony")
    GenServer.cast(__MODULE__, {:pheromons_updated, pheromons})
  end
end