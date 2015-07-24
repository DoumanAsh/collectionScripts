//! Wget module

use std;

#[inline(always)]
fn find_file_name(text: &String) -> Option<String> {
    let left: usize = text.rfind("-O \"").unwrap_or(0);
    let right: usize = text.rfind("\" -c").unwrap_or(0);

    if left == right { return None; }
    let left: usize = left + 4;
    Some(text[left..right].to_string())
}

#[inline(always)]
pub fn is_applicable(text: &String) -> Option<String> {
    if !text.starts_with("wget") { return None; }
    find_file_name(text)
}

pub fn handler(text: &String, file_name: String) {
    println!(">>>wget {}", &file_name);

    let cmd = format!("cd E:/Downloads; {}", text);
    if std::thread::Builder::new().name(file_name).spawn(move || {
        let output = std::process::Command::new("powershell").arg("-Command").arg(cmd).output().unwrap();
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
