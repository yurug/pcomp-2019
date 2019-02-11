
// use std::fs::File;
// use std::io::Write;

// use data::{Cell, Data};
// use data::Data::{Val, Wrong};

// // FIXME test!!!
// pub fn print_spreadsheet(block: Vec<Vec<Data>>, filename: &str) {

//     let mut file = File::create(filename).expect(
//         &format!("Error creating file {}", filename)
//     );

//     for line in block {
//         writeln!(&mut file, "{}", line.into_iter().map(|data| {
//             to_string(&data)
//         }).collect::<Vec<String>>().join(";")).unwrap();
//     }
// }

// pub fn print_changes(changes: Vec<Cell>, effects: Vec<Vec<Cell>>, filename: &str) {
//     let mut file = File::create(filename).expect(
//         &format!("Error creating file {}", filename)
//     );

//     for (i, change) in changes.iter().enumerate() {
//         writeln!(&mut file, "after \"{} {} {}\":",
//                  change.loc.x, change.loc.y, to_string(&change.content)
//         ).unwrap();
        
//         for effect in effects.get(i).unwrap() { // safe
//             writeln!(&mut file, "{} {} {}",
//                      effect.loc.x, effect.loc.y, to_string(&effect.content)
//             ).unwrap();
//         }
//     }
// }

// fn to_string(data: &Data) -> String {
//     match data {
//         Val(v) => v.to_string(),
//         Wrong => "P".to_owned(),
//         _ => panic!("Unexpected value while printing")
//     }
// }
