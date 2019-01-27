
// FIXME remove import when defining
//       Matrix type
use std::marker::PhantomData;

pub type Num = u8 ;

pub struct Matrix<T> {
    phatom: PhantomData<T>
}

#[derive(Debug,Clone,PartialEq)]
pub struct Point {
    pub x: u64,
    pub y: u64
}

#[derive(Debug,PartialEq)]
pub struct Cell {
    pub content: Data,
    pub loc: Point
}

#[derive(Debug,Clone,PartialEq)]
pub enum Data {
    Val(Num),
    Fun(Function),
    Wrong
}

#[derive(Debug,Clone,PartialEq)]
pub enum Function {
    Count(Point, Point, Num)
}
