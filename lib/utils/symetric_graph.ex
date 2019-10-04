defmodule SymetricGraph do
  # TODO: Use struct, to pattern match + add n + ensure the functions are only used with the correct struct
  def new do
    %{}
  end

  def new(n, default_value) do
    for a <- 0..(n - 1), b <- 0..(n - 1), a <= b, into: SymetricGraph.new do
      {{a, b}, default_value}
    end  
  end

  def get_value(graph, i, j) when i > j do
    get_value(graph, j, i)
  end

  def get_value(graph, i, j) do
    Map.get(graph, {i, j})
  end

  def set_value(graph, i, j, value) when i > j do
    set_value(graph, j, i, value)
  end

  def set_value(graph, i, j, value) do
    Map.put(graph, {i, j}, value)
  end

  def get_row(graph, row) do
    graph 
    |> Enum.filter(fn({{i, j}, value}) -> i == row || j == row end)
    |> Enum.map(fn ({{i, j}, value}) -> 
      col = if i == row, do: j, else: i
      {col, value}
    end)
    |> Enum.sort(fn ({cola, _}, {colb, _}) -> cola < colb end)
    |> Enum.map(fn({col, value}) -> value end)
  end

  def apply_to_all(graph, transformation) do
    graph |> Enum.reduce(graph, fn ({{i, j}, value}, acc) -> Map.put(acc, {i,j}, transformation.(value)) end)
  end
end