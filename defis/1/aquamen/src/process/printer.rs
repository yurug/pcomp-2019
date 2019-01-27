
use data::{Matrix, Num};

// FIXME test!!!
pub fn print(block: Matrix<Num>) {
    for line in block.lines() {
        print!("{};",line.into_iter().map(|i| i.to_string()).collect::<Vec<String>>().join(","))
    }
}
