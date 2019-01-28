
mod parser;
mod eval;
mod printer;
use self::printer::print;
use self::eval::eval;
use self::parser::parse_line;
use data::Matrix;

// FIXME test!!!!

// FIXME for now we are going to assume that we
// receive the full sheet. This should be modified
// so that it can take an arbitrary rectangle view
// of the spreadsheet
pub fn process(block: String) {
    // FIXME setup the channel
    // FIXME setup a way to get data from central authority?
    let sheet = Matrix::from_2d_vec(block.split("\n").map(|l| parse_line(0, l)).collect());
    let res = eval(&sheet);
    print(res)
}
