defmodule AntColony.Application do
  use Application

  def start(_type, _args) do
    {graph, n} = read_instance(System.get_env("INSTANCE") || "berlin52")
    AntColony.RootSupervisor.start_link(name: AntColony.RootSupervisor, graph: graph, n: n)
  end

  def read_instance(filename) do
    {:ok, body} = File.read("./instances/#{filename}.tsp")
    lines = String.split(body, "\n")

    points_coord = lines
      |> Enum.drop(6)
      |> Enum.drop(-1)
      |> Enum.map(&parse_point/1)

    # n = Enum.count(points_coord)

    graph = for a <- 0..(n - 1), b <- 0..(n - 1), a <= b, into: SymetricGraph.new do
      {i_a, j_a} = Enum.at(points_coord, a)
      {i_b, j_b} = Enum.at(points_coord, b)
      {{a, b}, :math.sqrt( :math.pow(i_a - i_b, 2) + :math.pow(j_a - j_b, 2))}
    end
    {graph, n}
  end

  def parse_point(point) do
    [_, i, j] = String.split(point)
    try do
      {String.to_float(i), String.to_float(j)}
    rescue
      e in ArgumentError -> {String.to_integer(i), String.to_integer(j)}
    end
  end
end