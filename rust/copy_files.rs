use std::env::args as cmd_args;
use std::fs::{read_dir, metadata};
use std::collections::HashSet;
use std::path::Path;
use std::ffi::OsString;

#[inline(always)]
fn usage() {
    println!("Usage: copy_files [source dir] [dest dir]");
    println!("It copies only files from destination direcotry");
}

#[inline(always)]
///Check if giver argument is directory or not
fn dir_check<T: AsRef<Path>>(dir: T) -> bool {
    if let Ok(source_metadata) = metadata(&dir) {
        return source_metadata.is_dir();
    }
    false
}

///Macro wrapper for directiers check.
///Perform return if directories are not valid for copy
macro_rules! dir_check_copy {
    ($dir1:expr, $dir2:expr) => {
        if $dir1 == $dir2 {
            println!(">>>Both destination and source directories are the same");
            return;
        }
        dir_check_copy!($dir1);
        dir_check_copy!($dir2);
    };
    ($dir:expr) => {
        if !dir_check($dir) {
            println!(">>>{}: is not a directory or there is no such directory", $dir);
            return;
        }
    };
}

///Performs copy of the files from @source_dir to @dest_dir.
///Only files in @dest_dir are going to be copied.
fn copy(source_dir: &str, dest_dir: &str) {
    dir_check_copy!(source_dir, dest_dir);

    let dest_files: HashSet<OsString> = read_dir(&dest_dir).unwrap()
                                                           .map(|elem| elem.unwrap().path())
                                                           .filter(|elem| metadata(&elem).unwrap().is_file())
                                                           .map(|elem| elem.file_name().unwrap().to_os_string())
                                                           .collect();
    let source_files = read_dir(&source_dir).unwrap()
                                            .map(|elem| elem.unwrap().path())
                                            .filter(|elem| metadata(&elem).unwrap().is_file() &&
                                                           dest_files.contains(elem.file_name().unwrap()) );

    let dest_path = Path::new(&dest_dir);
    for src_file in source_files {
        let dest_file = dest_path.join(src_file.file_name().unwrap());
        println!("Overwrite {} into {}", &src_file.display(), &dest_file.display());
        if std::fs::copy(&src_file, &dest_file).is_err() {
            println!(">>>Failed to copy file: {}", src_file.display());
        }
    }
}

fn main() {
    if cmd_args().len() < 3 { return usage(); }

    let source_dir = cmd_args().skip(1).next().unwrap();
    let dest_dir = cmd_args().skip(2).next().unwrap();

    copy(&source_dir, &dest_dir)
}
