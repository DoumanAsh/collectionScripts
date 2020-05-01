///Script to compress png with pngcrush.exe
///Just handle files/folders as cmd arguments. Nothing interesting

use std::env::args as cmd_args;
use std::process::{Command, Stdio};
use std::path::Path;
use std::fs::{create_dir, read_dir, metadata};

macro_rules! exec_cmd {
    (cmd=>$cmd:expr, $($arg:expr),*) => { Command::new($cmd)$(.arg($arg))*.stderr(Stdio::null()).stdout(Stdio::null()).status().unwrap(); }
}

macro_rules! input {
    ($msg:expr) => {{
        use std::io::{Read, Write};
        print!($msg);
        std::io::stdout().flush().unwrap();
        std::io::stdin().bytes().next();
    }}
}

macro_rules! is_file {
    ($path:expr) => { std::fs::metadata($path).unwrap().is_file() }
}

macro_rules! is_extension_eq {
    ($path:expr, $ext:expr) => { $path.extension().map_or(false, |ext| ext == $ext) }
}

#[inline(always)]
fn usage() {
    println!("Usage: pngcompress [file/dir]");
    println!("pngcrush.exe is used for compression");
}

fn main() {
    if cmd_args().len() < 2 { return usage(); }

    let script_path = cmd_args().next().unwrap();
    let pngcrush = Path::new(&script_path).parent().unwrap().join("pngcrush.exe");
    let pngcrush = pngcrush.to_str().unwrap();

    drop(script_path);

    for arg in cmd_args().skip(1) {
        let arg_is_file: bool;
        if let Ok(meta_data) = metadata(&arg) {
            arg_is_file = meta_data.is_file();
        }
        else {
            println!(">>>{}: No such file or directory", &arg);
            continue;
        }

        //File handler
        if arg_is_file {
            let arg_path = Path::new(&arg);
            if is_extension_eq!(arg_path, "png") {
                println!(">>>Compress file: {}", arg);
                let crushed_dir = arg_path.parent().unwrap().join("compressed_png");
                let _ = create_dir(crushed_dir.to_str().unwrap());
                exec_cmd!(cmd=>pngcrush, "-d", crushed_dir.to_str().unwrap(), arg_path.to_str().unwrap());
                println!("Result: {}", crushed_dir.join(arg_path.to_str().unwrap()).display());
            }
        }
        //Directory handler
        else if let Ok(dir_content) = read_dir(&arg) {
            for entry_path in dir_content {
                let entry_path = entry_path.unwrap().path();

                if is_file!(&entry_path) && is_extension_eq!(entry_path, "png") {
                    println!(">>>Compress file: {}", entry_path.display());
                    let crushed_dir = entry_path.parent().unwrap().join("compressed_png");
                    let _ = create_dir(crushed_dir.to_str().unwrap());
                    exec_cmd!(cmd=>pngcrush, "-d", crushed_dir.to_str().unwrap(), entry_path.to_str().unwrap());
                    println!("Result: {}", crushed_dir.join(entry_path.file_name().unwrap()).display());
                }
            }
        }
        //Error handler
        else {
            println!(">>>{}: cannot access directory", &arg);
            continue;
        }
    }
    input!("Press Enter to exit...");
}
