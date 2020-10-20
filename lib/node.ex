defmodule Tapestry.Node do
  @moduledoc "This is the tapestry node"

  use GenServer
  require Logger

  def start_link(hash_id) do
    {:ok, pid} = GenServer.start_link(__MODULE__, hash_id)
    {hash_id, pid}
  end

  def init(hash_id) do
    #Logger.info("My Hash ID: #{hash_id}")
    routing_table_map = RoutingTable.create_table(40, 16)
    #Logger.info("Created routing table: #{length(routing_table_map)}")
    #Logger.info("Created routing table column length: #{length(Enum.at(routing_table_map, 0))}")
    {:ok, {hash_id, routing_table_map, 0}}
  end

  #initialises the routing table for a node
  def handle_cast(
        {:calculate_routing_table, hash_list, my_hash_id},
        {hash_id, routing_table_map, messages_to_be_send}
      ) do
    #    Logger.info("In Node creating table #{my_hash_id} #######################################################")
    routing_table = Enum.reduce(
      hash_list,
      routing_table_map,
      fn (entry, temp_table) -> (
                                  cond do
                                    (String.equivalent?(entry, my_hash_id) == false) ->
                                      #Logger.info("Adding entry: #{entry}")
                                      temp_table = RoutingTable.set_cell_value(temp_table, my_hash_id, entry)
                                    true ->
                                      #Logger.info("Not Adding entry: #{entry}")
                                      temp_table
                                  end
                                  )
      end
    )
    #    Enum.each(
    #      0..7,
    #      fn
    #        x ->
    #          Enum.each(
    #            0..15,
    #            fn y -> Logger.info("#{x}, #{y}: #{RoutingTable.get_cell_value_using_indices(routing_table, x, y)}") end
    #          )
    #      end
    #    )
    #    Logger.info("Done creating table #{my_hash_id} #######################################################")
    {:noreply, {hash_id, routing_table, messages_to_be_send}}
  end

#  def handle_cast({:check_table, test}, {hash_id, routing_table_map, messages_to_be_send}) do
#    #Logger.info("Node checking table #{hash_id} #######################################################")
#    Enum.each(
#      0..7,
#      fn
#        x ->
#          Enum.each(
#            0..15,
#            fn y ->
#              Logger.info(
#                "#{hash_id} #{x}, #{y}: #{RoutingTable.get_cell_value_using_indices(routing_table_map, x, y)}"
#              )
#            end
#          )
#      end
#    )
#    #Logger.info("Node checking table done #{hash_id} #######################################################")
#    {:noreply, {hash_id, routing_table_map, messages_to_be_send}}
#  end

  #method responsible for routing the message to other nodes
  def handle_cast(
        {:route_message, source_hash_value, destination_hash_value, hop_count, hash_id_to_pid_map},
        {hash_id, routing_table_map, messages_to_be_send}
      ) do
    #Logger.info("Self: #{source_hash_value}")
    #Logger.info("#{source_hash_value} Other: #{destination_hash_value}")
    try do
      if String.equivalent?(source_hash_value, destination_hash_value) == false do
        x = RoutingTable.find_max_index_of_prefix_match([source_hash_value, destination_hash_value])
        #Logger.info("#{source_hash_value} #{destination_hash_value} x: #{x}")
        y = elem(Integer.parse(String.at(destination_hash_value, x), 16), 0)
        #Logger.info("y: #{y}")
        next_destination_value = RoutingTable.get_cell_value_using_indices(routing_table_map, x, y)
        #Logger.info("next_destination_value: #{next_destination_value}")
        #Logger.info("destination_hash_value: #{destination_hash_value}")
        if next_destination_value != "" do
          cond do
            (String.equivalent?(destination_hash_value, next_destination_value) == true) ->
              #Logger.info("#{source_hash_value} Last hop count: #{hop_count}")
              Register.set_hop_count(hop_count)
              Register.decrement_node_count()
            true ->
              #Logger.info("Sending node to next node: #{next_destination_value}")
              GenServer.cast(
                hash_id_to_pid_map[next_destination_value],
                {:route_message, next_destination_value, destination_hash_value, hop_count + 1, hash_id_to_pid_map}
              )
            #Logger.info("Sent message to next node: #{next_destination_value}")
          end
        else
          Register.decrement_node_count()
        end
      else
        Register.decrement_node_count()
      end
    rescue
      error -> Logger.info("In routing table creation #{source_hash_value} #{destination_hash_value} #{error}")
    end
    {:noreply, {hash_id, routing_table_map, messages_to_be_send}}
  end

end