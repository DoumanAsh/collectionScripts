extern crate clipboard_win;

use clipboard_win::{set_clipboard, ClipboardManager};
use std::process::Command;

///Trimm all lines in string.
///Return None if string is not changed.
fn trim_lines(text: &String) -> Option<String> {
let orig_len = text.len();
let last_char = text.chars().last().unwrap();
let mut text = text.lines().fold(String::new(), |acc, line| acc + line.trim() + "\n");

if last_char != '\n' {
text.pop();
}

if orig_len == text.len() { return None; }
Some(text)
}

fn handler_clip_text(text: &String) {
if text.len() == 0 { return; }

if text.starts_with("wget") {
println!("wget download:");
let status = Command::new("powershell").arg("-Command").arg(format!("cd D:/Downloads; {}", &text)).status().unwrap();
if !status.success() {
println!("Failed to run wget.");
}
return;
}

println!("Clipboard content:\n{}", &text);
if let Some(trim_text) = trim_lines(&text) {
if set_clipboard(&trim_text).is_err() {
println!("Failed to update clipboard");
}
}
}

fn main() {
println!("Clipboard monitor");
ClipboardManager::new().ok_callback(handler_clip_text).run();
}
