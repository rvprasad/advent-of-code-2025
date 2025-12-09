import io.Source

case class Location(x: Long, y: Long)

def readLocations(filename: String) =
  Source
    .fromFile(filename)
    .getLines
    .map(l =>
      val tmp = l.split(",").map(_.toLong)
      Location(tmp(0), tmp(1))
    )
    .toList

def cartesian_product(list: List[Location]) =
  for
    (l1, i1) <- list.zipWithIndex
    (l2, i2) <- list.zipWithIndex
    if i1 < i2
  yield (l1, l2)

def area(l1: Location, l2: Location) =
  ((Math.abs(l2.x - l1.x)) + 1) * (Math.abs(l2.y - l1.y) + 1)

def solvePart1(locations: List[Location]) =
  cartesian_product(locations).map((l1, l2) => area(l1, l2)).max

def collectNonGreenRedNeighbors(pairs: List[(Location, Location)]) =
  def helper(a: Long, b: Long) =
    val (l, h) = order(a, b)
    (h - l) match
      case 1 => List(l, h)
      case 2 => List(l, l + 1, h)
      case _ => List(l, l + 1, h - 1, h)

  val perimeter = pairs.foldLeft(Set.empty[(Location)]) { (acc, e) =>
    val (l1, l2) = e
    acc ++ (if (l1.x == l2.x)
              helper(l1.y, l2.y).map { Location(l1.x, _) }
            else
              helper(l1.x, l2.x).map { Location(_, l1.y) })
  }
  val (set1: Set[Location], set2: Set[Location]) = pairs
    .foldLeft((Set.empty[Location], Set.empty[Location])) { (acc, e) =>
      val (l1, l2) = e
      val (tmp1, tmp2) = if l1.x == l2.x then
        val ys = helper(l1.y, l2.y)
        (
          ys.map { Location(l1.x - 1, _) }.toSet,
          ys.map { Location(l1.x + 1, _) }.toSet
        )
      else
        val xs = helper(l1.x, l2.x)
        (
          xs.map { Location(_, l1.y - 1) }.toSet,
          xs.map { Location(_, l1.y + 1) }.toSet
        )

      val (set1_additions, set2_additions) =
        if (!(acc._1 & tmp1).isEmpty || !(acc._2 & tmp2).isEmpty) (tmp1, tmp2)
        else (tmp2, tmp1)

      (
        (acc._1 ++ set1_additions) -- perimeter,
        (acc._2 ++ set2_additions) -- perimeter
      )
    }
  if (set1.size > set2.size) set1 else set2

def order(a: Long, b: Long) = if (a < b) (a, b) else (b, a)

def solvePart2(locations: List[Location]) =
  val pairs = locations.zip(locations.drop(1).appended(locations.head))
  val (horizontals, verticals) = pairs.partition((l1, l2) => l1.y == l2.y)
  val nonGreenRedNeighbors = collectNonGreenRedNeighbors(pairs)

  cartesian_product(locations)
    .foldLeft(Set.empty[(Location, Location)]) {
      (acc, e: (Location, Location)) =>
        val (a, b) = e
        if (acc.contains((b, a))) { acc }
        else { acc + e }
    }
    .filterNot((e: (Location, Location)) =>
      val (x1, x2) = order(e._1.x, e._2.x)
      val (y1, y2) = order(e._1.y, e._2.y)
      nonGreenRedNeighbors.exists((l: Location) =>
        x1 <= l.x && l.x <= x2 && y1 <= l.y && l.y <= y2
      )
    )
    .filterNot((e: (Location, Location)) =>
      val (lo_x, hi_x) = order(e._1.x, e._2.x)
      val (lo_y, hi_y) = order(e._1.y, e._2.y)
      horizontals.exists((h1, h2) =>
        val (a, b) = order(h1.x, h2.x)
        lo_y < h1.y && h1.y < hi_y && a <= lo_x && hi_x <= b
      ) || verticals.exists((v1, v2) =>
        val (a, b) = order(v1.y, v2.y)
        lo_x < v1.x && v1.x < hi_x && a <= lo_y && hi_y <= b
      )
    )
    .map((l1, l2) => area(l1, l2))
    .max

@main def main(filename: String) = {
  val locations = readLocations(filename)
  println(solvePart1(locations))
  println(solvePart2(locations))
}
