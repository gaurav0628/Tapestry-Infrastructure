  defmodule NodeCreator do
  @moduledoc false

  use DynamicSupervisor
  require Logger

  @module_name NodeCreator

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: @module_name)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_node(hash_value) do
    #Logger.info("Generating node NodeCreator: #{hash_value}")
    {_, pid} = DynamicSupervisor.start_child(@module_name, {Tapestry.Node, hash_value})
    pid
  end

end