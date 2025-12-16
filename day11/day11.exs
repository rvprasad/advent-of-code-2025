defmodule Day11 do
  def read_graph(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.map(fn l ->
      [hd | tl] = String.split(l, " ")
      {String.replace(hd, ":", ""), MapSet.new(tl)}
    end)
    |> Map.new()
  end

  defp dfs(src, trg, node_2_path_count, graph) do
    if Map.get(graph, src) do
      succs = Map.get(graph, src)

      succs
      |> Enum.reject(&Map.get(node_2_path_count, &1))
      |> Enum.reduce(Map.put(node_2_path_count, src, 0), fn n, acc ->
        dfs(n, trg, acc, graph)
      end)
      |> then(fn m ->
        Map.put(
          m,
          src,
          (succs |> Enum.map(&Map.get(m, &1)) |> Enum.sum()) +
            if(MapSet.member?(succs, trg), do: 1, else: 0)
        )
      end)
    else
      node_2_path_count
    end
  end

  def solve_part_1(graph) do
    dfs("you", "out", %{"out" => 0}, graph) |> Map.get("you")
  end

  def solve_part_2(graph) do
    helper = fn nodes ->
      last_node = List.last(nodes)

      nodes
      |> Enum.zip(Enum.drop(nodes, 1))
      |> Enum.map(fn {a, b} ->
        dfs(a, b, %{b => 0, last_node => 0}, graph)
        |> Map.get(a)
      end)
      |> Enum.product()
    end

    helper.(["svr", "dac", "fft", "out"]) + helper.(["svr", "fft", "dac", "out"])
  end
end

filename = System.argv() |> List.first()
graph = Day11.read_graph(filename)
Day11.solve_part_1(graph) |> IO.puts()
Day11.solve_part_2(graph) |> IO.puts()
