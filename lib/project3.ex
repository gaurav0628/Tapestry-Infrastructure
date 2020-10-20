defmodule Project3Application do
  def start(_type, _args) do

    children = [
      Register,
      Simulator,
      NodeCreator
    ]

    opts = [strategy: :one_for_one, name: Project3Application.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
