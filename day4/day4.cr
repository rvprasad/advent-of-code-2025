def readGrid(filename)
  File.read_lines(filename).each_with_index.flat_map { |(line, r)|
    line.split("").each_with_index.reject { |(e, c)| e == "." }
      .map { |(e, c)| {r, c} }
  }.to_set
end

def getNumberOfNeighborRolls(row, col, max_row, max_col, grid)
  (Math.max(0, row - 1)..Math.min(max_row, row + 1)).flat_map { |r|
    (Math.max(0, col - 1)..Math.min(max_col, col + 1)).map { |c|
      {r, c}
    }
  }.count { |e| !(e[0] == row && e[1] == col) && grid.includes?(e) }
end

def getRemovableRolls(grid)
  max_row = grid.max_of { |e| e[0] }
  max_col = grid.max_of { |e| e[1] }
  grid.select { |(r, c)|
    getNumberOfNeighborRolls(r, c, max_row, max_col, grid) < 4
  }.to_set
end

def solvePart1(grid)
  getRemovableRolls(grid).size
end

def solvePart2(grid)
  removableRolls = getRemovableRolls(grid)
  if removableRolls.empty?
    0
  else
    removableRolls.size + solvePart2(grid - removableRolls)
  end
end

grid = readGrid(ARGV[0])
puts solvePart1(grid)
puts solvePart2(grid)
