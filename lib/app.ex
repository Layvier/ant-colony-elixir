defmodule App do
  use Application

  def start(_type, _args) do
    
    # Although we don't use the supervisor name below directly,
    # it can be useful when debugging or introspecting the system.
    {graph, n} = read_instance("a280")
    AntColonySupervisor.start_link(name: AntColonySupervisor, graph: graph, n: n)
  end

  def read_instance(filename) do
    {:ok, body} = File.read("./instances/a280.tsp")
    n = 280
    points_coord = String.split(body, "\n") 
      |> Enum.slice(6, n) 
      |> Enum.map(fn (point) -> 
        [_, i, j] = String.split(point)
        {String.to_integer(i), String.to_integer(j)}
      end)
    
    # graph = SymetricGraph.new

    graph = for a <- 0..(n - 1), b <- 0..(n - 1), a <= b, into: SymetricGraph.new do
      {i_a, j_a} = Enum.at(points_coord, a)
      {i_b, j_b} = Enum.at(points_coord, b)
      {{a, b}, :math.sqrt( :math.pow(i_a - i_b, 2) + :math.pow(j_a - j_b, 2))}
    end
    IO.inspect(graph)
    {graph, n}
  end
end