import io.Source

def readVoltages(filename: String): List[Array[Long]] =
  Source
    .fromFile(filename)
    .getLines
    .map(line => line.split("").map(_.toLong))
    .toList

def solve(voltages: List[Array[Long]], num_batteries: Int): Long =
  def helper(bank: Array[Long], n: Int, ret: Long): Long =
    n match {
      case 0 => ret
      case _ => {
        val limit = bank.size - n
        val (digit, idx) =
          bank.zipWithIndex.reduce((acc, item) =>
            if (item._2 <= limit && item._1 > acc._1) item else acc
          )
        helper(bank.drop(idx + 1), n - 1, ret * 10 + digit)
      }
    }

  voltages.map(helper(_, num_batteries, 0L)).sum

@main def main(filename: String) = {
  val voltages = readVoltages(filename)
  println(solve(voltages, 2))
  println(solve(voltages, 12))
}
