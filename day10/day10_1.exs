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
    if work_list |> Enum.find(&(&1 == machine.lights)) do
      n
    else
      new_work_list =
        work_list
        |> Enum.flat_map(fn lights ->
          machine.buttons
          |> Enum.map(fn b ->
            MapSet.union(MapSet.difference(lights, b), MapSet.difference(b, lights))
          end)
        end)
        |> MapSet.new()

      turn_lights_on(
        machine,
        new_work_list,
        n + 1,
        new_work_list |> Enum.reduce(seen, &MapSet.put(&2, &1))
      )
    end
  end

  def solve_part_1(machines) do
    machines
    |> Enum.map(fn machine ->
      turn_lights_on(machine, [MapSet.new()], 0, MapSet.new())
    end)
    |> Enum.sum()
  end

  def transform_to_row_echelon_form(matrix) do
    case matrix do
      [] ->
        []

      [hd] ->
        [hd]

      _ ->
        pivot_c_idx =
          matrix
          |> Enum.reduce(Enum.count(hd(matrix)), fn row, idx ->
            tmp = Enum.find_index(row, &(&1 != 0))
            if tmp < idx, do: tmp, else: idx
          end)

        [pivot_row | bottom] =
          matrix
          |> Enum.sort(fn a, b ->
            abs(Enum.at(a, pivot_c_idx)) >= abs(Enum.at(b, pivot_c_idx))
          end)

        scale = 1 / Enum.at(pivot_row, pivot_c_idx)
        pivoted_row = pivot_row |> Enum.map(&(&1 * scale))

        [pivoted_row] ++
          (bottom
           |> Enum.map(fn row ->
             tmp = Enum.at(row, pivot_c_idx)

             if tmp == 0 do
               row
             else
               row
               |> Enum.with_index(&(&1 - tmp * Enum.at(pivoted_row, &2)))
             end
           end)
           |> Enum.reject(fn r ->
             List.last(r) == 0 || Enum.drop(r, -1) |> Enum.all?(&(&1 == 0))
           end)
           |> transform_to_row_echelon_form())
    end
  end

  defp search_for_assignments(work_list, n, buttons, voltages, seen) do
    {Enum.count(work_list), n, Enum.count(seen)} |> IO.inspect()

    if work_list |> Enum.find(&(&1 == voltages)) do
      n
    else
      new_work_list =
        work_list
        |> Enum.flat_map(fn presses ->
          buttons
          |> Enum.map(fn lights ->
            lights
            |> Enum.with_index()
            |> Enum.reduce(presses, fn {b, i}, acc ->
              List.update_at(acc, i, fn e -> e + b end)
            end)
          end)
        end)
        |> Enum.filter(fn new_voltages ->
          new_voltages |> Enum.zip(voltages) |> Enum.all?(fn {a, b} -> a <= b end)
        end)
        |> MapSet.new()
        |> MapSet.difference(seen)

      search_for_assignments(
        new_work_list,
        n + 1,
        buttons,
        voltages,
        MapSet.union(seen, new_work_list)
      )
      |> IO.inspect()
    end
  end

  def get_solution_by_back_substitution(matrix, solution) do
    {matrix, solution} |> IO.inspect()

    if Enum.empty?(matrix) do
      solution |> Map.values() |> Enum.sum()
    else
      tmp1 =
        matrix
        |> Enum.group_by(fn r ->
          r |> Enum.drop(-1) |> Enum.count(&(&1 != 0)) == 1
        end)

      assignment_rows = Map.get(tmp1, true)

      if assignment_rows == nil do
        buttons =
          0..((matrix |> hd |> Enum.count()) - 2)
          |> Enum.map(fn i ->
            matrix |> Enum.map(&Enum.at(&1, i)) |> Enum.to_list()
          end)
          |> Enum.reject(fn b -> b |> Enum.all?(&(&1 == 0)) end)

        voltages = matrix |> Enum.map(&List.last/1) |> Enum.to_list()
        init_presses = Stream.cycle([0]) |> Enum.take(Enum.count(matrix)) |> Enum.to_list()

        search_for_assignments(
          [init_presses],
          0,
          buttons,
          voltages,
          MapSet.new()
        ) + (Map.values(solution) |> Enum.sum())
      else
        new_solution =
          assignment_rows
          |> Enum.map(fn row ->
            {v, i} =
              row
              |> Enum.with_index()
              |> Enum.find_value(fn {e, i} ->
                if e != 0, do: {e, i}, else: nil
              end)

            {i, v * List.last(row)}
          end)
          |> Map.new()
          |> Map.merge(solution)

        tmp1
        |> Map.get(false, [])
        |> Enum.map(fn row ->
          vars = row |> Enum.drop(-1)

          val =
            List.last(row) -
              (vars |> Enum.with_index(&(&1 * Map.get(new_solution, &2, 0))) |> Enum.sum())

          tmp2 =
            (vars |> Enum.with_index(&if Map.get(new_solution, &2), do: 0, else: &1)) ++ [val]

          if val < 0, do: tmp2 |> Enum.map(&(-&1)), else: tmp2
        end)
        |> get_solution_by_back_substitution(new_solution)
      end
    end
  end

  def solve_part_2(machines) do
    machines
    |> Enum.map(fn machine ->
      machine.voltages
      |> Enum.with_index(fn v, v_i ->
        (machine.buttons
         |> Enum.map(&if Enum.member?(&1, v_i), do: 1.0, else: 0.0)
         |> Enum.to_list()) ++ [v * 1.0]
      end)
      |> Enum.uniq()
      |> transform_to_row_echelon_form()
      |> Enum.map(fn r ->
        if List.last(r) < 0, do: r |> Enum.map(&(-&1)), else: r
      end)
      |> IO.inspect(limit: :infinity)
    end)
    |> Enum.map(&get_solution_by_back_substitution(&1, %{}))
    |> Enum.sum()
  end
end

filename = System.argv() |> List.first()
machines = Day10.get_machines(filename)
machines |> Day10.solve_part_1() |> IO.puts()
machines |> Day10.solve_part_2() |> IO.puts()
