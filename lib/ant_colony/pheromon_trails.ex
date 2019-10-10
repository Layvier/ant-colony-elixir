defmodule AntColony.PheromonTrails do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:state], name: opts[:name])
  end

  def init(%{pheromons: pheromons, nb_ants: nb_ants}) do
    IO.puts("starting Colony")
    {:ok, %{
      pheromons: pheromons,
      counter: 0 ,
      evaporation_rate: 0.005 ,
      nb_ants: nb_ants,
      best_solution: nil
      }}
  end

  def handle_cast({:new_ant_path, path, cost, from}, state) do
    new_pheromons = state[:pheromons] 
      |> evaporate_pheromons(state[:evaporation_rate], state[:nb_ants]) 
      |> rec_add_next_pheromon(path, cost)

    GenServer.cast(from, {:walk, new_pheromons})
    new_counter = state[:counter] + 1
    new_state = %{state | pheromons: new_pheromons}
    {:noreply, %{new_state | counter: new_counter, best_solution: record_best_tour(state[:best_solution], path, cost)}}
  end

  def evaporate_pheromons(pheromons, evaporation_rate, nb_ants) do
    # not exactly as real formula, since we don't wait for all ants to finish
    SymetricGraph.apply_to_all(pheromons, fn (pheromon_val) -> pheromon_val * (1 - evaporation_rate / nb_ants) end)
  end

  def rec_add_next_pheromon(pheromons, [0], cost) do
    pheromons
  end

  def rec_add_next_pheromon(pheromons, path, cost) do
    [i | new_path] = path
    new_pheromons = set_pheromon_value(pheromons, i, List.first(new_path), cost)
    rec_add_next_pheromon(new_pheromons, new_path, cost)
  end

  def send_ant_path(from, path, cost) do
    GenServer.cast(__MODULE__, {:new_ant_path, path, cost, from})
  end

  def set_pheromon_value(pheromons, i, j, path_cost) do
    current_pheromon_value = SymetricGraph.get_value(pheromons, i, j)
    SymetricGraph.set_value(pheromons, i, j, current_pheromon_value + 1 / path_cost)
  end

  def record_best_tour(current_best_solution, path, cost) do
    if current_best_solution == nil or cost < current_best_solution.cost do
      IO.puts("New best solution: #{cost}")
      IO.inspect(path)
      %{
        path: path,
        cost: cost
      }
    else
      current_best_solution
    end
  end
end