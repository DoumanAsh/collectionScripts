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

#[inline(always)]
pub fn handler(text: &String, file_name: String) {
    println!(">>>wget {}", &file_name);

    let cmd = format!("cd E:/Downloads; {}", text);
    if std::thread::Builder::new().name(file_name).spawn(move || {
        let status = std::process::Command::new("powershell").arg("-Command").arg(cmd).stdout(std::process::Stdio::null()).stderr(std::process::Stdio::null()).status().unwrap();
        if !status.success() {
            println!("[{}] Failed to wget", std::thread::current().name().unwrap_or("UNKNOWN"));
        }
        else {
            println!("[{}] Successfully downloaded", std::thread::current().name().unwrap_or("UNKNOWN"));
        }
    }).is_err() {
        println!("Failed to run new thread with wget");
    }
    return;
}
