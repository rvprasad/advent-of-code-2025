class Machine
  getter lights : Set(Int32)
  getter buttons : Array(Set(Int32))
  getter voltages : Array(Int32)

  def initialize(@lights, @buttons, @voltages)
  end
end

def get_machines(filename)
  File.read_lines(filename).map { |line|
    p1, *p2, p3 = line.split(" ")
    lights = p1.gsub(/[\[\]]/, "")
      .split("")
      .each_with_index
      .select { |(e, i)| e == "#" }
      .map { |e| e[1].to_i }
      .to_set

    buttons = p2.map { |b|
      b.gsub(/[\(\)]/, "")
        .split(",")
        .map { |e| e.to_i }
        .to_set
    }
    voltages = p3.gsub(/[{}]/, "")
      .split(",")
      .map { |e| e.to_i }
    Machine.new(lights, buttons, voltages)
  }
end

def turn_lights_on(machine, work_list, presses, seen)
  if work_list.any? { |e| e == machine.lights }
    presses
  else
    new_work_list = work_list.flat_map { |lights|
      machine.buttons.map { |b| lights ^ b }
    }.to_set
    turn_lights_on(machine, new_work_list, presses + 1, seen | new_work_list)
  end
end

def solve_part_1(machines)
  machines.map { |m|
    turn_lights_on(m, [Set(Int32).new], 0, Set(Set(Int32)).new)
  }.sum
end

def transform_to_row_echelon_form(matrix)
  if matrix.empty?
    Array(Array(Int128)).new
  elsif matrix.size == 1
    matrix
  else
    pivot_c_idx = matrix
      .map { |r| r.index! { |e| e != 0 } }
      .min
    top_row, *bottom = matrix.sort_by { |r|
      num_non_zero_entries = r[0..-2].count { |e| e != 0 }
      {-r[pivot_c_idx].abs, -r[pivot_c_idx], num_non_zero_entries, r[-1]}
    }
    pivot_row = top_row[pivot_c_idx] > 0 ? top_row : top_row.map { |e| -e }
    [pivot_row] + transform_to_row_echelon_form(
      bottom.map { |row|
        row.zip(pivot_row).map { |(r, p)|
          r * pivot_row[pivot_c_idx] - p * row[pivot_c_idx]
        }
      }.reject { |r|
        r[0..-2].all? { |e| e == 0 }
      })
  end
end

def scale_down_rows(matrix)
  matrix.map { |row|
    gcd = row.reduce { |a, b| a.gcd(b) }
    row.map { |e| e // gcd }
  }
end

def find_free_vars_and_ranges(matrix)
  pivot_vars = matrix.map { |r| r.index { |e| e != 0 } }
  tmp = (0..(matrix[0].size - 2))
    .reject { |i| pivot_vars.includes?(i) }
    .map { |i|
      limit = matrix.select { |r| r[i] != 0 }
        .map { |r| r[-1].abs }
        .reject { |e| e == 0 }
        .max? || 0
      {i, (0..limit).to_a}
    }.reject { |(_, e)| e.size == 0 }
  tmp.empty? ? nil : {tmp.map { |e| e[0] }, tmp.map { |e| e[1] }}
end

def back_substitute_and_extend_solution(matrix, solution)
  matrix.reverse.each { |row|
    idx = row.index! { |e| e != 0 }
    solution[idx] = (row[-1] - row[0..-2].map_with_index { |e, i|
      e * solution.fetch(i, 0)
    }.sum(0_f32)) / row[idx]
  }
  return solution
end

def solve_part_2(machines)
  machines.map { |machine|
    init_matrix = machine.voltages.each_with_index.map { |(v, v_i)|
      machine.buttons.map { |b| b.includes?(v_i) ? 1_i128 : 0_i128 }.to_a << v.to_i128
    }.to_a
    transformed_matrix = transform_to_row_echelon_form(init_matrix)
    matrix = scale_down_rows(transformed_matrix)

    tmp1 = find_free_vars_and_ranges(matrix)
    if tmp1
      free_vars, ranges = tmp1
      Indexable.cartesian_product(ranges).reduce(Float32::MAX) { |acc, solution|
        if solution.sum >= acc
          acc
        else
          values = back_substitute_and_extend_solution(
            matrix,
            free_vars.zip(solution.map { |e| e.to_f32 }).to_h
          ).values

          if values.all? { |e| e >= 0 && e.to_i32 == e }
            Math.min(acc, values.sum)
          else
            acc
          end
        end
      }
    else
      back_substitute_and_extend_solution(matrix, Hash(Int32, Float32).new).values.sum
    end
  }.sum
end

machines = get_machines(ARGV[0])
puts solve_part_1(machines)
puts solve_part_2(machines)
