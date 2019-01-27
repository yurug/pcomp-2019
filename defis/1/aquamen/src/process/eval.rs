
use data::{Matrix, Cell, Num, Point, Data};
use data::Data::*;
use data::Function::*;

// FIXME test!!!!

// FIXME should return a list of dependencies
// in case of if we can't completly compute
// the cell (because we don't have the full sheet)
// FIXME improve perfs
// FIXME add some kind of Result so that we can print
// an error
fn eval_cell(data: &Data, sheet: &Matrix<Cell>) -> Num {
    match data {
        Val(i) => i.clone(),
        Fun(Count(b, e, v)) => {
            let mut acc = 0;
            for x in b.x..e.x {
                for y in b.y..e.y {
                    if eval_cell(&sheet.get(Point{x: x, y: y}).content, sheet) == v.clone() {
                        acc += 1;
                    }
                }
            }
            acc
        }
        _ => 0 // FIXME better errors!!!

    }
}

// FIXME add a way to communicate to the caller (and the central authority)
pub fn eval(input: &Matrix<Cell>) -> Matrix<Num> {
    let mut res = Vec::new();
    for line in input.lines() {
        let mut lres: Vec<Num>  = Vec::with_capacity(line.len());
        for cell in line {
            lres.push(eval_cell(&cell.content, input))
        }
        res.push(lres)
    }
    Matrix::from_2d_vec(res)
}
