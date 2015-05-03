///Script to compress png with pngcrush.exe
///Just handle files/folders as cmd arguments. Nothing interesting

use std::env::args as cmd_args;
use std::process::Command;
use std::path::Path;
use std::fs::{create_dir, read_dir};

macro_rules! exec_cmd {
    (cmd=>$cmd:expr, $($arg:expr),*) => { Command::new($cmd)$(.arg($arg))*.status().unwrap(); }
}

#[inline(always)]
fn usage() {
    println!("Usage: pngcompress [file/dir]");
    println!("pngcrush.exe is used for compression");
}

fn main() {
    if cmd_args().len() < 2 { return usage(); }

    let script_path = cmd_args().next().unwrap();
    let script_dir = Path::new(&script_path).parent().unwrap();
    let pngcrush = script_dir.join("pngcrush.exe");
    let pngcrush = pngcrush.to_str().unwrap();

    for arg in cmd_args().skip(1) {
        let arg_path = Path::new(&arg);
        let is_file: bool = arg_path.extension().is_some();

        if is_file && arg.ends_with("png") {
            println!(">>>Compress file: {}", arg);
            let crushed_dir = arg_path.parent().unwrap().join("compressed_png");
            let _ = create_dir(crushed_dir.to_str().unwrap());
            exec_cmd!(cmd=>pngcrush, "-d", crushed_dir.to_str().unwrap(), arg_path.to_str().unwrap());
            println!("Result: {}", crushed_dir.join(arg_path.to_str().unwrap()).display());
        }
        else {
            let dir_content = read_dir(arg_path.to_str().unwrap());

            //Assume that it is not dir then
            if dir_content.is_err() { continue; }

            let dir_content = dir_content.unwrap();

            for entry in dir_content {
                let entry_path = entry.unwrap().path();
                let is_file = entry_path.extension().is_some();

                if is_file && entry_path.to_str().unwrap().ends_with(".png") {
                    println!(">>>Compress file: {}", entry_path.display());
                    let crushed_dir = entry_path.parent().unwrap().join("compressed_png");
                    let _ = create_dir(crushed_dir.to_str().unwrap());
                    exec_cmd!(cmd=>pngcrush, "-d", crushed_dir.to_str().unwrap(), entry_path.to_str().unwrap());
                    println!("Result: {}", crushed_dir.join(entry_path.file_name().unwrap()).display());
                }
            }
        }
    }
}
