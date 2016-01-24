//! Clipboard monitor
//!
//! Auto-download with valid wget command(for example produced by means of cliget).
//! Or just print and trim clipboard content.

extern crate clipboard_win;

use clipboard_win::{set_clipboard};

pub mod wget;
pub mod magnet;
pub mod manager;

///Trimm all lines in string.
///Return None if string is not changed.
fn trim_lines(text: &String) -> Option<String> {
    let orig_len = text.len();
    let last_char = text.chars().last().unwrap();
    let mut text = text.lines().fold(String::new(), |acc, line| acc + line.trim_right() + "\n");

    if last_char != '\n' {
        text.pop();
    }

    if orig_len == text.len() { return None; }
    Some(text)
}

fn handler_clip_text(text: &String) {
    if text.len() == 0 { return; }

    if let Some(file_name) = wget::is_applicable(&text) {
        wget::handler(text, file_name);
        return;
    }
    else if magnet::is_applicable(&text) {
        magnet::handler(text);
        return;
    }

    //Default:
    println!("Clipboard content:\n{}", &text);
    if let Some(trim_text) = trim_lines(&text) {
        if set_clipboard(&trim_text).is_err() {
            println!("Failed to update clipboard");
        }
    }
}

fn main() {
    println!("###########################");
    println!("#    Clipboard monitor    #");
    println!("###########################");
    manager::ClipboardManager::new().ok_callback(handler_clip_text).run();
}
