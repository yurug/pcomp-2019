
use data::{Matrix, Cell, Point, Requirements};
use data::Requirements::Empty;
use data::Data::*;
use data::Function::*;

// FIXME test!!!!

// FIXME improve perfs
/// Requirements is the list of cell that can't be evaluated
/// because we're missing other cells. Will be used later
/// when we need to split the sheet in sub-sheet
fn eval_cell(cell: &Cell, sheet: &Matrix<Cell>) -> (Cell, Requirements) {
    match cell.content {
        Val(_i) => (cell.clone(), Empty),
        Fun(Count(b, e, v)) => {
            let mut acc = 0;
            for x in b.x..e.x+1 {
                for y in b.y..e.y+1 {
                    match eval_cell(&sheet.get(Point{x: x, y: y}), sheet).0.content {
                        // FIXME find out why it's a ref and not a value
                        Val(i) => if i == v.clone() {
                            acc += 1;
                        },
                        _ => panic!("Failure while evaluating ")
                    }
                }
            }
            (Cell{content: Val(acc), loc: cell.loc}, Empty)
        }
        Wrong => (cell.clone(), Empty)

    }
}

// FIXME add a way to communicate to the caller (and the central authority)
pub fn eval(input: &Matrix<Cell>) -> Matrix<Cell> {
    let mut res = Vec::new();
    for line in input.lines() {
        let mut lres: Vec<Cell>  = Vec::with_capacity(line.len());
        for cell in line {
            let (r, _) = eval_cell(&cell, input);
            lres.push(r)
        }
        res.push(lres)
    }
    Matrix::from_2d_vec(res)
}

pub fn eval_changes(changes: &Vec<Cell>, spreadsheet: &Matrix<Cell>) -> Vec<Cell> {
    changes.into_iter().map(|c| eval_cell(&c, spreadsheet).0).collect()
}