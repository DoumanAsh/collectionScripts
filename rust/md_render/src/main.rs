extern crate hoedown;
use hoedown::renderer::Render;

use std::env::args as cmd_args;
use std::io::{Write, BufReader};

const USAGE: &'static str  = "Usage: md_render <files>...\n
";

const EXT_TABLES: u32            = 1 << 0;
const EXT_FENCED_CODE: u32       = 1 << 1;
const EXT_FOOTNOTES: u32         = 1 << 2;
const EXT_AUTOLINK: u32          = 1 << 3;
const EXT_STRIKETHROUGH: u32     = 1 << 4;
const EXT_UNDERLINE: u32         = 1 << 5;
const EXT_HIGHLIGHT: u32         = 1 << 6;
const EXT_QUOTE: u32             = 1 << 7;
const EXT_NO_INTRA_EMPHASIS: u32 = 1 << 11;
const EXT_SPACE_HEADERS: u32     = 1 << 12;

macro_rules! is_file {
    ($path:expr) => { std::fs::metadata($path).unwrap().is_file() }
}

#[inline]
fn usage() {
    println!("{}", USAGE);
}

fn main() {
    if cmd_args().len() < 2 { return usage(); }

    let md_ext = hoedown::Extension::from_bits_truncate(EXT_TABLES |
                                                        EXT_FENCED_CODE |
                                                        EXT_FOOTNOTES |
                                                        EXT_AUTOLINK |
                                                        EXT_STRIKETHROUGH |
                                                        EXT_UNDERLINE |
                                                        EXT_HIGHLIGHT |
                                                        EXT_QUOTE |
                                                        EXT_NO_INTRA_EMPHASIS |
                                                        EXT_SPACE_HEADERS);
    let flags = hoedown::renderer::html::Flags::empty();
    let mut html_render = hoedown::renderer::html::Html::new(flags, 0);
    for arg in cmd_args().skip(1) {
        if is_file!(&arg) {
            if !arg.ends_with(".md") { continue; }

            println!("Render - {}", &arg);
            let html_path = std::path::Path::new(&arg).with_extension("html");

            if let Ok(file) = std::fs::File::open(&arg) {
                let mut html_file = std::fs::File::create(&html_path).unwrap();

                let file = BufReader::new(file);
                let file = hoedown::Markdown::read_from(file).extensions(md_ext);
                let render_result = html_render.render(&file);

                html_file.write_all(&render_result).unwrap();
                println!(">>>Result: {}", &html_path.to_str().unwrap_or(""));
            }
            else {
                println!(">>>{}: failed to open", &arg);
            }
            println!("");
        }
        else if let Ok(dir_content) = std::fs::read_dir(&arg) {
            println!("Render in directory - {}\n", &arg);
            for entry in dir_content.map(|elem| elem.unwrap())
                                    .filter(|elem| elem.file_type().map(|elem| elem.is_file()).unwrap_or(false))
                                    .map(|elem| elem.path())
                                    .filter(|path| path.extension().map(|ext| ext == "md").unwrap_or(false)) {

                println!("File: {}", entry.to_str().unwrap_or(""));
                let html_path = std::path::Path::new(&entry).with_extension("html");

                if let Ok(file) = std::fs::File::open(&entry) {
                    let mut html_file = std::fs::File::create(&html_path).unwrap();

                    let file = BufReader::new(file);
                    let file = hoedown::Markdown::read_from(file).extensions(md_ext);
                    let render_result = html_render.render(&file);

                    html_file.write_all(&render_result).unwrap();
                    println!(">>>Result: {}", &html_path.to_str().unwrap_or(""));
                }
                else {
                    println!(">>>{}: failed to open", entry.to_str().unwrap_or(""));
                }

                println!("");
            }
        }
        else {
            println!(">>>{}: cannot access\n", &arg);
            continue;
        }

    }
}
