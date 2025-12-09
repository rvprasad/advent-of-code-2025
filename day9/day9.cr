alias Location = Tuple(Int64, Int64)

def read_locations(filename)
  File.read_lines(filename).map { |l| Location.from(l.split(",").map &.to_i64) }
end

def solve_part_1(locations)
  locations.cartesian_product(locations)
    .map { |((x1, y1), (x2, y2))| ((x2 - x1).abs + 1) * ((y2 - y1).abs + 1) }
    .max
end

def order(a, b)
  a < b ? {a, b} : {b, a}
end

def non_green_red_neighbors_of(pairs)
  helper = ->(a : Int64, b : Int64) {
    l, h = order(a, b)
    if h - l == 1
      [l, h]
    elsif h - l == 2
      [l, l + 1, h]
    else
      [l, l + 1, h - 1, h]
    end
  }

  perimeter = pairs.reduce(Set(Location).new) { |acc, ((x1, y1), (x2, y2))|
    acc | if x1 == x2
      helper.call(y1, y2).map { |y| {x1, y} }.to_set
    else
      helper.call(x1, x2).map { |x| {x, y1} }.to_set
    end
  }
  set1, set2 = pairs
    .reduce({Set(Location).new, Set(Location).new}) { |(set1, set2), ((x1, y1), (x2, y2))|
      tmp1, tmp2 = if x1 == x2
                     ys = helper.call(y1, y2)
                     {
                       ys.map { |y| {x1 - 1, y} }.to_set,
                       ys.map { |y| {x1 + 1, y} }.to_set,
                     }
                   else
                     xs = helper.call(x1, x2)
                     {
                       xs.map { |x| {x, y1 - 1} }.to_set,
                       xs.map { |x| {x, y1 + 1} }.to_set,
                     }
                   end

      set1_additions, set2_additions = if !(set1 & tmp1).empty? || !(set2 & tmp2).empty?
                                         {tmp1, tmp2}
                                       else
                                         {tmp2, tmp1}
                                       end

      {(set1 | set1_additions) - perimeter, (set2 | set2_additions) - perimeter}
    }
  set1.size > set2.size ? set1 : set2
end

def solve_part_2(locations)
  pairs = locations.zip(locations.cycle.skip(1))
  horizontals, verticals = pairs.partition { |(l1, l2)| l1[1] == l2[1] }
  non_green_red_neighbors = non_green_red_neighbors_of(pairs)

  locations.cartesian_product(locations)
    .reduce(Set(Tuple(Location, Location)).new) { |acc, (a, b)|
      acc.includes?({b, a}) ? acc : acc << {a, b}
    }
    .reject { |l1, l2|
      x1, x2 = order(l1[0], l2[0])
      y1, y2 = order(l1[1], l2[1])
      non_green_red_neighbors.any? { |(x, y)| x1 <= x <= x2 && y1 <= y <= y2 }
    }
    .reject { |((x1, y1), (x2, y2))|
      lo_x, hi_x = order(x1, x2)
      lo_y, hi_y = order(y1, y2)
      horizontals.any? { |(hx1, hy), (hx2, _)|
        a, b = order(hx1, hx2)
        lo_y < hy < hi_y && a <= lo_x < hi_x <= b
      } || verticals.any? { |(vx, vy1), (_, vy2)|
        a, b = order(vy1, vy2)
        lo_x < vx < hi_x && a <= lo_y < hi_y <= b
      }
    }
    .map { |l1, l2|
      ((l2[0] - l1[0]).abs + 1) * ((l2[1] - l1[1]).abs + 1)
    }.max
end

locations = read_locations(ARGV[0])
puts solve_part_1(locations)
puts solve_part_2(locations)
