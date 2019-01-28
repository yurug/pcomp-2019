
use data::{Matrix, Cell, Point, Data};
use data::Data::*;
use data::Function::*;

// FIXME test!!!!

// FIXME should return a list of dependencies
// in case of if we can't completly compute
// the cell (because we don't have the full sheet)
// FIXME improve perfs
// FIXME add some kind of Result so that we can print
// an error
fn eval_cell(data: &Data, sheet: &Matrix<Cell>) -> Data {
    match data {
        Val(_i) => data.clone(),
        Fun(Count(b, e, v)) => {
            let mut acc = 0;
            for x in b.x..e.x+1 {
                for y in b.y..e.y+1 {
                    match eval_cell(&sheet.get(Point{x: x-1, y: y-1}).content, sheet) {
                        // FIXME find out why it's a ref and not a value
                        Val(i) => if i == v.clone() {
                            acc += 1;
                        },
                        _ => panic!("Failure while evaluating ")
                    }
                }
            }
            Val(acc)
        }
        _ => data.clone() // FIXME better errors!!!

    }
}

// FIXME add a way to communicate to the caller (and the central authority)
pub fn eval(input: &Matrix<Cell>) -> Matrix<Data> {
    let mut res = Vec::new();
    for line in input.lines() {
        let mut lres: Vec<Data>  = Vec::with_capacity(line.len());
        for cell in line {
            let r = eval_cell(&cell.content, input);
            lres.push(r)
        }
        res.push(lres)
    }
    Matrix::from_2d_vec(res)
}
