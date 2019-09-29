defmodule Ant do
  use GenServer

  def start_link(opts) do
    IO.puts("Starting " <> Atom.to_string(opts[:name]))
    GenServer.start_link(__MODULE__, {:ok, opts[:state]}, opts)
  end

  def init({:ok, state}) do
    state = Map.put(state, :path, [0])
    state = Map.put(state, :path_cost, 0)
    
    {:ok, walk(state)}
  end

  def walk(state) do
    start_time_ms = :os.system_time(:millisecond)
    new_state = rec_walk_next_node(state, Enum.to_list(1..(state[:n] - 1)))
    done_walking_time_ms = :os.system_time(:millisecond)
    IO.puts(done_walking_time_ms - start_time_ms)
    IO.puts(new_state[:path_cost])
    new_pheromons = PheromonTrails.send_ant_path(new_state[:path], new_state[:path_cost])
    IO.puts(:os.system_time(:millisecond) - done_walking_time_ms)
    walk(%{new_state | pheromons: new_pheromons , path_cost: 0 , path: [0]})
  end


  def rec_walk_next_node(state, []) do
    current_node = List.last(state[:path])
    new_node = 0
    new_path = state[:path] ++ [ new_node ]
    new_cost = state[:path_cost] + SymetricGraph.get_value(state[:graph], current_node, new_node)
    %{%{state | path: new_path} | path_cost: new_cost}
  end

  def rec_walk_next_node(state, nodes_left) do
    # IO.puts("walk next node")
    current_node = List.last(state[:path])
    # IO.puts("current node #{current_node}")
    new_node = choose_next_node(SymetricGraph.get_row(state[:pheromons], current_node), nodes_left)
    
    new_path = state[:path] ++ [ new_node ]
    new_cost = state[:path_cost] + SymetricGraph.get_value(state[:graph], current_node, new_node)
    rec_walk_next_node(%{%{state | path: new_path} | path_cost: new_cost}, Enum.filter(nodes_left, fn (n) -> n != new_node end))
  end

  def choose_next_node(pheromons_next_node, nodes_left) do
    pheromons_left = Enum.map(Range.new(0, Enum.count(pheromons_next_node) - 1), fn(i) -> if Enum.member?(nodes_left, i), do: Enum.at(pheromons_next_node, i), else: 0 end)
    total_pheromons = Enum.reduce(pheromons_left, 0, fn (p, a) -> p + a end)
    
    buckets = Enum.reduce(pheromons_left, [], fn (p, acc) -> acc ++ [(List.last(acc) || 0) + p / total_pheromons] end)
    # pick a number between 0 and 1
    random_value = :rand.uniform()
    {_, _, found} = Enum.reduce(buckets, {0, 0, nil}, fn (next, {ind, prev, found}) -> if (prev <= random_value and random_value < next), do: {ind + 1, next, ind}, else: {ind + 1, next, found} end)#if (prev <= random_value and random_value <= next), do: {ind++, next, ind}, else: {ind++, next, found} end)
    found
  end
end