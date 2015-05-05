///Lazy git tool
use std::env::args as cmd_args;
use std::process::{Command, Stdio};

///Executes git command with arguments
///Building sequence of arguments like .arg(@arg)
macro_rules! exec_git_cmd {
    (all_fd=>$fd:expr, $($arg:expr),*) => { Command::new("git")$(.arg($arg))*.stdout($fd).stderr($fd).status().unwrap(); };
    (stdout=>$stdout:expr, stderr=>$stderr:expr, $($arg:expr),*) => { Command::new("git")$(.arg($arg))*.stdout($stdout).stderr($stderr).status().unwrap(); };
    (stdout=>$stdout:expr, $($arg:expr),*) => { Command::new("git")$(.arg($arg))*.stdout($stdout).status().unwrap(); };
    (stderr=>$stderr:expr, $($arg:expr),*) => { Command::new("git")$(.arg($arg))*.stderr($stderr).status().unwrap(); };
    ($($arg:expr),*) => { Command::new("git")$(.arg($arg))*.status().unwrap(); };
}

///Print with prefix >>>
macro_rules! trace {
    ($($arg:expr),*) => { println!(">>>{}", [$(format!("{}", $arg),)*].connect(" ")); }
}

#[inline(always)]
fn usage() {
    println!("lgit [option]\n");
    println!("options:");
    println!("  amend [edit] - amend all changes into last commit");
    println!("  add - add all changes");
    println!("  clean - undo all changes");
    println!("  push [force] - push current branch");
    println!("  commit [message] - commit with message");
    println!("  fetch - get updates from upstream\n");
}

///Amend changes
fn git_amend(args: &[String]) {
    git_add();
    if args.len() != 0 && args[0] == "edit" { exec_git_cmd!("commit", "--amend"); }
    else { exec_git_cmd!("commit", "--amend", "--no-edit"); }
}

///Fetch changes from upstream
fn git_fetch() {
    exec_git_cmd!("checkout", "master");
    exec_git_cmd!("fetch", "upstream");
    exec_git_cmd!("merge", "upstream/master");
}

///Push the current branch
fn git_push(args: &[String]) {
    if args.len() != 0 && args[0] =="force" { exec_git_cmd!("push", "--force", "origin", "HEAD"); }
    else { exec_git_cmd!("push", "origin", "HEAD"); }
}

///Add all changes
fn git_add() {
    exec_git_cmd!("add", "--all");
}

///Undo all changes
fn git_clean() {
    exec_git_cmd!("checkout", "-f");
    exec_git_cmd!("clean", "-fdq");
}

///Commit with message
fn git_commit(args: &[String]) {
    if args.len() == 0 {
        trace!("Empty commit message");
    }
    else {
        exec_git_cmd!("commit", "-m", args.connect(" "));
    }
}

///Unexpected argument handler
fn unexpected(arg: &str) {
    trace!("Unexpected argument:", arg);
    usage();
}

fn main() {
    let args: Vec<String> = cmd_args().collect();
    //To check if git repo present
    let is_repo = exec_git_cmd!(stderr=>Stdio::null(), "rev-parse", "-q");

    if !is_repo.success() {
        trace!("Not a git repository");
        return;
    }
    else if args.len() == 1 {
        usage();
        return;
    }

    match args[1].as_ref() {
        "amend"  => git_amend(&args[2..]),
        "fetch"  => git_fetch(),
        "push"   => git_push(&args[2..]),
        "add"    => git_add(),
        "clean"  => git_clean(),
        "commit" => git_commit(&args[2..]),
        _        => unexpected(&args[1]),
    }
}
