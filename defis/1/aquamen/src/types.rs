use std::hash::{Hash, Hasher};
use std::cmp::Ordering;
use std::collections::HashSet;
use std::collections::HashMap;

use ::Data::{Fun, Val, Wrong};
use ::Function::Count;

pub type Num = u8;
pub type Index = u128;

/**
 * Note de Hugo : Je pense qu'il ne faut pas regrouper les types représentant
 * les données parsées et les types représentant les données structurées
 * dans le même fichier/module. En compilation, ce serait comme définir
 * l'environnement dans le même fichier/module que l'AST source. Il faut
 * garder un fichier data.rs (qu'on importe ici et dans le parser)
 * et avoir en plus ce fichier nommé spreadsheet.rs.
**/

///===============================///
///============ Point ============///
///===============================///


#[derive(Debug,Clone,Copy,PartialEq)]
pub struct Point {
    pub x: Index,
    pub y: Index
}

impl Point {
    pub fn cmp(self, p: &Point) -> Ordering {
        match self.x.cmp(&p.x) {
            Ordering::Equal => self.y.cmp(&p.y),
            o => o
        }
    }
}

impl Hash for Point {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.x.hash(state);
        self.y.hash(state);
    }
}

impl Eq for Point {}

pub type PointsList = HashSet<Point>;

pub type PointsListsMap = HashMap<Point, PointsList>;


///===============================///
///============= Cell ============///
///===============================///


#[derive(Debug,Clone,Copy,PartialEq)]
pub struct Cell {
    pub content: Data,
    pub loc: Point
}

impl Cell {
    pub fn cmp(self, c: &Cell) -> Ordering {
        self.loc.cmp(&c.loc)
    }
}


///===============================///
///============= Data ============///
///===============================///


#[derive(Debug,Clone,Copy,PartialEq)]
pub enum Data {
    Val(Num),
    Fun(Function),
    Wrong
}


///===============================///
///=========== Function ==========///
///===============================///

#[derive(Debug,Clone,Copy,PartialEq)]
pub enum Function {
    Count(Point, Point, Num)
}


///===============================///
///========= Spreadsheet =========///
///===============================///


pub struct Spreadsheet {
    width: Index,
    inner: HashMap<Point, Data>,
    bindings: PointsListsMap,
    changes: PointsList
}

impl Spreadsheet {
    
    /**
     * Note de Hugo : je ne teste que ce sous-ensemble de fonctions pour
     * conserver une interface minimale.
     * ======================================================================
     */

    pub fn new(n: Index) -> Self {
        Spreadsheet {
            width: n,
            inner: HashMap::new(),
            bindings: HashMap::new(),
            changes: HashSet::new()
        }
    }
    
    pub fn add_cell(&mut self, cell: Cell) {
        match self.inner.get(&cell.loc) {
            Some(_) => { self.update_changes(cell.loc); },
            None => self.bind(&cell)
        }

        self.inner.insert(cell.loc, cell.content);
    }
    
    pub fn eval(&mut self) -> Vec<Data> {        
        let len = self.inner.len();
        let mut res = Vec::with_capacity(len);
        let width = self.width;

        for i in 0..(len as u128 / width) {
            for j in 0..width {
                res.push(self.inner.get(&Point { x: i, y: j }).unwrap().clone());
            }
        }
        
        res
    }
    
    pub fn eval_one(&self, p: Point) -> Option<Cell> { // Recursive
        let data = match self.inner.get(&p).unwrap() {
            
            Fun(Count(Point { x: x1, y: y1 }, Point { x: x2, y: y2 }, n)) => {
                let mut res = 0;
                
                for x in x1..(x2 + 1) {
                    for y in y1..(y2 + 1) {
                        if let Some(val) = self.eval_one(Point { x: x, y: y }) {
                            res += 1;
                        }
                        else {
                            return None;
                        }
                    }
                }

                Val(res)
            },

            x => x.clone()
        };
        
        Some(Cell { content: data, loc: p })
    }
    
    pub fn changes(&self) -> Vec<Cell> {
        let mut changes = Vec::new();
        
        for point in &self.changes {
            if let Some(cell) = self.eval_one(point.clone()) { // hard to handle if None
                changes.push(cell);
            }
        }
        
        changes.sort_by(|c1, c2| c1.cmp(&c2));
        
        changes
    }
    
    /**
     * ======================================================================
     */
     
    pub fn add_line(&mut self, cells: Vec<Cell>) {
        cells.into_iter().for_each(|c| self.add_cell(c));
    }
    

    ///======== PRIVATE SCOPE ========///

    fn bind(&mut self, c: &Cell) {
        match c.content {
            Val(_) | Wrong => (),
            Fun(f) => self.bind_function(f, c.loc)
        }
    }

