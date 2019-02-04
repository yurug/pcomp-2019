
use std::collections::HashSet;

use data::{Matrix, Cell, Point, Requirements};
use data::Requirements::Empty;
use data::Data::*;
use data::Function::*;

use bench::bench;

// FIXME test!!!!

// FIXME should return a list of dependencies
// in case of if we can't completly compute
// the cell (because we don't have the full sheet)
// FIXME improve perfs
// FIXME add some kind of Result so that we can print
// an error
fn eval_cell(cell: &Cell,
             sheet: &Matrix<Cell>,
             viewed: &mut HashSet<Point>,
             bench: bench::Sender) -> (Cell, Requirements) {
    match cell.content {
        Val(_i) => {
            let _ = bench.send(1);
            if !viewed.contains(&cell.loc) {
                (cell.clone(), Empty)
            } else {
                (Cell{content: Wrong, loc: cell.loc}, Empty)
            }
        },
        Fun(Count(b, e, v)) => {
            let _ = bench.send(1);
            if !viewed.contains(&cell.loc) {
                viewed.insert(cell.loc);
                let mut acc = 0;
                for x in b.x..e.x+1 {
                    for y in b.y..e.y+1 {
                        match eval_cell(&sheet.get(Point{x: x, y: y}), sheet, viewed, bench.clone()).0.content {
                            // FIXME find out why it's a ref and not a value
                            Val(i) => if i == v.clone() {
                                acc += 1;
                            },
                            _ => return (Cell{content: Wrong, loc: cell.loc}, Empty)
                        }
                    }
                }
                (Cell{content: Val(acc), loc: cell.loc}, Empty)
            } else {
                (Cell{content: Wrong, loc: cell.loc}, Empty)
            }
        }
        _ => {
            let _ = bench.send(1);
            (cell.clone(), Empty)
        }

    }
}

// FIXME add a way to communicate to the caller (and the central authority)
pub fn eval(input: &Matrix<Cell>, bench: bench::Sender) -> Matrix<Cell> {
    let mut res = Vec::new();
    for line in input.lines() {
        let mut lres: Vec<Cell>  = Vec::with_capacity(line.len());
        for cell in line {
            let (r, _) = eval_cell(&cell, input, &mut HashSet::new(), bench.clone());
            lres.push(r)
        }
        res.push(lres)
    }
    Matrix::from_2d_vec(res)
}

pub fn eval_changes(changes: &Vec<Cell>, spreadsheet: &Matrix<Cell>, bench: bench::Sender) -> Vec<Cell> {
    changes.into_iter().map(|c| eval_cell(&c, spreadsheet, &mut HashSet::new(), bench.clone()).0).collect()
}
