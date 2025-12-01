def read_doc(filename)
  File.read_lines(filename).map { |l|
    exit unless md = /([LR])(\d+)/.match(l)
    (md[1] == "L" ? -1 : 1) * md[2].to_i
  }
end

def get_password1(lines)
  lines.reduce([50]) { |acc, v| acc.push((acc[-1] + v) % 100) }
    .count { |v| v == 0 }
end

def get_password2(shifts)
  shifts.reduce({50, 0}) { |(prev_val, zeroes), shift|
    shifted_val = prev_val + shift
    if shifted_val > 0
      zero_inc = shifted_val // 100
    elsif shifted_val == 0
      zero_inc = 1
    else
      zero_inc = shifted_val.abs // 100 + (prev_val > 0 ? 1 : 0)
    end
    {shifted_val % 100, zeroes + zero_inc}
  }[1]
end

encrypted_doc = read_doc(ARGV[0])

puts get_password1(encrypted_doc)
puts get_password2(encrypted_doc)
