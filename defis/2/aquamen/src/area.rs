use data::Point;
use data::Index;

pub type Rectangle = (Point, Point);

pub fn area(b: Point, e: Point) -> Index {
    (e.x - b.x) * (e.y - b.y)
}

pub fn between(p: Index, b: Index, e: Index) -> bool {
    b <= p && p <= e
}

pub fn contained_in(p: Point, b: Point, e: Point) -> bool {
    // between(p.x, b.x, e.x) &&
    between(p.y, b.y, e.y)
}

// use data::Point;
// use data::Index;

// #[derive(Copy,Clone)]
// pub struct Rectangle {
//     pub begin: Point,
//     pub end: Point,
// }

// fn between(p: Index, b: Index, e: Index) -> bool {
//     b <= p && p <= e
// }

// impl Rectangle {
//     pub fn area(&self) -> Index {
//         (self.end.x - self.begin.x) * (self.end.y - self.begin.y)
//     }
//     pub fn contained_in(&self, p: Point) -> bool {
//         // between(p.x, b.x, e.x) &&
//         between(p.y, self.begin.y, self.end.y)
//     }
// }
