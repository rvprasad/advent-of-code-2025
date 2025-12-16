use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() {
    let args: Vec<String> = env::args().collect();
    if let Ok(graph) = read_graph(&args[1]) {
        println!("{}", solve_part_1(&graph));
        println!("{}", solve_part_2(&graph));
    }
}
fn read_graph(filename: &String) -> std::io::Result<HashMap<String, Vec<String>>> {
    let f = File::open(filename)?;
    Ok(BufReader::new(f)
        .lines()
        .flatten()
        .fold(HashMap::new(), |mut acc, l| {
            if l.is_empty() {
                acc
            } else {
                let tmp1 = l.split(" ").map(|s| s.to_string()).collect::<Vec<String>>();
                let key = tmp1[0].strip_suffix(":").unwrap().to_string();
                acc.insert(key, tmp1[1..].iter().cloned().collect::<Vec<String>>());
                acc
            }
        }))
}

fn dfs<'a>(
    node: &'a String,
    end_node: &String,
    mut node_2_path_count: HashMap<&'a String, i64>,
    graph: &'a HashMap<String, Vec<String>>,
) -> HashMap<&'a String, i64> {
    if graph.contains_key(node) {
        node_2_path_count.insert(node, 0);

        let succs = &graph[node];
        let mut new_node_2_path_count = succs
            .iter()
            .filter(|s| !node_2_path_count.contains_key(s) && *s != end_node)
            .fold(node_2_path_count.clone(), |acc, s| {
                dfs(&s, end_node, acc, graph)
            });

        new_node_2_path_count.insert(
            node,
            graph[node]
                .iter()
                .map(|s| new_node_2_path_count.get(s).unwrap())
                .sum::<i64>()
                + if succs.contains(end_node) { 1 } else { 0 },
        );
        new_node_2_path_count
    } else {
        node_2_path_count
    }
}

fn solve_part_1(graph: &HashMap<String, Vec<String>>) -> i64 {
    let mut node_2_path_count = HashMap::new();
    let src = "you".to_string();
    let trg = "out".to_string();
    node_2_path_count.insert(&trg, 0);
    dfs(&src, &trg, node_2_path_count, graph)[&src]
}

fn solve_part_2(graph: &HashMap<String, Vec<String>>) -> i64 {
    let helper = |nodes: Vec<&String>| {
        let last_node = nodes.last().unwrap();
        nodes
            .iter()
            .zip(nodes.iter().skip(1))
            .map(|(a, b)| {
                let node_2_path_count = HashMap::from([(*last_node, 0), (b, 0)]);
                dfs(&a, &b, node_2_path_count, graph)[a]
            })
            .product::<i64>()
    };

    let out = "out".to_string();
    let svr = "svr".to_string();
    let dac = "dac".to_string();
    let fft = "fft".to_string();
    helper(vec![&svr, &dac, &fft, &out]) + helper(vec![&svr, &fft, &dac, &out])
}
