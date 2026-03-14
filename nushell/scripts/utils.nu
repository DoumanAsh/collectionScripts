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
    } else if ( $env_export | path exists ) {
        cat $env_export
    } else {
        $env_export
    }

    $env_export | lines
                | str replace -r '^export *' ''
                | split column '=' name value
                | where { ('value' in $in) and ($in | select value | is-not-empty) }
                | where { $in.name != 'PATH' }
                | reduce -f {} {|it, acc| $acc | upsert $it.name $it.value | str trim -c '"' }
                | load-env
}
