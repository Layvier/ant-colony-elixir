defmodule PheromonTrails do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:state], name: opts[:name])
  end

  def init(state) do
    IO.puts("starting Colony")
    {:ok, Map.put(state, :counter, 0)}
  end

  def handle_info({:message, message}, state) do
    IO.puts(state)
    {:noreply, state <> "_" <> message}
  end

  def handle_call({:new_ant_path, path, cost}, _from, state) do
    new_pheromons = rec_add_next_pheromon(evaporate_pheromons(state[:pheromons]), path, cost)
    new_counter = state[:counter] + 1
    new_state = %{state | pheromons: new_pheromons}
    IO.inspect(new_pheromons)
    {:reply, new_pheromons, %{new_state | counter: new_counter}}
  end

  def evaporate_pheromons(pheromons) do
    Enum.map(pheromons, fn(pheromon_line) -> Enum.map(pheromon_line, fn (cell) -> evaporate(cell) end) end)
  end

  def evaporate(cell) do
    cell * 0.95
  end

  def rec_add_next_pheromon(pheromons, [0], cost) do
    pheromons
  end

  def rec_add_next_pheromon(pheromons, path, cost) do
    [i | new_path] = path
    new_pheromons = set_pheromon_value(pheromons, i, List.first(new_path), cost)
    rec_add_next_pheromon(new_pheromons, new_path, cost)
  end

  def send_ant_path(path, cost) do
    GenServer.call(__MODULE__, {:new_ant_path, path, cost})
  end

  def set_pheromon_value(pheromons, i, j, value) do
    # TODO: Calculate graph value according to one of the official algorithm formula
    current_pheromon_value = get(pheromons, i, j)
    new_pheromon_value = current_pheromon_value + (1 - current_pheromon_value)*(1 / value)
    new_row = List.replace_at(Enum.at(pheromons, i), j, new_pheromon_value)
    new_pheromons = List.replace_at(pheromons, i, new_row)
    new_pheromons
  end

  def get(matrix, i, j) do
    Enum.at(Enum.at(matrix, i), j)
  end
end