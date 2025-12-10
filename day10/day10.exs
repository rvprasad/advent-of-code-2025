defmodule Day10 do
  def get_machines(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.map(fn l ->
      tmp = String.split(l, " ")

      lights =
        tmp
        |> hd()
        |> String.replace(~r/[\[\]]/, "")
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.filter(fn {e, _} -> e == "#" end)
        |> MapSet.new(&elem(&1, 1))

      buttons =
        tmp
        |> Enum.drop(1)
        |> Enum.drop(-1)
        |> Enum.map(fn s ->
          s
          |> String.replace(~r/[()]/, "")
          |> String.split(",")
          |> Enum.map(&String.to_integer/1)
          |> MapSet.new()
        end)
        |> Enum.uniq()
        |> Enum.to_list()

      voltages =
        tmp
        |> List.last()
        |> String.replace(~r/[{}]/, "")
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> Enum.to_list()

      %{buttons: buttons, lights: lights, voltages: voltages}
    end)
    |> Enum.to_list()
  end

  defp turn_lights_on(machine, work_list, n, seen) do
    if Enum.find(work_list, &(&1 == machine.lights)) do
      n
    else
      new_work_list =
        work_list
        |> Enum.flat_map(fn lights ->
          Enum.map(machine.buttons, &MapSet.symmetric_difference(&1, lights))
        end)
        |> MapSet.new()

      turn_lights_on(
        machine,
        new_work_list,
        n + 1,
        MapSet.union(new_work_list, seen)
      )
    end
  end

  def solve_part_1(machines) do
    machines
    |> Enum.map(&turn_lights_on(&1, [MapSet.new()], 0, MapSet.new()))
    |> Enum.sum()
  end

  defp transform_to_row_echelon_form([]) do
    []
  end

  defp transform_to_row_echelon_form([hd]) do
    [hd]
  end

  defp transform_to_row_echelon_form(matrix) do
    pivot_c_idx =
      matrix
      |> Enum.map(fn row -> Enum.find_index(row, &(&1 != 0)) end)
      |> Enum.min()

    [top_row | bottom] =
      matrix
      |> Enum.sort_by(fn r ->
        tmp = Enum.at(r, pivot_c_idx)
        num_non_zero_entries = r |> Enum.drop(-1) |> Enum.count(&(&1 != 0))
        {-abs(tmp), -tmp, num_non_zero_entries, List.last(r)}
      end)

    pivot_row =
      if Enum.at(top_row, pivot_c_idx) > 0, do: top_row, else: Enum.map(top_row, &(-&1))

    pivot_element = Enum.at(pivot_row, pivot_c_idx)

    [pivot_row] ++
      (bottom
       |> Enum.map(fn row ->
         scale = Enum.at(row, pivot_c_idx)
         row |> Enum.zip(pivot_row) |> Enum.map(fn {r, p} -> r * pivot_element - p * scale end)
       end)
       |> Enum.reject(fn r -> Enum.drop(r, -1) |> Enum.all?(&(&1 == 0)) end)
       |> transform_to_row_echelon_form())
  end

  defp scale_down_rows(matrix) do
    matrix
    |> Enum.map(fn row ->
      gcd = row |> Enum.reduce(&Integer.gcd/2)
      row |> Enum.map(&Integer.floor_div(&1, gcd))
    end)
  end

  defp find_free_vars_and_ranges(matrix) do
    pivot_vars =
      matrix
      |> Enum.map(fn r -> Enum.find_index(r, &(&1 != 0)) end)
      |> MapSet.new()

    0..((matrix |> hd() |> Enum.count()) - 2)
    |> Enum.reject(&Enum.member?(pivot_vars, &1))
    |> Enum.map(fn i ->
      limit =
        matrix
        |> Enum.filter(&(Enum.at(&1, i) != 0))
        |> Enum.map(&abs(List.last(&1)))
        |> Enum.reject(&(&1 == 0))
        |> Enum.max(fn -> 0 end)
        |> round()

      [i, 0..limit]
    end)
    |> Enum.reject(&(&1 |> List.last() |> Range.size() == 0))
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp back_substitute_and_extend_solution(matrix, solution) do
    matrix
    |> Enum.reverse()
    |> Enum.reduce(solution, fn row, acc ->
      idx = row |> Enum.find_index(&(&1 != 0))

      Map.put(
        acc,
        idx,
        (List.last(row) -
           (row
            |> Enum.drop(-1)
            |> Enum.with_index(&(&1 * Map.get(acc, &2, 0)))
            |> Enum.sum())) / Enum.at(row, idx)
      )
    end)
  end

  def cartesian_product(list) do
    case list do
      [hd] ->
        Stream.map(hd, &[&1])

      [hd | tl] ->
        Stream.flat_map(hd, fn i ->
          Stream.map(cartesian_product(tl), &[i | &1])
        end)
    end
  end

  def solve_part_2(machines) do
    machines
    |> Enum.map(fn machine ->
      matrix =
        machine.voltages
        |> Enum.with_index(fn v, v_i ->
          (machine.buttons
           |> Enum.map(&if Enum.member?(&1, v_i), do: 1, else: 0)
           |> Enum.to_list()) ++ [v]
        end)
        |> transform_to_row_echelon_form()
        |> scale_down_rows()

      case find_free_vars_and_ranges(matrix) do
        [free_vars, ranges] ->
          ranges
          |> cartesian_product()
          |> Enum.reduce(Integer.pow(2, 32), fn solution, acc ->
            if Enum.sum(solution) >= acc do
              acc
            else
              values =
                back_substitute_and_extend_solution(
                  matrix,
                  free_vars |> Enum.zip(solution) |> Map.new()
                )
                |> Map.values()

              if !Enum.empty?(values) and values |> Enum.all?(&(&1 >= 0 && round(&1) == &1)) do
                min(acc, Enum.sum(values))
              else
                acc
              end
            end
          end)

        [] ->
          back_substitute_and_extend_solution(matrix, Map.new()) |> Map.values() |> Enum.sum()
      end
    end)
    |> Enum.sum()
  end
end

filename = System.argv() |> List.first()
machines = Day10.get_machines(filename)
machines |> Day10.solve_part_1() |> IO.puts()
machines |> Day10.solve_part_2() |> IO.puts()
