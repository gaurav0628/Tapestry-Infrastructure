defmodule Simulator do
  @moduledoc "Simulator of a network which uses tapestry"

  use GenServer
  require Logger

  @module_name Simulator

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: @module_name)
  end

  def init(arg) do
    Process.send_after(self(), :start_tapestry, 0)
    {:ok, arg}
  end

  #simulates tapestry
  def handle_info(:start_tapestry, _args) do
    args = System.argv()
    number_of_nodes = String.to_integer(Enum.at(args, 0))
    number_of_messages = String.to_integer(Enum.at(args, 1))

    count_of_80_percent_nodes = trunc(number_of_nodes * 0.8)

    #Logger.info("number of nodes sent = #{number_of_nodes}")
    {_, all_hash_ids_of_80_nodes} = generate_hash_values(1..count_of_80_percent_nodes)

    map_hash_to_pid_80 = get_hash_to_pid_map(all_hash_ids_of_80_nodes)
    #Logger.info("Simulator starting to create routing table")

    #calculates the routing table for each node
    Enum.each(
      all_hash_ids_of_80_nodes,
      fn hash_id ->
        GenServer.cast(map_hash_to_pid_80[hash_id], {:calculate_routing_table, all_hash_ids_of_80_nodes, hash_id})
      end
    )


    :timer.sleep(5000)
    #Logger.info("Done creating table for 80 nodes")

    start_number = count_of_80_percent_nodes + 1
    #generating other 20 nodes
    {_, all_hash_ids_of_20_nodes} = generate_hash_values(start_number..number_of_nodes)
    map_hash_to_pid_20 = get_hash_to_pid_map(all_hash_ids_of_20_nodes)

    #Logger.info("Done creating 20 nodes")

    all_hash_ids = all_hash_ids_of_80_nodes ++ all_hash_ids_of_20_nodes

    #combining the two maps
    map_hash_to_pid = Map.merge(map_hash_to_pid_80, map_hash_to_pid_20)

    cool_table = :ets.new(:cool_table, [:named_table])
    :ets.insert(cool_table, {:number, all_hash_ids_of_80_nodes})

    Enum.each(
      all_hash_ids_of_20_nodes,
      fn hash_id ->
        temp_hash_ids = :ets.lookup_element(cool_table, :number, 2) ++ [hash_id]
        #Logger.info("After adding element #{length(temp_hash_ids)}")
        GenServer.cast(map_hash_to_pid[hash_id], {:calculate_routing_table, temp_hash_ids, hash_id})
        :ets.insert(cool_table, {:number, temp_hash_ids})
      end
    )

    #Logger.info("Done creating table for 20 nodes")


    #all_hash_ids_in_ets = :ets.lookup_element(cool_table, :number, 2)

    #Logger.info("ETS list size #{length(all_hash_ids_in_ets)}")

    #Logger.info("Simulator done creating routing table")

    Register.set_number_of_nodes(length(Map.keys(map_hash_to_pid)) * number_of_messages)

    #Start sending messages
    Enum.each(
      all_hash_ids,
      fn hash_id ->
        Enum.each(
          1..number_of_messages,
          fn _ ->
            GenServer.cast(
              map_hash_to_pid[hash_id],
              {:route_message, hash_id, Enum.random(all_hash_ids), 1, map_hash_to_pid}
            )
          end
        )
      end
    )
    {:noreply, args}
  end

  def get_hash_to_pid_map(hash_ids) do
    hash_to_pid_map = Enum.reduce(
      hash_ids,
      %{},
      fn (hash_value, temp_map) -> (
                                     {hash_value, pid} = NodeCreator.start_node(hash_value)
                                     temp_map = Map.put(temp_map, hash_value, pid)
                                     temp_map
                                     )
      end
    )
    hash_to_pid_map
  end

  #Generates the 40 digit hash values using SHA algorithm
  def generate_hash_values(range) do
    #Logger.info("In generate hash values")
    node_id_to_hash_id_map = Enum.reduce(
      range,
      %{},
      fn (node_id, temp_map) -> (
                                  hash_value = :crypto.hash(:sha, "#{node_id}")
                                               |> Base.encode16()
                                  temp_map = Map.put(temp_map, node_id, hash_value)
                                  temp_map
                                  )
      end
    )
    #Logger.info("Generated hash values")
    all_hash_ids = Map.values(node_id_to_hash_id_map)
    #Logger.info("Size of hash ID list #{length(all_hash_ids)}")
    {node_id_to_hash_id_map, all_hash_ids}
  end



end