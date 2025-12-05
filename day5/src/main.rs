use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() {
    let args: Vec<String> = env::args().collect();
    if let Ok((ranges, ids)) = read_ranges_and_ids(&args[1]) {
        println!("{}", solve_part_1(&ranges, ids));
        println!("{}", solve_part_2(ranges));
    }
}
fn read_ranges_and_ids(filename: &String) -> std::io::Result<(Vec<(u64, u64)>, Vec<u64>)> {
    let f = File::open(filename)?;
    let mut ranges: Vec<String> = BufReader::new(f).lines().flatten().collect();
    let ids = ranges.split_off(ranges.iter().position(|l| l.is_empty()).unwrap() + 1);
    Ok((
        ranges
            .iter()
            .filter(|l| !l.is_empty())
            .map(|l| {
                let tmp: Vec<u64> = l.split("-").map(|x| x.parse::<u64>().unwrap()).collect();
                (tmp[0], tmp[1])
            })
            .collect(),
        ids.iter().map(|l| l.parse::<u64>().unwrap()).collect(),
    ))
}

fn solve_part_1(ranges: &Vec<(u64, u64)>, ids: Vec<u64>) -> usize {
    ids.iter()
        .filter(|&i| ranges.iter().any(|r| r.0 <= *i && *i <= r.1))
        .count()
}

fn solve_part_2(ranges: Vec<(u64, u64)>) -> u64 {
    let mut acc: Vec<(u64, u64)> = ranges.iter().take(1).copied().collect();
    for e in ranges.iter().skip(1) {
        let (l, h) = e;
        let (overlapping, non_overlapping): (Vec<(u64, u64)>, Vec<(u64, u64)>) =
            acc.into_iter().partition(|(al, ah)| {
                al <= l && l <= ah || al <= h && h <= ah || l <= al && al <= h || l <= ah && ah <= h
            });
        let new_val = if overlapping.is_empty() {
            *e
        } else {
            let (left, right): (Vec<u64>, Vec<u64>) = overlapping.into_iter().chain([*e]).unzip();
            (
                left.into_iter().min().unwrap(),
                right.into_iter().max().unwrap(),
            )
        };
        acc = non_overlapping.clone();
        acc.push(new_val);
    }
    acc.into_iter().map(|(l, h)| h - l + 1).sum()
}
