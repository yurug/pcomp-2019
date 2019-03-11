use std::fs::File;
use std::fs::create_dir_all;
use std::io::Write;
use std::io::Read;
use bench;
use log::*;
use std::path::Path;
use data::Cell;
use data::Data::*;
use data::*;
use data::Index;
use data::Point;
use data::Function::*;

pub fn read_data(begin: Point, end: Point, filename: &String) -> Vec<Cell> {
    let f = format!("{}.cells", filename);
    let mut file = File::open(f).unwrap(); // FIXME better error management
    let mut res: Vec<u8> = Vec::new();
    file.read(&mut res).unwrap();
    let mut cpt = 0;
    let mut x = begin.x;
    let mut y = begin.y;
    let mut data = Vec::new();
    while cpt < res.len() {
        let t = res[cpt];
        let v = res[cpt+1];
        let r = match t {
            0 => Val(v),
            1 => Fun(Count(Point{x:0,y:0}, Point{x:0,y:0}, 0)),
            2 => Wrong,
            _ => panic!("Unexpected value in data dump")
        };
        trace!("Reading cell {:?}", Cell{loc:Point{x:x,y:y},content:r});
        bench::bench::get_sender().send(1);
        data.push(Cell{
            content: r,
            loc: Point{x: x, y: y},
        });
        if x <= end.x {
            x += 1;
        } else {
            x = begin.x;
            y += 1;
        }
        cpt += 2;
    }
    data
}

// FIXME put magic value in enum or in cste ?
pub fn dump_val_to(i: u8, dest: &mut Vec<u8>) {
    dest.push(0);
    dest.push(i);
}

pub fn dump_fun_to(dest: &mut Vec<u8>) {
    dest.push(1);
    dest.push(0);
}

pub fn dump_wrong_to(dest: &mut Vec<u8>) {
    dest.push(2);
    dest.push(0);
}

// Consume the data
pub fn dump_cells(filename: String, data: Vec<Cell>) {
    trace!("Dumping in {}.cells", filename);
    create_dir_all(Path::new(&filename)
                   .parent()
                   .unwrap()
                   .to_str()
                   .unwrap()).unwrap();
    let mut file = File::create(format!("{}.cells",filename)).unwrap(); // FIXME better error management
    let mut res = Vec::new();
    trace!("Writing data of node {} : {:?} ", filename, data);
    for c in data {
        bench::bench::get_sender().send(-1);
        trace!("Dumping {:?}", c);
        match c.content {
            Val(i) => dump_val_to(i, &mut res),
            Fun(_) => dump_fun_to(&mut res),
            Wrong  => dump_wrong_to(&mut res),
        }
    }
    trace!("Writing cells of node {} : {:?} ", filename, res);
    file.write_all(&res);
}
