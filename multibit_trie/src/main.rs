extern crate multibit_trie;
use multibit_trie::trie;

use std::fs;
use std::io::{BufReader, BufRead};
use std::time::Instant;

fn main() {
    let mut trie = trie::FixedStrideMultiBit::new(4);
    let insert_file = BufReader::new(fs::File::open("./resources/insert.txt").unwrap());
    for line in insert_file.lines() {
        trie.insert(line.unwrap().to_string());
    }

    let search_file = BufReader::new(fs::File::open("./resources/1000000.txt").unwrap());
    let mut search_list: Vec<String> = Vec::new();
    for line in search_file.lines() {
        search_list.push(line.unwrap().to_string());
    }
    let start = Instant::now();
    for ip in search_list {
        trie.search(ip);
    }
    let end = start.elapsed();
    println!("{}.{:03}[s]", end.as_secs(), end.subsec_nanos() / 1_000_000);

}
