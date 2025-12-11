defmodule Day10 do
  use Agent

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

  defp minimum_button_presses_to_turn_on_machine(machine, work_list, n, seen) do
    tmp1 = work_list |> Enum.find(fn lights -> lights == machine.lights end)

    if tmp1 do
      n
    else
      new_seen = work_list |> Enum.reduce(seen, &MapSet.put(&2, &1))

      new_work_list =
        work_list
        |> Enum.flat_map(fn lights ->
          machine.buttons
          |> Enum.map(fn b ->
            MapSet.union(MapSet.difference(lights, b), MapSet.difference(b, lights))
          end)
        end)
        |> MapSet.new()

      minimum_button_presses_to_turn_on_machine(machine, new_work_list, n + 1, new_seen)
    end
  end

  def solve_part_1(machines) do
    machines
    |> Enum.map(fn machine ->
      minimum_button_presses_to_turn_on_machine(machine, [MapSet.new()], 0, MapSet.new())
    end)
    |> Enum.sum()
  end

  def generate_button_presses(target, splits) do
    # {target, splits} |> IO.inspect()

    case splits do
      [hd] ->
        [[Enum.min([target, hd])]]

      [hd | tl] ->
        for i <- 0..Enum.min([target, hd]) do
          generate_button_presses(target - i, tl) |> Enum.map(&[i | &1])
        end
        |> Enum.concat()
    end
  end

  defp minimum_button_presses_to_set_voltage_1(
         work_list,
         [],
         _,
         machine
       ) do
    work_list
    |> Enum.filter(fn {voltages, _} -> voltages == machine.voltages end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.min(fn -> Integer.pow(2, 64) end)
    |> then(fn e ->
      {"End >>>>>>>>>>>>>>>>>>>>>>>>>>>>>.", e} |> IO.inspect()
      machine |> IO.inspect()
      e
    end)
  end

  defp minimum_button_presses_to_set_voltage_1(
         work_list,
         [light | remaining_lights],
         seen,
         machine
       ) do
    buttons_of_light =
      machine.buttons
      |> Enum.filter(fn b -> MapSet.member?(b, light) end)
      |> Enum.to_list()

    # {"light", light} |> IO.inspect()
    # {"work_list", work_list |> Enum.count()} |> IO.inspect()
    # {"buttons_of_light", buttons_of_light} |> IO.inspect()

    new_work_list =
      work_list
      |> Enum.flat_map(fn {voltages, presses} ->
        remaining_voltage_for_light =
          Enum.at(machine.voltages, light) - Enum.at(voltages, light)

        {"voltages & presses & remaining_voltage_for_light", voltages, presses,
         remaining_voltage_for_light}

        # |> IO.inspect()

        if remaining_voltage_for_light == 0 do
          [{voltages, presses}]
        else
          remaining_presses_for_buttons =
            buttons_of_light
            |> Enum.map(fn b ->
              b |> Enum.map(fn i -> Enum.at(machine.voltages, i) - Enum.at(voltages, i) end)
            end)

          generate_button_presses(remaining_voltage_for_light, remaining_presses_for_buttons)
          # |> IO.inspect()
          |> Enum.map(fn button_presses ->
            # {"button_presses", button_presses} |> IO.inspect()

            button_presses
            |> Enum.with_index()
            |> Enum.reduce(voltages, fn {n, b}, acc1 ->
              # {"acc1", acc1} |> IO.inspect()

              buttons_of_light
              |> Enum.at(b)
              |> Enum.reduce(acc1, fn l, acc2 ->
                List.update_at(acc2, l, &(&1 + n))
              end)
            end)
            |> then(&{&1, presses + remaining_voltage_for_light})
          end)
          |> Enum.filter(fn {new_voltages, _} ->
            new_voltages |> Enum.zip(machine.voltages) |> Enum.all?(fn {a, b} -> a <= b end)
          end)
        end
      end)
      |> MapSet.new()

    minimum_button_presses_to_set_voltage_1(
      new_work_list,
      remaining_lights,
      MapSet.union(seen, MapSet.new(new_work_list)),
      machine
    )
  end

  def solve_part_2_1(machines) do
    machines
    |> Enum.map(fn machine ->
      # machine |> IO.inspect()

      init_voltages = [0] |> Stream.cycle() |> Enum.take(Enum.count(machine.voltages))

      light_indices =
        machine.voltages
        |> Enum.with_index()
        |> Enum.sort(fn {e1, _}, {e2, _} -> e1 <= e2 end)
        |> Enum.map(&elem(&1, 1))
        |> Enum.to_list()

      minimum_button_presses_to_set_voltage_1(
        [{init_voltages, 0}],
        light_indices,
        MapSet.new(),
        machine
      )
    end)
    |> Enum.sum()
  end

  defp split_voltage(voltage, n) do
    case n do
      0 -> %{0 => voltage}
      _ -> []
    end
  end

  defp update_voltages_for_light(voltages, light, machine) do
    voltage = Enum.at(machine.voltages, light)
    buttons = machine.buttons |> Enum.filter(&MapSet.member?(&1, light))

    split_voltage(voltage, Enum.count(buttons) - 1)
    |> Enum.map(fn list_of_presses ->
      buttons
      |> Enum.zip(list_of_presses)
      |> Enum.map(fn {button, presses} ->
        button |> Enum.reduce(voltages, fn {i, acc} -> Map.update!(acc, i, &(&1 + presses)) end)
      end)
    end)
    |> Enum.reject(fn vs -> Enum.any?(vs, fn {i, v} -> v > Enum.at(machine.voltages, i) end) end)
  end

  defp minimum_button_presses_to_set_voltage_2(voltages, [light | tl], presses, machine) do
    update_voltages_for_light(voltages, light, machine)
    |> Enum.map(fn {new_voltage, additional_presses} ->
      minimum_button_presses_to_set_voltage_2(
        new_voltage,
        tl,
        presses + additional_presses,
        machine
      )
    end)
    |> Enum.min()
  end

  defp minimum_button_presses_to_set_voltage_2(_, [], presses, _) do
    presses
  end

  def solve_part_2_2(machines) do
    machines
    |> Enum.map(fn machine ->
      init_voltages =
        [
          Stream.repeatedly(fn -> 0 end)
          |> Enum.take(Enum.count(machine.voltages))
          |> Enum.with_index()
          |> Map.new(fn {e, i} -> {i, e} end)
        ]

      light_indices =
        machine.voltages
        |> Enum.with_index()
        |> Enum.sort(fn {e1, _}, {e2, _} -> e1 <= e2 end)
        |> Enum.map(&elem(&1, 1))
        |> Enum.to_list()

      minimum_button_presses_to_set_voltage_2(init_voltages, light_indices, 0, machine)
    end)
    |> Enum.sum()
  end
end

filename = System.argv() |> List.first()
machines = Day10.get_machines(filename)
machines |> Day10.solve_part_1() |> IO.puts()
machines |> Day10.solve_part_2_1() |> IO.puts()
