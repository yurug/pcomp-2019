use std::fs::File;
use std::fs::create_dir_all;
use std::io::Write;
use std::io::Read;
use std::rc::Rc;
use std::path::Path;

use data::Point;
use area::Rectangle;
use area::*;
// use area::Rectangle::*;
use serialize::read_data;
use serialize::dump_val_to;
use serialize::dump_wrong_to;
use serialize::dump_fun_to;
use serialize::*;
use data::Cell;
use data::Index;
use data::Data::*;
use data::Data;
use data::Function::*;

use bench;

use log::*;

static NODE_MAX_SIZE: Index = 10;

// Idea: store the nodes in a vec
// and find a way to store them
// in a cache-friendly way

// FIXME try to avoid string copy
// FIXME find why nothing is written
// FIXME check the result of computation
// FIXME find why the splits are weird => add -> resize ?? FIXED by using with_size ?

enum Content {
    Leaf {
        // Generated when dumping data
        filename: String,
        // Cell waiting to be dumped on disk
        // Used when filling the node (before dumping variables)
        // or before computation (when we need to load vars)
        data: Vec<Cell>,
        dumped: bool,
    },
    Node {
        left: Rc<Tree>,
        right: Rc<Tree>,
        // FIXME put id/filename in Tree
        id: String,
    }
}

pub struct Tree {
    // FIXME abstract away in Rect struct
    pub begin: Point,
    pub end: Point,
    content: Content,
}


fn split_data(data: &Vec<Cell>, b: Point, e: Point) -> Vec<Cell> {
    trace!("Getting data between {:?} and {:?}", b, e);
    data.iter()
        .filter( |c| contained_in(c.loc, b, e) )
        .map(|c| c.clone())
        .collect()
}


fn split_content(filename: String, begin: Point, end: Point, data: &Vec<Cell>, mid: Point) -> Content {
    trace!("Building the sub leaf of {}: ({:?}; {:?}) & ({:?}; {:?})", filename, begin, mid, mid, end);
    Content::Node {
        left: Rc::new(Tree{
            begin: begin,
            end: mid,
            content: Content::Leaf {
                dumped: false,
                filename: format!("{}/left", filename),
                data: split_data(&data, begin, mid)
            }
        }),
        right: Rc::new(Tree{
            begin: mid,
            end: end,
            content: Content::Leaf {
                dumped: false,
                filename: format!("{}/right", filename),
                data: split_data(&data, mid, end)
            }
        }),
        id: filename,
    }
}

fn add_cell_leaf(filename: String, begin: Point, end: Point, data: &mut Vec<Cell>, cell: Cell) -> Option<Content> {
    data.push(cell);
    if data.len() > (NODE_MAX_SIZE as usize) {
        let mid = Point {
            x: end.x,
            y: (end.y  - begin.y) / 2,
        };
        trace!("Splitting content of leaf {} in {:?}", filename, mid);
        Some(split_content(filename, begin, end, &data, mid))
    } else {
        None
    }
}

fn split_leaf(file: String, begin: Point, end: Point, data: &mut Vec<Cell>) -> Content {
    let mid = Point {
        x: end.x,
        y: (end.y  - begin.y) / 2,
    };
    trace!("Splitting content of leaf {} in {:?}", file, mid);
    split_content(file, begin, end, &data, mid)
}

fn need_resize(rect: Rectangle, p: Point) -> bool {
    // If we need to make the area grow
    // e.g. adding a cell in a new line
    // (since we don't know beforehand the size of the sheet)
    let (begin, end) = rect;
    p.y > end.y
}

fn resize_for(rect: Rectangle, loc: Point) -> Rectangle {
    let (begin, end) = rect;
    (begin, Point{x: end.x, y: loc.y})
}

fn resize(begin: &mut Point, end: &mut Point, new: Point) {
    if need_resize((*begin, *end), new) {
        trace!("Resizing the leaf");
        let (b, e) = resize_for((*begin, *end), new);
        *begin = b; // FIXME find how to put self.*
        *end = e;     // in destructuring
    }
}


impl Tree {

    pub fn new() -> Tree {
        trace!("Creating Tree");
        Tree {
            begin: Point{x:0, y:0},
            end: Point{x:0, y:0},
            content: Content::Leaf {
                filename: String::from("data/root"),
                data: Vec::new(),
                dumped: false
            }
        }
    }

    pub fn with_size(size: Index) -> Tree {
        trace!("Creating Tree with size {}", size);
        Tree {
            begin: Point{x:0, y:0},
            // Assume that the matrix is at least square
            // or that height > width.
            // Make splits more balanced.
            end: Point{x:size, y:size},
            content: Content::Leaf {
                filename: String::from("data/root"),
                data: Vec::new(),
                dumped: false
            }
        }
    }



