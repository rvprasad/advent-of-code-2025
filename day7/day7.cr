def read_diagram(filename)
  File.read_lines(filename).map { |line| line.chars }
end

def solve(diagram)
  start_loc = diagram[0].index { |c| c == 'S' }.as(Int32)
  relevant_rows = diagram.skip(1).select { |r| r.any? { |c| c != '.' } }
  tmp = relevant_rows.reduce({0, {start_loc => 1_u64}}) { |acc, row|
    split_locs, not_split_locs = acc[1].partition { |(k, v)| row[k] == '^' }

    loc_2_timelines = not_split_locs.to_h
    split_locs.each { |(k, v)|
      loc_2_timelines[k - 1] = loc_2_timelines.fetch(k - 1, 0_u64) + v
      loc_2_timelines[k + 1] = loc_2_timelines.fetch(k + 1, 0_u64) + v
    }

    {acc[0] + split_locs.size, loc_2_timelines}
  }
  {tmp[0], tmp[1].values.sum}
end

diagram = read_diagram(ARGV[0])
puts solve(diagram)
