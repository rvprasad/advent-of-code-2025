# Advent of Code 2025

This repo contains the code to solve the puzzles from [2025 Advent of
Code](https://adventofcode.com/2025). The README.md file in the folder for
each day contains my observations when solving that day's puzzle.

## Instructions

Unless day-specific README.md files contain specific instructions, use the
following commands to execute the solution.

- `crystal dayX.cr <filename>`
- `elixir dayX.exs <filename>`
- `cargo run <filename>`
- `scala dayX.scala -- <filename>`

| Days | [Crystal (v1.18.2)](https://crystal-lang.org) | [Elixir (v1.19.4)](https://elixir-lang.org) | [Rust (v1.91.1)](https://rust-lang.org) | [Scala (v3.7.4)](https://scala-lang.org)
|----|---|---|---|---
| 1  | 1 | 2 |   |
| 2  |   | 1 | 2 |
| 3  |   |   | 1 | 2
| 4  | 2 |   |   | 1
| 5  | 1 |   | 2 |
| 6  |   | 1 |   | 2
| 7  | 2 |   | 1 |
| 8  |   | 2 |   | 1
| 9  | 1 |   |   | 2
| 10 | 2 | 1 |   |
| 11 |   | 2 | 1 |
| 12 |   |   | 2 | 1

1. On Day 9, I found an odd bug in Crystal: `(set1 | set2) - set3` contained
   elements from `set3` when these sets contained objects of a custom class
   named `Location` that had two getters `x: Int64` and `y: Int64` along with
   custom equals and hash methods defined via the `def_equals_and_hash()` macro.
   I was not able to reproduce the same issue in a minimal setting.

## Attribution

Copyright (c) 2025, Venkatesh-Prasad Ranganath

Licensed under BSD 4-Clause “Original” or “Old” License (<https://choosealicense.com/licenses/bsd-4-clause/>)

**Authors:** Venkatesh-Prasad Ranganath
