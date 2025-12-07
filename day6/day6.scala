import io.Source
import scala.util.Using
import scala.collection.mutable.ListBuffer
import scala.collection.Seq

def readProblems(filename: String): List[List[String]] =
  val content = Source.fromFile(filename).getLines().toList.reverse
  val tmp = content.head
    .toCharArray()
    .zipWithIndex
    .filterNot(_._1 == ' ')
    .map(_._2)
    .appended(content.head.length())
    .toList

  tmp
    .dropRight(1)
    .zip(tmp.drop(1))
    .map((l, h) => content.map(_.substring(l, h)))
    .toList

def solve_part_1(problems: List[List[String]]): Long =
  problems
    .map(problem => {
      val tmp = problem.tail.map(_.trim).filterNot(_.isEmpty()).map(_.toLong)
      if problem.head.trim() == "*" then tmp.product else tmp.sum
    })
    .sum

def solve_part_2(problems: List[List[String]]): Long =
  solve_part_1(
    problems
      .map(problem =>
        problem.head :: problem.tail.reverse
          .map(_.toCharArray())
          .transpose
          .map(_.mkString)
      )
  )

@main def main(filename: String) = {
  val problems = readProblems(filename)
  println(solve_part_1(problems))
  println(solve_part_2(problems))
}
