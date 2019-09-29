defmodule Colony do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, {:ok, opts[:state]}, opts)
  end

  def init({:ok, state}) do
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
end