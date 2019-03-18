
use std::rc::Rc;
use std::collections::HashMap;

use data::{Index, Cell, Point, Data};
use area::Rectangle;

use log::*;

static NODE_MAX_SIZE: Index = 100;
static CELLS_NUM_MAX: usize = 4 * (NODE_MAX_SIZE as usize);

enum Content {
    Leaf {
        data: HashMap<Point, Cell>,
        dumped: bool,
    },
    Node {
        left: Rc<Tree>,
        right: Rc<Tree>,
    }
}

type Reader = fn(Point, Point, &String) -> Vec<Cell>;
type Dumper = fn(&String, Vec<Cell>);

pub struct Tree {
    area: Rectangle,
    current_area: Rectangle,
    content: Content,
    id: String,
    reader: Reader,
    dumper: Dumper,
}

fn split_vec(data: &mut HashMap<Point, Cell>, b: Point, e: Point) -> HashMap<Point, Cell> {
    trace!("Splitting data between {:?} and {:?}", b, e);
    data.iter()
        .filter( |c| Rectangle{begin:b, end: e}.contained_in(*c.0) )
        .map(|c| (c.0.clone(), c.1.clone()))
        .collect()
}

fn split_data(data: &mut HashMap<Point, Cell>, begin: Point, mid: Point,
              end: Point, carea: Rectangle,id: &String, reader: Reader, dumper: Dumper) -> Content {
    trace!("Splitting node {}", id);
    Content::Node {
        left: Rc::new(Tree{
            content: Content::Leaf {
                dumped: false,
                data: split_vec(data, begin, mid),
            },
            id: format!("{}/left", id),
            current_area: carea.split(mid).0,
            reader: reader,
            dumper: dumper,
            area: Rectangle{begin: begin, end: mid}
        }),
        right: Rc::new(Tree {
            content: Content::Leaf {
                dumped: false,
                data: split_vec(data, mid, end),
            },
            id: format!("{}/left", id),
            current_area: carea.split(mid).1,
            reader: reader,
            dumper: dumper,
            area: Rectangle{begin: begin, end: mid}
        })
    }
}

impl Tree {

    pub fn new(size: Index, read: Reader, dump: Dumper) -> Tree {
        Tree {
            area: Rectangle {
                begin: Point{x:0, y:0},
                // Assume that the matrix is at least square
                // or that height > width.
                // Make splits more balanced.
                end: Point{x:size, y:size},
            },
            reader: read,
            current_area: Rectangle{begin: Point{x:0, y:0}, end: Point{x:0, y:0}},
            dumper: dump,
            id: String::from("data/root"),
            content: Content::Leaf {
                data: HashMap::new(),
                dumped: false
            }
        }
    }

    pub fn begin(&self) -> Point {
        self.area.begin
    }
    pub fn end(&self) -> Point {
        self.area.end
    }

    fn loaded_cells(&self) -> usize {
        match self.content {
            Content::Leaf{ref data, ref dumped} => data.len(),
            Content::Node{ref right, ref left} => {
                left.loaded_cells() + right.loaded_cells()
            }
        }
    }

    fn dump_data(&mut self) {
        trace!("Dumping data for node {}", self.id);
        match self.content {
            Content::Leaf{ref mut data, ref mut dumped} => {
                let mut vec = Vec::new();
                for j in self.area.begin.y..(self.area.end.y) {
                    for i in self.area.begin.x..(self.area.end.x) {
                        if let Some(cell) = data.get(&Point{x:i, y:j}) {
                            vec.push(*cell);
                        }
                    }
                }
                if !(*dumped) {
                    *dumped = true;
                    (self.dumper)(&self.id, vec);
                    data.clear();
                    data.shrink_to_fit();
                }
            },
            Content::Node{ref mut left, ref mut right} => {
                let r = Rc::get_mut(right).unwrap();
                let l = Rc::get_mut(left).unwrap();
                l.dump_data();
                r.dump_data();
            }
        }
    }

