///Script to calculate checksums
extern crate crypto;

use crypto::digest::Digest;
use crypto::md5::Md5;
use crypto::sha1::Sha1;
use crypto::sha2::{Sha256, Sha512};

use std::env::args as cmd_args;
use std::fs::{read_dir, metadata};
use std::io::Read;

macro_rules! is_file {
    ($path:expr) => { std::fs::metadata($path).unwrap().is_file() }
}

macro_rules! input {
    ($msg:expr) => {{
        use std::io::{Read, Write};
        print!($msg);
        std::io::stdout().flush().unwrap();
        std::io::stdin().bytes().next();
    }}
}

#[inline(always)]
fn usage() {
    println!("Usage: hash_check [file/dir]");
}

#[inline(always)]
fn calc_checksum(path: &str) {
    if let Ok(mut file) = std::fs::File::open(&path) {
        let mut file_content: Vec<u8> = vec!();
        let mut md5_sum = Md5::new();
        let mut sha1_sum = Sha1::new();
        let mut sha256_sum = Sha256::new();
        let mut sha512_sum = Sha512::new();

        println!(">>>{}:", &path);
        file.read_to_end(&mut file_content).unwrap();
        md5_sum.input(&file_content);
        sha1_sum.input(&file_content);
        sha256_sum.input(&file_content);
        sha512_sum.input(&file_content);
        println!("MD5:   {}", md5_sum.result_str());
        println!("SHA1:  {}", sha1_sum.result_str());
        println!("SHA256:{}", sha256_sum.result_str());
        println!("SHA512:{}", sha512_sum.result_str());
        println!("=======================================================\n");
    }
    else {
        println!(">>>{}: failed to open", &path);
    }
}

fn main() {
    if cmd_args().len() < 2 { return usage(); }

    for arg in cmd_args().skip(1) {
        if let Ok(arg_meta_data) = metadata(&arg) {
            if arg_meta_data.is_file() {
                calc_checksum(&arg);
            }
            else if let Ok(dir_content) = read_dir(&arg) {
                for entry_path in dir_content.map(|entry| entry.unwrap().path()) {
                    if is_file!(&entry_path) { calc_checksum(&entry_path.to_str().unwrap()); }
                }
            }
            else {
                println!(">>>{}: cannot access content of this dir", &arg);
                continue;
            }
        }
        else {
            println!(">>>{}: cannot access file/directory", &arg);
            continue;
        }
    }

    input!("Press Enter to exit...");
}
