//! Magnet links downloader module
use std::process::Command;

#[inline(always)]
pub fn is_applicable<T: AsRef<str>>(text: T) -> bool {
    text.as_ref().starts_with("magnet:")
}

#[inline(always)]
pub fn handler<T: AsRef<str>>(magnet_uri: T) {
    println!("Run torrent client on uri: {}", magnet_uri.as_ref());
    Command::new("powershell").arg("-NoProfile")
                              .arg("-c")
                              .arg(format!("start {}", magnet_uri.as_ref()))
                              .status()
                              .unwrap_or_else(|error| panic!("Unable to run powershell. Reason: {}", error));
}
