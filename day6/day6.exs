defmodule Day6 do
  def read_problems(filename) do
    content =
      File.stream!(filename)
      |> Enum.reverse()
      |> Enum.to_list()

    content
    |> List.first()
    |> then(&String.graphemes/1)
    |> Enum.with_index()
    |> Enum.reject(&(elem(&1, 0) == " "))
    |> Enum.map(&elem(&1, 1))
    |> then(&Enum.zip(Enum.drop(&1, -1), Enum.drop(&1, 1)))
    |> Enum.map(fn {l, h} ->
      content |> Enum.map(&String.slice(&1, l..(h - 1)))
    end)
  end

  def solve_part_1(problems) do
    problems
    |> Enum.map(fn [op | operands] ->
      f = if String.trim(op) == "*", do: &Enum.product/1, else: &Enum.sum/1

      operands
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&String.to_integer/1)
      |> then(&f.(&1))
    end)
    |> Enum.sum()
  end

  def solve_part_2(problems) do
    problems
    |> Enum.map(fn [hd | tl] ->
      [
        hd
        | tl
          |> Enum.reverse()
          |> Enum.map(&String.split(&1, ""))
          |> Enum.zip()
          |> Enum.map(&Tuple.to_list/1)
          |> Enum.map(&Enum.join/1)
      ]
    end)
    |> then(&solve_part_1/1)
  end
end

filename = System.argv() |> List.first()
problems = Day6.read_problems(filename)
Day6.solve_part_1(problems) |> IO.puts()
Day6.solve_part_2(problems) |> IO.puts()
