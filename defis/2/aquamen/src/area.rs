use data::Point;
use data::Index;

#[derive(Copy,Clone)]
pub struct Rectangle {
    pub begin: Point,
    pub end: Point,
}

fn between(p: Index, b: Index, e: Index) -> bool {
    b <= p && p <= e
}

impl Rectangle {
    pub fn area(&self) -> Index {
        (self.end.x - self.begin.x) * (self.end.y - self.begin.y)
    }
    pub fn contained_in(&self, p: Point) -> bool {
        // between(p.x, b.x, e.x) &&
        between(p.y, self.begin.y, self.end.y)
    }
    pub fn mid(&self) -> Point {
        Point {
            x: self.begin.x,
            y: (self.end.y - self.begin.y) / 2
        }
    }
    // Split according to y
    pub fn split(&self, mid: Point) -> (Rectangle, Rectangle) {
        let left = if mid.y > self.end.y {
            Rectangle{
                begin: self.begin,
                end: mid,
            }
        } else {
            Rectangle{
                begin: self.begin,
                end: self.end,
            }
        };
        let right = if mid.y > self.end.y {
            Rectangle{
                begin: mid,
                end: self.end,
            }
        } else {
            Rectangle{
                begin: mid,
                end: mid,
            }
        };
        (left, right)
    }
}
