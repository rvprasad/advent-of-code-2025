import io.Source
import scala.collection.Seq

@main def main(filename: String) = {
  println(
    Source
      .fromFile(filename)
      .getLines()
      .filter(_.contains("x"))
      .filter(l =>
        val Array(a, b) = l.split(":")
        a.split("x")
          .map(_.toInt)
          .product >= (b.trim().split(" ").map(_.toInt).sum * 9)
      )
      .size
  )
}
