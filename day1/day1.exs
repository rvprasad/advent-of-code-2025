defmodule Day1 do
  def read_doc(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.map(&Regex.run(~r/([LR])(\d+)/, &1, capture: :all_but_first))
    |> Stream.map(fn [a, b] ->
      if(a == "L", do: -1, else: 1) * String.to_integer(b)
    end)
    |> Enum.to_list()
  end

  def get_password1(shifts) do
    shifts
    |> Enum.reduce([50], fn v, acc ->
      [Integer.mod(hd(acc) + v, 100)] ++ acc
    end)
    |> Enum.count(&(&1 == 0))
  end

  def get_password2(shifts) do
    shifts
    |> Enum.reduce({50, 0}, fn shift, {prev_val, zeroes} ->
      shifted_val = prev_val + shift

      zero_inc =
        cond do
          shifted_val > 0 ->
            div(shifted_val, 100)

          shifted_val == 0 ->
            1

          true ->
            div(abs(shifted_val), 100) + if(prev_val > 0, do: 1, else: 0)
        end

      {Integer.mod(shifted_val, 100), zeroes + zero_inc}
    end)
    |> elem(1)
  end
end

filename = System.argv() |> List.first()
shifts = Day1.read_doc(filename)
Day1.get_password1(shifts) |> IO.puts()
Day1.get_password2(shifts) |> IO.puts()
