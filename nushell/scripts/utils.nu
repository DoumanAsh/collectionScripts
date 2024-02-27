export def --env env_add_path [...dests: string] {
    let path_key = (
        if ("PATH" in $env) {
            "PATH"
        } else {
            "Path"
        }
    )

    let path = $env | get $path_key
    load-env {
        $path_key: (
            $path | prepend ($dests | filter { ($in | path exists) and $in not-in $path })
        )
    }
}
