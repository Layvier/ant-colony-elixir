defmodule App do
  use Application

  def start(_type, _args) do
    # Although we don't use the supervisor name below directly,
    # it can be useful when debugging or introspecting the system.
    IO.puts("starting")
    AntColonySupervisor.start_link(name: AntColonySupervisor)
  end
end