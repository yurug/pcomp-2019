
use std::sync::mpsc::channel;
use std::fs;

use process::process;

use bench::bench;

// FIXME test!!!!

pub fn schedule(sheet_path: &str,
                user_mod_path: &str,
                view0_path: &str,
                changes_path: &str,
                bench: bench::Sender) {

    // Step 1

    let sheet = fs::read_to_string(sheet_path)
        .expect("Something went wrong reading the first file");
    let changes = fs::read_to_string(user_mod_path)
        .expect("Something went wrong reading the second file");

    let (sender, _recv) = channel();
    process(sheet, changes, view0_path, changes_path, sender, bench);
}
