
use data::{Matrix, Data};
use data::Data::{Val, Wrong};

// FIXME test!!!
pub fn print(block: Matrix<Data>) {
    for line in block.lines() {
        print!("{}\n",line.into_iter().map(|i| {
            match i {
                Val(i) => i.to_string(),
                Wrong => "P".to_owned(),
                _ => panic!("Unexpected value while printing")
            }
        }).collect::<Vec<String>>().join(";"))
    }
}
