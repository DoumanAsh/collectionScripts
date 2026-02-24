export def git_prompt [] {
    # Perform tilde substitution on dir
    # To determine if the prefix of the path matches the home dir, we split the current path into
    # segments, and compare those with the segments of the home dir. In cases where the current dir
    # is a parent of the home dir (e.g. `/home`, homedir is `/home/user`), this comparison will
    # also evaluate to true. Inside the condition, we attempt to str replace `$nu.home-dir` with `~`.
    # Inside the condition, either:
    # 1. The home prefix will be replaced
    # 2. The current dir is a parent of the home dir, so it will be uneffected by the str replace
    let dir = (
        if ($env.PWD | path split | zip ($nu.home-dir | path split) | all { $in.0 == $in.1 }) {
            ($env.PWD | str replace $nu.home-dir "~")
        } else {
            $env.PWD
        }
    )

    # Prepare git prompt
    mut git_prompt = "";
    let git_branch = (do { git rev-parse --abbrev-ref HEAD } | complete | $in.stdout | str trim)
    if (($git_branch | str length) != 0) {
        let git_dirty = (do { git diff-index --name-only --ignore-submodules HEAD -- } | complete | $in.stdout | str trim)
        let git_color = (
            if (($git_dirty | str length) == 0) {
                ansi green
            } else {
                ansi red
            }
        )

        let diff_status = do { git rev-list $"HEAD...origin/($git_branch)"  --left-right --ignore-submodules --count } | complete
        let commits_to_push = (
            if ($diff_status.exit_code == 0) {
                $diff_status.stdout | str trim | split row --regex '\s+'
            } else {
                ["0", "0"]
            }
        )
        let commits_ahead = $commits_to_push | get 0 | into int
        let commits_behind = $commits_to_push | get 1 | into int

        let git_diff = (
            if ($commits_ahead != 0 and $commits_behind != 0) {
                $" ^ ($commits_ahead) -($commits_behind)"
            } else if ($commits_ahead != 0) {
                $" ^ ($commits_ahead)"
            } else if ($commits_behind != 0) {
                $" -($commits_behind)"
            } else {
            ""
            }
        )

        $git_prompt = $" [($git_color)($git_branch)($git_diff)(ansi reset)]"
    }

    $"(ansi yellow)($dir)(ansi reset)($git_prompt)\n(date now | format date '%H:%M') "
}
