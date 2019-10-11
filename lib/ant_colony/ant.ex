defmodule AntColony.Ant do
  use GenServer

  def start_link(state, opts \\ []) do
    IO.puts("Starting " <> Atom.to_string(opts[:name]))
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    initial_state = Map.merge(state, %{ path: [0], path_cost: 0 })
    {:ok, walk(initial_state)}
  end

  def walk(state) do
    new_state = rec_walk_next_node(state, Enum.to_list(1..(state[:n] - 1)))
    # yo
    AntColony.PheromonTrails.send_ant_path(self(), new_state[:path], new_state[:path_cost])
    new_state
  end

  def handle_cast({:walk, new_pheromons}, state) do
    # 3
    new_state = walk(%{state | pheromons: new_pheromons , path_cost: 0 , path: [0]})
    {:noreply, new_state}
  end

  def rec_walk_next_node(state, []) do
    current_node = List.last(state[:path])
    new_node = 0
    new_path = state[:path] ++ [ new_node ]
    # 4
    new_cost = state[:path_cost] + SymetricGraph.get_value(state[:graph], current_node, new_node)
    %{%{state | path: new_path} | path_cost: new_cost}
  end

  def rec_walk_next_node(state, nodes_left) do
    #conflict
    #
    #oh no a conflict !!
    current_node = List.last(state[:path])
    new_node = choose_next_node(SymetricGraph.get_row(state[:pheromons], current_node), SymetricGraph.get_row(state[:graph], current_node), nodes_left)
    
    new_path = state[:path] ++ [ new_node ]
    new_cost = state[:path_cost] + SymetricGraph.get_value(state[:graph], current_node, new_node)
    rec_walk_next_node(%{%{state | path: new_path} | path_cost: new_cost}, Enum.filter(nodes_left, fn (n) -> n != new_node end))
  end

  def choose_next_node(pheromon_next_nodes, distance_next_nodes, nodes_left) do
    # use real formula, including desirability
    next_nodes_probabilities_unnormalized = Range.new(0, Enum.count(pheromon_next_nodes) - 1)
      |> Enum.map(fn(i) -> if Enum.member?(nodes_left, i), do: Enum.at(pheromon_next_nodes, i) / (Enum.at(distance_next_nodes, i) + 1), else: 0 end) # 

    normalizer = Enum.reduce(next_nodes_probabilities_unnormalized, 0, fn (p, a) -> p + a end)
    buckets = Enum.reduce(next_nodes_probabilities_unnormalized, [], fn (p, acc) -> acc ++ [(List.last(acc) || 0) + p / normalizer] end)
    # pick a number between 0 and 1
    random_value = :rand.uniform()
    {_, _, found} = Enum.reduce(buckets, {0, 0, nil}, fn (next, {ind, prev, found}) -> if (prev <= random_value and random_value < next), do: {ind + 1, next, ind}, else: {ind + 1, next, found} end)
    found
  end
end