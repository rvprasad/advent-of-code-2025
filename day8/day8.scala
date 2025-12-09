import io.Source

type Coord = (Int, Int, Int)
type Edge = (Coord, Coord, Double)

def readCoordinates(filename: String): List[Coord] =
  Source
    .fromFile(filename)
    .getLines()
    .map(l =>
      val tmp = l.split(",").map(_.toInt).toList
      (tmp(0), tmp(1), tmp(2))
    )
    .toList

def generateEdges(coordinates: List[Coord]) =
  def distance(x: Coord, y: Coord) =
    Math.sqrt(x.zip(y).toList.map(e => Math.pow(e(0) - e(1), 2)).sum)

  (for
    (v, vi) <- coordinates.zipWithIndex
    (u, ui) <- coordinates.zipWithIndex
    if (vi < ui)
  yield (v, u, distance(v, u)))
    .sortBy(_._3)

def connectComponentsWithEdge(
    node2comp: Map[Coord, Set[Coord]],
    e: Edge
): Map[Coord, Set[Coord]] =
  val (u, v, _) = e
  val updates = (node2comp.contains(u), node2comp.contains(v)) match
    case (false, false) =>
      val comp = Set(u, v)
      Seq(u -> comp, v -> comp)
    case (true, false) =>
      val comp = node2comp(u) + v
      comp.map(e => e -> comp)
    case (false, true) =>
      val comp = node2comp(v) + u
      comp.map(e => e -> comp)
    case (true, true) if (node2comp(u).contains(v)) =>
      Seq.empty
    case _ =>
      val comp = node2comp(u) ++ node2comp(v)
      comp.map(e => e -> comp)
  node2comp ++ updates

def solve_part_1(coordinates: List[Coord], n: Int): Int =
  generateEdges(coordinates)
    .take(n)
    .foldLeft(Map.empty)(connectComponentsWithEdge)
    .values
    .toSet
    .map(_.size)
    .toList
    .sortBy(-_)
    .take(3)
    .product

def solve_part_2(coordinates: List[Coord]): Long =
  val numCoords = coordinates.length
  def folder(
      acc: (Map[Coord, Set[Coord]], Option[Edge]),
      e: Edge
  ): (Map[Coord, Set[Coord]], Option[Edge]) =
    acc match
      case (_, Some(_)) => acc
      case (_, None)    =>
        val newNode2comp = connectComponentsWithEdge(acc(0), e)
        val finalEdgeFound = newNode2comp.values.head.size == numCoords
        (newNode2comp, if (finalEdgeFound) Some(e) else None)

  generateEdges(coordinates)
    .foldLeft((Map.empty, None))(folder)(1)
    .map(e => e(0)(0).toLong * e(1)(0).toLong)
    .getOrElse(0)

@main def main(filename: String, n: Int) = {
  val coordinates = readCoordinates(filename)
  println(solve_part_1(coordinates, n))
  println(solve_part_2(coordinates))
}
