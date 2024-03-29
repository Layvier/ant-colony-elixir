defmodule AntColony.Colony do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, {:ok, opts[:state]}, opts)
  end

  def init({:ok, state}) do
    children = Range.new(1, state.nb_ants)
      |> Enum.map(fn(ant_id) -> 
        %{
        id: ant_id,
        start: {AntColony.Ant, :start_link, [state, [name: String.to_atom("ant_#{ant_id}")]]}
      } 
    end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end