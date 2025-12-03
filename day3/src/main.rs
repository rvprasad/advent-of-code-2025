use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() {
    let args: Vec<String> = env::args().collect();
    if let Ok(voltages) = read_voltages(&args[1]) {
        println!("{}", solve(&voltages, 2));
        println!("{}", solve(&voltages, 12));
    }
}
fn read_voltages(filename: &String) -> std::io::Result<Vec<String>> {
    let f = File::open(filename)?;
    Ok(BufReader::new(f)
        .lines()
        .flatten()
        .filter(|l| !l.is_empty())
        .collect())
}

fn solve(voltages: &Vec<String>, num_batteries: usize) -> u64 {
    fn helper(bank: &[u32], n: usize, val: u64) -> u64 {
        if n == 0 {
            val
        } else {
            let limit = bank.len() - n;
            let (idx, digit) = bank
                .iter()
                .enumerate()
                .reduce(|acc, (i, e)| {
                    if i <= limit && e > &acc.1 {
                        (i, e)
                    } else {
                        acc
                    }
                })
                .unwrap();
            helper(&bank[(idx + 1)..], n - 1, val * 10u64 + (*digit as u64))
        }
    }

    voltages
        .iter()
        .map(|bank| {
            helper(
                &(bank
                    .chars()
                    .map(|c| c.to_digit(10).unwrap())
                    .collect::<Vec<u32>>()[..]),
                num_batteries,
                0u64,
            )
        })
        .sum()
}
