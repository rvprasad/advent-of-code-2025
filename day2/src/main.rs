use std::collections::HashSet;
use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() {
    let args: Vec<String> = env::args().collect();
    if let Ok(ranges) = read_ranges(&args[1]) {
        println!("{}", solve_puzzle(&ranges, &is_invalid_1));
        println!("{}", solve_puzzle(&ranges, &is_invalid_2));
    }
}
fn read_ranges(filename: &String) -> std::io::Result<Vec<(String, String)>> {
    let f = File::open(filename)?;
    Ok(BufReader::new(f)
        .lines()
        .flatten()
        .filter(|l| !l.is_empty())
        .map(|l| {
            l.split(',')
                .map(|s| {
                    let tmp1: Vec<&str> = s.split('-').collect();
                    (tmp1[0].to_string(), tmp1[1].to_string())
                })
                .collect::<Vec<(String, String)>>()
        })
        .flatten()
        .collect())
}

type IsInvalid = dyn Fn(String) -> bool;

fn solve_puzzle(ranges: &Vec<(String, String)>, is_invalid: &IsInvalid) -> i64 {
    ranges
        .iter()
        .flat_map(|(l, h)| {
            (l.parse::<i64>().unwrap()..(h.parse::<i64>().unwrap() + 1))
                .filter(|i| is_invalid(i.to_string()))
        })
        .sum()
}

fn is_invalid_1(s: String) -> bool {
    let (a, b) = s.split_at(s.len() / 2);
    a == b
}

fn is_invalid_2(s: String) -> bool {
    let s_len = s.len();
    let s_chars = s.chars().collect::<Vec<char>>();

    s_len > 1
        && (1..(s_len / 2 + 1))
            .filter(|l| s_len % l == 0)
            .any(|l| s_chars.chunks(l).collect::<HashSet<&[char]>>().len() == 1)
}