    fn bind_function(&mut self, f: Function, p: Point) {        
        match f {
            Count(Point { x: x1, y: y1 }, Point { x: x2, y: y2 }, n) =>
                for x in x1..(x2 + 1) {
                    for y in y1..(y2 + 1) {
                        let pcell = Point { x, y };
                        self.bind_cell(pcell, p);
                    }
                }
        }
    }

    fn bind_cell(&mut self, pcell: Point, p: Point) {
        if let Some(set) = self.bindings.get_mut(&pcell) {
            set.insert(p);
            return;
        }
        
        let mut set = HashSet::new();
        set.insert(p);
        self.bindings.insert(pcell, set);
    }

    fn update_changes(&mut self, p: Point) { // Recursive
        self.changes.insert(p);

        let value = self.bindings.get(&p);

        if let Some(set) = value {
            for point in set {
                self.update_changes(point.clone());
            }
        }
    }
}

fn main() {}

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn test_simple_val() {
        let d = Val(5) ;
        let input = Cell{content:d,loc:Point{x:0,y:0}} ;
        let output = vec![!vec[d]] ;
        let g = Spreadsheet::new(1) ;
        g::add_cell(input) ;
        assert_eq!(g::eval(),output) ;
    }

    #[test]
    #[should_panic]
    fn test_ill_locations() {
        let d = Val(5) ;
        let input = Cell{content:d,loc:Point{x:8,y:1}} ;
        let g = Spreadsheet::new(1) ;
        g::add_cell(input) ;
        g::eval()
    }

    #[test]
    fn test_simple_error() {
        let d = Wrong ;
        let input = Cell{content:d,loc:Point{x:0,y:0}} ;
        let output = vec![!vec[d]] ;
        let g = Spreadsheet::new(1) ;
        g::add_cell(input) ;
        assert_eq!(g::eval(),output) ;
    }

    #[test]
    fn test_simple_location_handling() {
        let output = vec![
            vec![Cell{content:Val(5),loc:Point{x:0,y:0}},
                 Cell{content:Val(8),loc:Point{x:1,y:0}}],
            vec![Cell{content:Val(2),loc:Point{x:0,y:1}},
                 Cell{content:Val(9),loc:Point{x:1,y:1}}]
        ] ;
        let g = Spreadsheet::new(2) ;
        for lines in output.iter() {
            for c in lines.iter() {
                g::add_cell(input) ;
            }
        }
        assert_eq!(g::eval(),output) ;
    }

    #[test]
    fn test_tricky_location_handling() {
        let output = vec![
            vec![Cell{content:Val(5),loc:Point{x:0,y:0}},
                 Cell{content:Val(8),loc:Point{x:1,y:0}}],
            vec![Cell{content:Val(2),loc:Point{x:0,y:1}},
                 Cell{content:Val(9),loc:Point{x:1,y:1}}]
        ] ;
        let g = Spreadsheet::new(2) ;
        for lines in (output.rev().iter()) {
            for c in (lines.rev().iter()) {
                g::add_cell(input) ;
            }
        }
        assert_eq!(g::eval(),output) ;
    }

    #[test]
    fn test_simple_count() {
        let pattern = Val(5) ;
        let res = Val(2) ;
        let r = (Point{x:0,y:0},Point{x:2,y:0});
        let output = vec![
            vec![Cell{content:pattern,loc:Point{x:0,y:0}},
                 Cell{content:Val(8),loc:Point{x:1,y:0}},
                 Cell{content:pattern,loc:Point{x:2,y:0}}],
            vec![Cell{content:Val(2),loc:Point{x:0,y:1}},
                 Cell{content:Val(2),loc:Point{x:1,y:1}},
                 Cell{content:Fun(Count(r.0,r.1,pattern)),loc:Point{x:2,y:1}}]
        ] ;
        let g = Spreadsheet::new(3) ;
        for lines in output.iter() {
            for c in lines.iter() {
                g::add_cell(input) ;
            }
        }
        output[1][2] = res ;
        assert_eq!(g::eval(),output) ;
    }

    #[test]
    fn test_wrong_propagation_count() {
        let pattern = Val(5) ;
        let res = Wrong ;
        let r = (Point{x:0,y:0},Point{x:2,y:0});
        let output = vec![
            vec![Cell{content:pattern,loc:Point{x:0,y:0}},
                 Cell{content:Wrong,loc:Point{x:1,y:0}},
                 Cell{content:pattern,loc:Point{x:2,y:0}}],
            vec![Cell{content:Val(2),loc:Point{x:0,y:1}},
                 Cell{content:Val(2),loc:Point{x:1,y:1}},
                 Cell{content:Fun(Count(r.0,r.1,pattern)),loc:Point{x:2,y:1}}]
        ] ;
        let g = Spreadsheet::new(3) ;
        for lines in output.iter() {
            for c in lines.iter() {
                g::add_cell(input) ;
            }
        }
        output[1][2] = res ;
        assert_eq!(g::eval(),output) ;
    }
    
}
