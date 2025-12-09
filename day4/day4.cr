def read_grid(filename)
  File.read_lines(filename).each_with_index.flat_map { |(line, r)|
    line.split("").each_with_index.reject { |(e, c)| e == "." }
      .map { |(e, c)| {r, c} }
  }.to_set
end

def get_number_of_neighbor_rolls(row, col, max_row, max_col, grid)
  (Math.max(0, row - 1)..Math.min(max_row, row + 1)).flat_map { |r|
    (Math.max(0, col - 1)..Math.min(max_col, col + 1)).map { |c|
      {r, c}
    }
  }.count { |e| !(e[0] == row && e[1] == col) && grid.includes?(e) }
end

def get_removable_rolls(grid)
  max_row = grid.max_of { |e| e[0] }
  max_col = grid.max_of { |e| e[1] }
  grid.select { |(r, c)|
    get_number_of_neighbor_rolls(r, c, max_row, max_col, grid) < 4
  }.to_set
end

def solve_part_1(grid)
  get_removable_rolls(grid).size
end

def solve_part_2(grid)
  removableRolls = get_removable_rolls(grid)
  if removableRolls.empty?
    0
  else
    removableRolls.size + solve_part_2(grid - removableRolls)
  end
end

grid = read_grid(ARGV[0])
puts solve_part_1(grid)
puts solve_part_2(grid)
