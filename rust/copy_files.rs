use std::env::args as cmd_args;
use std::fs::{read_dir, metadata};
use std::collections::HashSet;
use std::path::Path;
use std::ffi::OsString;

#[inline(always)]
fn usage() {
    println!("Usage: copy_files [source dir] [dest dir]");
}

#[inline(always)]
fn dir_check(dir: &String) -> bool {
    if let Ok(source_metadata) = metadata(&dir) {
        return source_metadata.is_dir();
    }
    false
}

fn main() {
    if cmd_args().len() < 3 { return usage(); }

    let source_dir = cmd_args().skip(1).next().unwrap();
    let dest_dir = cmd_args().skip(2).next().unwrap();

    if source_dir == dest_dir {
        println!(">>>Both destination and source directories are the same");
        return;
    }
    else if !dir_check(&source_dir) {
        println!(">>>{}: is not a directory or there is no such directory", &source_dir);
        return;
    }
    else if !dir_check(&dest_dir) {
        println!(">>>{}: is not a directory or there is no such directory", &dest_dir);
        return;
    }

    let dest_files: HashSet<OsString> = read_dir(&dest_dir).unwrap()
                                                           .map(|elem| elem.unwrap().path())
                                                           .filter(|elem| metadata(&elem).unwrap().is_file())
                                                           .map(|elem| elem.file_name().unwrap().to_os_string())
                                                           .collect();
    let source_files = read_dir(&source_dir).unwrap()
                                            .map(|elem| elem.unwrap().path())
                                            .filter(|elem| metadata(&elem).unwrap().is_file() && dest_files.contains(elem.file_name().unwrap()));
    let dest_path = Path::new(&dest_dir);
    for src_file in source_files {
        let dest_file = dest_path.join(src_file.file_name().unwrap());
        println!("Copy {} into {}", &src_file.display(), &dest_file.display());
        if std::fs::copy(&src_file, &dest_file).is_err() {
            println!(">>>Failed to copy file: {}", src_file.display());
        }
    }
}
