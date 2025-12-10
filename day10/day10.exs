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

      voltages =
        tmp
        |> List.last()
        |> String.replace(~r/[{}]/, "")
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> Enum.to_list()

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
        |> Enum.to_list()

      %{buttons: buttons, lights: lights, voltages: voltages}
    end)
    |> Enum.to_list()
  end

  defp minimum_button_presses_to_turn_on_machine(machine, work_list, seen) do
    tmp1 = work_list |> Enum.find(fn {lights, _} -> lights == machine.lights end)

    if tmp1 do
      elem(tmp1, 1)
    else
      new_seen =
        work_list
        |> Enum.reduce(seen, fn {lights, _}, seen ->
          MapSet.put(seen, lights)
        end)

      new_work_list =
        work_list
        |> Enum.flat_map(fn {lights, n} ->
          machine.buttons
          |> Enum.map(fn b ->
            {MapSet.union(MapSet.difference(lights, b), MapSet.difference(b, lights)), n + 1}
          end)
        end)
        |> MapSet.new()

      minimum_button_presses_to_turn_on_machine(machine, new_work_list, new_seen)
    end
  end

  def solve_part_1(machines) do
    machines
    |> Enum.map(fn machine ->
      minimum_button_presses_to_turn_on_machine(machine, [{MapSet.new(), 0}], MapSet.new())
    end)
    |> Enum.sum()
  end
end

filename = System.argv() |> List.first()
machines = Day10.get_machines(filename) |> IO.inspect()
machines |> Day10.solve_part_1() |> IO.puts()
