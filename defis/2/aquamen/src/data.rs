use std::cmp::Ordering;
use std::collections::HashSet;
use std::collections::HashMap;

pub type Num = u8;
pub type Index = u64;

#[derive(Debug,Clone,Copy,PartialEq,Hash,Eq)]
pub struct Point {
    pub x: Index,
    pub y: Index
}

impl PartialOrd for Point {
    fn partial_cmp(&self, p: &Point) -> Option<Ordering> {
        Some(self.cmp(p))
    }
}

impl Ord for Point {
    fn cmp(&self, p: &Point) -> Ordering {
        match self.y.cmp(&p.y) {
            Ordering::Equal => self.x.cmp(&p.x),
            o => o
        }
    }
}

pub type PointsList = HashSet<Point>;

pub type PointsListsMap = HashMap<Point, PointsList>;

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

pub fn new_cell(d: Data, p: Point) -> Cell {
    Cell { content: d, loc: p}
}

#[derive(Debug,Clone,Copy,PartialEq)]
pub enum Data {
    Val(Num),
    Fun(Function),
    Wrong
}

#[derive(Debug,Clone,Copy,PartialEq)]
pub enum Function {
    Count(Point, Point, Num)
}