    pub fn get(&mut self, pos: Point) -> Option<Cell> {
        // trace!("Retreiving data for {:?}", pos);
        let res = match self.content {
            Content::Leaf{ref mut data, ref mut dumped } => {
                if *dumped {
                    trace!("Reading data from {}.cells", self.id);
                    let vec = (self.reader)(self.area.begin, self.current_area.end, &self.id);
                    for c in vec {
                        data.insert(c.loc, c);
                    }
                    *dumped = false;
                }
                data.get(&pos).map(|c| c.clone())
            },
            Content::Node{ ref mut left, ref mut right } => {
                let r = Rc::get_mut(right).unwrap();
                let l = Rc::get_mut(left).unwrap();
                if pos < l.area.end {
                    l.get(pos)
                } else {
                    r.get(pos)
                }
            }
        };
        if self.loaded_cells() > CELLS_NUM_MAX {
            self.dump_data();
        }
        res
    }

    pub fn set(&mut self, pos: Point, cell: Data) {
        self.insert(pos, cell);
    }

    pub fn insert(&mut self, pos: Point, cell: Data) {
        trace!("Inserting {:?} at {:?}", cell, pos);
        let new_content = match self.content {
            Content::Leaf{ ref mut data, ref mut dumped } => {
                if *dumped {
                    let vec = (self.reader)(self.area.begin, self.current_area.end, &self.id);
                    for c in vec {
                        data.insert(c.loc, c);
                    }
                    *dumped = false;
                }
                data.insert(pos, Cell{loc: pos, content: cell});
                if data.len() as Index > NODE_MAX_SIZE {
                    let mid = self.area.mid();
                    Some(split_data(data, self.area.begin, mid, self.area.end, self.current_area,
                                    &self.id, self.reader, self.dumper));
                }
                None
            },
            Content::Node{ ref mut left, ref mut right } => {
                let r = Rc::get_mut(right).unwrap();
                let l = Rc::get_mut(left).unwrap();
                if pos.y > self.area.end.y {
                    r.insert(pos, cell);
                } else {
                    l.insert(pos, cell);
                }
                None
            }
        };
        if pos.x >= self.current_area.end.x {
            self.current_area.end.x = pos.x+1;
        }
        if pos.y >= self.current_area.end.y {
            self.current_area.end.y = pos.y+1;
        }
        if let Some(c) = new_content {
            trace!("Node {} has been splitted", self.id);
            self.content = c;
        }
        if self.loaded_cells() > CELLS_NUM_MAX {
            self.dump_data();
        }
    }
}


#[cfg(test)]
mod test {

    use data::Data;
    use data::Point;
    use data::Cell;
    use data::Data::Val;
    use tree2::Tree;
    use rand::Rng;

    fn noop_read(b: Point, e: Point, id: &String) -> Vec<Cell> {
        Vec::new()
    }
    fn noop_dumper(id: &String, data: Vec<Cell>) {}

    fn generate_cells(num: usize, cols: usize) -> Vec<Cell> {
        let mut r = Vec::new();

        let mut rng = rand::thread_rng();

        let mut x = 0;
        let mut y = 0;

        for i in 0..num {
            let n1: u8 = rng.gen();
            r.push(Cell{
                loc: Point{x: x, y: y},
                content: Data::Val(n1),
            });
            if x >= cols as u64 {
                x = 0;
                y = y + 1;
            } else {
                x = x + 1;
            }
        }
        r
    }

    #[test]
    fn add_value() {
        let mut tree = Tree::new(10, noop_read, noop_dumper);
        tree.insert(Point{x: 0, y:0}, Data::Val(10));
        assert!(tree.get(Point{x: 0, y: 0}) == Some(Cell{loc: Point{x: 0, y:0}, content: Data::Val(10)}))
    }

    // #[test]
    fn add_multiple_values() {
        // Fail when dumping data: clear vector without saving old datas
        let mut tree = Tree::new(10, noop_read, noop_dumper);
        let cells = generate_cells(50, 5);
        for Cell{loc: p, content: d} in &cells {
            tree.insert(*p, *d);
        }
        for Cell{loc: p, content: d} in cells {
            assert!(tree.get(p) == Some(Cell{loc: p, content: d}))
        }
    }

    #[test]
    fn add_multiple_values_dump_read() {
        use serialize::dump_cells;
        use serialize::read_data;

        let mut tree = Tree::new(10, read_data, dump_cells);
        let cells = generate_cells(50, 5);
        for Cell{loc: p, content: d} in &cells {
            tree.insert(*p, *d);
        }
        for Cell{loc: p, content: d} in cells {
            println!("value = {:?}, {:?}", p, d);
            let res = tree.get(p);
            println!("tree.get = {:?}", res);
            assert!(res == Some(Cell{loc: p, content: d}))
        }
    }
}