    pub fn add_cell(&mut self, cell: Cell) {
        let mut need_split = false;
        let c = match self.content {
            Content::Leaf{ref filename, ref mut data, ref mut dumped} => {
                trace!("Adding {:?} to the leaf {}", cell, filename);

                resize(&mut self.begin, &mut self.end, cell.loc);

                if *dumped {
                    trace!("Reading data from {}", filename);
                    *data = read_data(self.begin, self.end, filename);
                }
                data.push(cell);

                if data.len() > (NODE_MAX_SIZE as usize) {
                    Some(split_leaf(filename.to_string(), self.begin, self.end, data))
                } else {
                    None
                }
            },
            Content::Node{ ref mut left, ref mut right, id:_ } => {
                let end = (*left).end;
                let r = Rc::get_mut(right).unwrap();
                let l = Rc::get_mut(left).unwrap();
                if cell.loc.y > end.y {
                    r.add_cell(cell);
                } else {
                    l.add_cell(cell)
                }

                resize(&mut self.begin, &mut self.end, cell.loc);

                None
            }
        };
        match c {
            Some(c) => {
                trace!("The leaf need to be split");
                self.content = c;
                // If we need to split data, then dump them
                self.dump_data();
            },
            None => {}
        };
    }

    fn dump_data(&mut self) {
        trace!("Dumping data");
        match self.content {
            Content::Leaf{ ref mut filename, ref mut data, ref mut dumped } => {
                *dumped = true;
                trace!("Dumping in {}.cells", filename);
                create_dir_all(Path::new(filename)
                               .parent()
                               .unwrap()
                               .to_str()
                               .unwrap()).unwrap();
                let mut file = File::create(format!("{}.cells",filename)).unwrap(); // FIXME better error management
                let mut res = Vec::new();
                for c in data {
                    trace!("Dumping {:?}", c);
                    match c.content {
                        Val(i) => dump_val_to(i, &mut res),
                        Fun(_) => dump_fun_to(&mut res),
                        Wrong  => dump_wrong_to(&mut res),
                    }
                }
                file.write_all(&res);
            },
            Content::Node{ref mut left, ref mut right, ref id} => {
                trace!("Dumping node {}", id);
                Rc::get_mut(right).unwrap().dump_data();
                Rc::get_mut(left).unwrap().dump_data();
            }
        }
    }

    pub fn set_cell(&mut self, pos: Point, cell: Data) {
        match self.content {
            Content::Leaf{ref filename, ref mut data, ref dumped} => {
                trace!("Modifying cell at pos {:?}", pos);
                if *dumped {
                    *data = read_data(self.begin, self.end, filename);
                }
                for c in data {
                    if c.loc == pos {
                        trace!("Setting the cell at {:?}", pos);
                        c.content = cell;
                        return
                    }
                }
                // If the cell doesn't exists, add it
                // add_cell_leaf(self.begin, self.end, data, Cell{loc: pos, content: cell});
            },
            Content::Node{ref mut left, ref mut right, id:_} => {
                let end = (*left).end;
                let r = Rc::get_mut(right).unwrap();
                let l = Rc::get_mut(left).unwrap();
                if pos.y > end.y {
                    r.set_cell(pos, cell)
                } else {
                    l.set_cell(pos, cell)
                }
            }
        }
    }

    pub fn get_cell(&mut self, pos: Point) -> Option<Cell> {
        match self.content {
            Content::Leaf{ref filename, ref mut data, ref dumped} => {
                if *dumped {
                    *data = read_data(self.begin, self.end, filename);
                }
                for c in data {
                    if c.loc == pos {
                        return Some(*c)
                    }
                }
                None
            },
            Content::Node{ref mut left, ref mut right, id:_} => {
                let end = (*left).end;
                let r = Rc::get_mut(right).unwrap();
                let l = Rc::get_mut(left).unwrap();
                if pos.y > end.y {
                    r.get_cell(pos)
                } else {
                    l.get_cell(pos)
                }
            }
        }
    }

    // Interface for spreadsheet to make sure
    // we don't have to much changes to do
    pub fn get(&mut self, pos: Point) -> Option<Cell> {
        self.get_cell(pos)
    }

    pub fn insert(&mut self, pos: Point, cell: Data) {
        match self.get(pos) {
            None => self.add_cell(Cell{loc: pos, content: cell}),
            Some(_) => self.set_cell(pos, cell),
        }
    }
}

