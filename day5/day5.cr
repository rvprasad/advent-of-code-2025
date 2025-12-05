def read_ranges_and_ids(filename)
  chunks = File.read(filename).split("\n\n")
  ranges = chunks[0].split.map { |s1|
    Tuple(UInt64, UInt64).from(s1.chomp.split("-").map { |s2| s2.to_u64 })
  }
  ids = chunks[1].split.map { |s| s.chomp.to_u64 }
  {ranges, ids}
end

def solve_part_1(ranges, ids)
  ids.count { |i| ranges.any? { |(l, h)| l <= i <= h } }
end

def solve_part_2(ranges)
  ranges[1..].reduce([ranges[0]]) { |acc, (l, h)|
    overlapping, non_overlapping = acc.partition { |(al, ah)|
      al <= l <= ah || al <= h <= ah || l <= al <= h || l <= ah <= h
    }
    if overlapping.empty?
      acc + [{l, h}]
    else
      tmp1 = overlapping + [{l, h}]
      non_overlapping + [{tmp1.min_of { |r| r[0] }, tmp1.max_of { |r| r[1] }}]
    end
  }.map { |(l, h)| h - l + 1 }.sum
end

ranges, ids = read_ranges_and_ids(ARGV[0])
puts solve_part_1(ranges, ids)
puts solve_part_2(ranges)
