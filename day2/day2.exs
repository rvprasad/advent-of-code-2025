defmodule Day2 do
  require Integer

  def read_id_ranges(filename) do
    File.stream!(filename)
    |> Enum.to_list()
    |> Enum.map(&String.trim_trailing/1)
    |> hd()
    |> String.split(",")
    |> Enum.map(fn l ->
      String.split(l, "-") |> Enum.map(&String.to_integer/1)
    end)
  end

  def find_invalid_ids([l, h]) do
    Enum.to_list(l..h)
    |> Enum.map(&Integer.to_string/1)
    |> Enum.filter(&Integer.is_even(String.length(&1)))
    |> Enum.filter(fn s ->
      {a, b} = String.split_at(s, div(String.length(s), 2))
      a == b
    end)
    |> Enum.map(&String.to_integer/1)
  end

  def solve_part_1(id_ranges) do
    id_ranges |> Enum.flat_map(&Day2.find_invalid_ids/1) |> Enum.sum()
  end
end

filename = System.argv() |> List.first()
Day2.read_id_ranges(filename) |> Day2.solve_part_1() |> IO.puts()
