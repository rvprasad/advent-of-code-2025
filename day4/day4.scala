import io.Source
import scala.math.max
import scala.math.min
import scala.collection.mutable.ListBuffer

def readGrid(filename: String) =
  Source
    .fromFile(filename)
    .getLines
    .zipWithIndex
    .flatMap((l, r) =>
      l.split("")
        .zipWithIndex
        .filter((e, c) => e == "@")
        .map((e, c) => (r, c))
    )
    .toSet

def getRemovableRolls(grid: Set[(Int, Int)]): Set[(Int, Int)] =
  val maxRow = grid.map(e => e._1).max
  val maxCol = grid.map(e => e._2).max
  def getNumberOfNeighborRolls(row: Int, col: Int) =
    (for
      r <- (max(0, row - 1) to min(maxRow, row + 1))
      c <- (max(0, col - 1) to min(maxCol, col + 1))
      if !(r == row && c == col) && grid.contains((r, c))
    yield 1).sum

  grid.filter((r, c) => getNumberOfNeighborRolls(r, c) < 4).toSet

def solvePart1(grid: Set[(Int, Int)]) = getRemovableRolls(grid).size

def solvePart2(grid: Set[(Int, Int)]): Int =
  val removableRoles = getRemovableRolls(grid)
  if (removableRoles.isEmpty) 0
  else removableRoles.size + solvePart2(grid -- removableRoles)

@main def main(filename: String) = {
  val grid = readGrid(filename)
  println(solvePart1(grid))
  println(solvePart2(grid))
}
