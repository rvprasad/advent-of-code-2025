defmodule Day2 do
  def read_ranges(filename) do
    File.stream!(filename)
    |> Enum.to_list()
    |> Enum.map(&String.trim_trailing/1)
    |> hd()
    |> String.split(",")
    |> Enum.map(fn l ->
      String.split(l, "-")
    end)
  end

  def find_invalid_ids([l, h], is_invalid) do
    Enum.to_list(String.to_integer(l)..String.to_integer(h))
    |> Enum.map(&Integer.to_string/1)
    |> Enum.filter(is_invalid)
    |> Enum.map(&String.to_integer/1)
  end

  def is_invalid_1(s) do
    {a, b} = String.split_at(s, div(String.length(s), 2))
    a == b
  end

  def is_invalid_2(s) do
    s_len = String.length(s)

    s_len > 1 &&
      Enum.to_list(1..div(s_len, 2))
      |> Enum.any?(fn l ->
        String.graphemes(s)
        |> Enum.chunk_every(l)
        |> MapSet.new()
        |> MapSet.size() == 1
      end)
  end

  def solve_puzzle(id_ranges, is_invalid) do
    id_ranges
    |> Enum.flat_map(&Day2.find_invalid_ids(&1, is_invalid))
    |> Enum.sum()
  end
end

filename = System.argv() |> List.first()
ranges = Day2.read_ranges(filename)
ranges |> Day2.solve_puzzle(&Day2.is_invalid_1/1) |> IO.puts()
ranges |> Day2.solve_puzzle(&Day2.is_invalid_2/1) |> IO.puts()
