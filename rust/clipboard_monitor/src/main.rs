extern crate clipboard_win;

use clipboard_win::{set_clipboard, ClipboardManager};
use std::process::Command;

fn handler_clip_text(text: &String) {
    if text.len() == 0 { return; }

    if text.starts_with("wget") {
        println!("wget download:");
        let status = Command::new("powershell").arg("-Command").arg(format!("cd E:/Downloads; {}", &text)).status().unwrap();
        if !status.success() {
            println!("Failed to run wget.");
        }
        return;
    }

    println!("Clipboard content: {}", &text);
    if !text.starts_with(' ') && !text.ends_with(' ') { return; }
    if set_clipboard(text.trim_matches(' ')).is_err() {
        println!("Failed to update clipboard");
    }
}

fn main() {
    println!("Clipboard monitor");
    ClipboardManager::new().ok_callback(handler_clip_text).run();
}
