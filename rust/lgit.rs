///Lazy git tool
use std::env::args as cmd_args;
use std::process::Command;

///Executes git command with arguments
macro_rules! exec_git_cmd {
    ($args:expr) => {
        Command::new("git").args($args).status().unwrap();
    }
}

#[inline(always)]
fn usage() {
    println!("lgit [option]\n");
    println!("options:");
    println!("  amend [edit] - amend all changes into last commit");
    println!("  add - add all changes");
    println!("  clean - undo all changes");
    println!("  push [force] - push current branch");
    println!("  fetch - get updates from upstream\n");
}

///Amend changes
fn git_amend(args: &[String]) {
    git_add();
    if args.len() != 0 && args[0] == "edit" { exec_git_cmd!(&["commit", "--amend"]); }
    else { exec_git_cmd!(&["commit", "--amend", "--no-edit"]); }
}

///Fetch changes from upstream
fn git_fetch() {
    exec_git_cmd!(&["checkout", "master"]);
    exec_git_cmd!(&["fetch", "upstream"]);
    exec_git_cmd!(&["merge", "upstream/master"]);
}

///Push the current branch
fn git_push(args: &[String]) {
    if args.len() != 0 && args[0] =="force" { exec_git_cmd!(&["push", "--force", "origin", "HEAD"]); }
    else { exec_git_cmd!(&["push", "origin", "HEAD"]); }
}

///Add all changes
fn git_add() {
    exec_git_cmd!(&["add", "--all"]);
}

///Undo all changes
fn git_clean() {
    exec_git_cmd!(&["checkout", "-f"]);
    exec_git_cmd!(&["clean", "-fdq"]);
}

///Unexpected argument handler
fn unexpected(arg: &str) {
    println!("Unexpected argument: {}", arg);
    usage();
}

fn main() {
    let args: Vec<String> = cmd_args().collect();
    //exclude file name
    let s_args = &args[1..];
    let is_repo = Command::new("git").arg("rev-parse").arg("-q").output().unwrap();

    if is_repo.status.code().unwrap() != 0 {
        println!("Not a git repository");
        return;
    }
    else if s_args.len() == 0 {
        usage();
        return;
    }

    match s_args[0].as_ref() {
        "amend" => git_amend(&args[2..]),
        "fetch" => git_fetch(),
        "push"  => git_push(&args[2..]),
        "add"   => git_add(),
        "clean" => git_clean(),
        _       => unexpected(&s_args[0]),
    }
}
