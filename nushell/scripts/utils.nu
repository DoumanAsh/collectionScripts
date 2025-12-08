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
            $path | prepend ($dests | where { ($in | path exists) and $in not-in $path })
        )
    }
}

###
#Accepts multine string in format of `(export )*NAME=VALUE` loading it into environment
###
export def --env load_env_from_env_export [env_export?: string] {
    let env_export = if ($env_export == null) {
        $in
    } else {
        $env_export
    }

    $env_export | default $in
                | lines
                | str replace -r '^export *' ''
                | split column '=' name value
                | where { $in.name != 'PATH' }
                | reduce -f {} {|it, acc| $acc | upsert $it.name $it.value | str trim -c '"' }
                | load-env
}
