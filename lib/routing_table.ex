defmodule RoutingTable do
  @moduledoc false
  require Logger

  #Creates a 2D table for storing routing table
  def create_table(number_of_rows, number_of_columns) do
    List.duplicate("", number_of_columns)
    |> List.duplicate(number_of_rows)
  end

  def set_cell_value(table, self_hash_id, other_node_hash_id) do
    #Logger.info("Self: #{self_hash_id}")
    #Logger.info("Other: #{other_node_hash_id}")
    x = find_max_index_of_prefix_match([self_hash_id, other_node_hash_id])
    #Logger.info("x: #{x}")
    y = elem(Integer.parse(String.at(other_node_hash_id, x), 16), 0)
    #Logger.info("y: #{y}")
    List.replace_at(
      table,
      x,
      List.replace_at(Enum.at(table, x), y, other_node_hash_id)
    )
  end

  def get_cell_value(table, self_hash_id, other_node_hash_id) do
    x = find_max_index_of_prefix_match([self_hash_id, other_node_hash_id])
    y = elem(Integer.parse(String.at(other_node_hash_id, x), 16), 0)
    table
    |> Enum.at(x)
    |> Enum.at(y)
  end

  def get_cell_value_using_indices(table, x, y) do
    table
    |> Enum.at(x)
    |> Enum.at(y)
  end

  #Calculates the length of the max matching prefix
  def find_max_index_of_prefix_match(hash_values) do
    min = Enum.min(hash_values)
    max = Enum.max(hash_values)
    index = Enum.find_index(0..String.length(min), fn pointer -> String.at(min, pointer) != String.at(max, pointer) end)
    if index, do: index, else: String.length(Enum.at(hash_values, 0))
  end

end