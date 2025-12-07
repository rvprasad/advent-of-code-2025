use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() {
    let args: Vec<String> = env::args().collect();
    if let Ok(diagram) = read_diagram(&args[1]) {
        println!("{:#?}", solve(&diagram));
    }
}
fn read_diagram(filename: &String) -> std::io::Result<Vec<Vec<char>>> {
    let f = File::open(filename)?;
    Ok(BufReader::new(f)
        .lines()
        .flatten()
        .filter(|l| !l.is_empty())
        .map(|l| l.chars().collect())
        .collect())
}

fn solve(diagram: &Vec<Vec<char>>) -> (usize, usize) {
    let mut loc_2_timelines: HashMap<usize, usize> = HashMap::new();
    let start_loc = diagram[0].iter().position(|c| *c == 'S').unwrap();
    loc_2_timelines.insert(start_loc, 1usize);
    let mut splits = 0usize;
    for row in diagram
        .iter()
        .skip(1)
        .filter(|r| r.iter().any(|e| *e != '.'))
    {
        let (split_locs, not_split_locs): (Vec<_>, Vec<_>) = loc_2_timelines
            .into_iter()
            .partition(|(k, _)| row[*k] == '^');
        loc_2_timelines = not_split_locs.into_iter().collect();
        for (k, v) in &split_locs {
            loc_2_timelines.insert(k - 1, loc_2_timelines.get(&(k - 1)).unwrap_or(&0usize) + v);
            loc_2_timelines.insert(k + 1, loc_2_timelines.get(&(k + 1)).unwrap_or(&0usize) + v);
        }

        splits += split_locs.len();
    }
    (splits, loc_2_timelines.values().sum::<usize>())
}
