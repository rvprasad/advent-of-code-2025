defmodule Day8 do
  def read_coordinates(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.map(fn l -> String.split(l, ",") |> Enum.map(&String.to_integer/1) end)
    |> Enum.to_list()
  end

  defp distance([vx, vy, vz], [ux, uy, uz]) do
    :math.sqrt(:math.pow(vx - ux, 2) + :math.pow(vy - uy, 2) + :math.pow(vz - uz, 2))
  end

  defp generate_edges(coordinates) do
    for {v, vi} <- Enum.with_index(coordinates),
        {u, ui} <- Enum.with_index(coordinates),
        vi < ui do
      {v, u, distance(v, u)}
    end
    |> Enum.sort(&(elem(&1, 2) <= elem(&2, 2)))
  end

  defp connect_components_with_edge({u, v, _}, node2comp) do
    updates =
      case {Map.has_key?(node2comp, u), Map.has_key?(node2comp, v)} do
        {false, false} ->
          comp = MapSet.new([u, v])
          %{u => comp, v => comp}

        {true, false} ->
          comp = node2comp |> Map.get(u) |> MapSet.put(v)
          comp |> Enum.reduce(%{}, &Map.put(&2, &1, comp))

        {false, true} ->
          comp = node2comp |> Map.get(v) |> MapSet.put(u)
          comp |> Enum.reduce(%{}, &Map.put(&2, &1, comp))

        {true, true} ->
          if node2comp |> Map.get(u) |> MapSet.member?(v) do
            %{}
          else
            comp = MapSet.union(Map.get(node2comp, u), Map.get(node2comp, v))
            comp |> Enum.reduce(%{}, &Map.put(&2, &1, comp))
          end
      end

    Map.merge(node2comp, updates)
  end

  def solve_part_1(coordinates, n) do
    coordinates
    |> generate_edges()
    |> Enum.take(n)
    |> Enum.reduce(%{}, &connect_components_with_edge/2)
    |> Map.values()
    |> Enum.uniq()
    |> Enum.map(&MapSet.size/1)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(3)
    |> Enum.product()
  end

  def solve_part_2(coordinates) do
    num_coords = coordinates |> Enum.count()

    {_, {[vx, _, _], [ux, _, _], _}} =
      coordinates
      |> generate_edges()
      |> Enum.reduce({%{}, nil}, fn e, acc ->
        {node2comp, final_edge} = acc

        case final_edge do
          nil ->
            new_node_2_comp = connect_components_with_edge(e, node2comp)

            final_edge_found =
              new_node_2_comp |> Map.values() |> hd |> MapSet.size() == num_coords

            {new_node_2_comp, if(final_edge_found, do: e, else: nil)}

          _ ->
            acc
        end
      end)

    vx * ux
  end
end

filename = System.argv() |> List.first()
n = System.argv() |> List.last() |> String.to_integer()
coordinates = Day8.read_coordinates(filename)
coordinates |> Day8.solve_part_1(n) |> IO.puts()
coordinates |> Day8.solve_part_2() |> IO.puts()
