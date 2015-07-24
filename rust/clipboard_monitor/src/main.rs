extern crate clipboard_win;

use clipboard_win::{set_clipboard, ClipboardManager};
use std::process::Command;

#[inline(always)]
fn find_file_name(text: &String) -> String {
    let left: usize = text.rfind("-O \"").unwrap_or(0);
    let right: usize = text.rfind("\" -c").unwrap_or(0);

    if left == right { return "UNKNOWN".to_string(); }
    let left: usize = left + 4;
    text[left..right].to_string()
}

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

    if text.starts_with("wget") {
        let file_name = find_file_name(&text);
        println!(">>>wget {}", &file_name);

        let cmd = format!("cd E:/Downloads; {}", text);
        if std::thread::Builder::new().name(file_name).spawn(move || {
            let output = Command::new("powershell").arg("-Command").arg(cmd).output().unwrap();
            if !output.status.success() {
                println!("[{}] Failed to wget:\n{}", std::thread::current().name().unwrap_or("UNKNOWN"), String::from_utf8_lossy(&output.stdout));
            }
            else {
                println!("[{}] Successfully downloaded", std::thread::current().name().unwrap_or("UNKNOWN"));
            }
        }).is_err() {
            println!("Failed to run new thread with wget");
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
