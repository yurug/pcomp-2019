use std::hash::{Hash, Hasher};
use std::cmp::Ordering;
use std::collections::HashSet;
use std::collections::HashMap;

use ::Data::{Fun, Val, Wrong};
use ::Function::Count;

pub type Num = u8;
pub type Index = u128;


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
    inner: Vec<Vec<Data>>,
    functions: PointsListsMap,
    bindings: PointsListsMap,
    changes: PointsList
}

impl Spreadsheet {
    pub fn new(n: Index) -> Self {
        Spreadsheet {
            inner: Vec::new(),
            functions: HashMap::new(),
            bindings: HashMap::new(),
            changes: HashSet::new()
        }
    }

    pub fn add_line(&mut self, cells: Vec<Cell>) {
        cells.iter().for_each(|c| self.bind(&c));
        let data = cells.iter().map(|c| c.content).collect();
        self.inner.push(data);
    }    

    pub fn eval(&mut self) -> &Vec<Vec<Data>> {
        self._eval();
        &self.inner
    }

    pub fn update(&mut self, d: Data, p: Point) {
        // Modifies the cell data and adds the cell and his children to the changes
    }
    
    pub fn changes(&mut self) -> Vec<Cell> {
        let mut changes = Vec::new();

        self.eval();
        
        for point in self.changes.iter() {
            changes.push(Cell { content: self.get(point), loc: point.clone() });
        }
        
        changes.sort_by(|c1, c2| c1.cmp(&c2));
        
        changes
    }

    ///======== PRIVATE SCOPE ========///

    fn get(&self, p: &Point) -> Data {
        self.inner[p.x as usize][p.y as usize]
    }    

    fn bind(&mut self, c: &Cell) {
        match c.content {
            Val(_) | Wrong => (),
            Fun(f) => self.bind_function(f, c.loc)
        }
    }

    fn bind_function(&mut self, f: Function, p: Point) {
        let key = p;
        let mut value = HashSet::new();
        
        match f {
            Count(Point { x: x1, y: y1 }, Point { x: x2, y: y2 }, _) =>
                for x in x1..(x2 + 1) {
                    for y in y1..(y2 + 1) {
                        let pcell = Point { x, y };
                        value.insert(p);
                        self.bind_cell(pcell.clone(), p.clone());
                    }
                }
        }

        self.functions.insert(key, value);
    }

    fn bind_cell(&mut self, pcell: Point, p: Point) {
        match self.bindings.get_mut(&pcell) {
            Some(set) => {
                set.insert(p);
                return;        // FCKING UGLY (=> double mutable borrow)
            },
            None => ()
        }

        let mut set = HashSet::new();
        set.insert(p);
        self.bindings.insert(pcell, set);
    }    
    
    fn _eval(&mut self) {
        // Calls eval_fun() on each functions not yet evaluated
    }

    fn eval_fun(&self, p: Point) {
        
    }    
}

fn main() {}
