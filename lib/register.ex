defmodule Register do
  @moduledoc "Stores the number of nodes that are currently executing"

  use GenServer
  require Logger

  @module_name Register

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @module_name)
  end

  def init(_opts) do
    {:ok, {0, 0, 0}}
  end

  def decrement_node_count() do
    GenServer.cast(@module_name, :decrement_node_count)
  end

  def set_hop_count(hop_count) do
    GenServer.cast(@module_name, {:set_hop_count, hop_count})
  end

  def set_number_of_nodes(number_of_nodes) do
    GenServer.cast(@module_name, {:set_number_of_nodes, number_of_nodes})
  end

  def handle_cast({:set_number_of_nodes, number_of_nodes}, state) do
    {_, count, hop_count} = state
    {:noreply, {number_of_nodes, count, hop_count}}
  end

  def handle_cast({:set_hop_count, new_hop_count}, {number_of_nodes, count, hop_count}) do
    if new_hop_count > hop_count do
      #Logger.info("Setting hop count #{new_hop_count}")
      {:noreply, {number_of_nodes, count, new_hop_count}}
    else
      {:noreply, {number_of_nodes, count, hop_count}}
    end
  end

  def handle_cast(:decrement_node_count, {number_of_nodes, count, hop_count}) do
    if number_of_nodes == count + 1 do
      IO.puts "#{hop_count}"
      System.halt(0)
    end
    {:noreply, {number_of_nodes, count + 1, hop_count}}
  end
end