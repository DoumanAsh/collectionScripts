export def rust_get_default_channel [] {
    if (which rustup | is-empty) {
        ""
    } else {
        let result = ( do { rustup default } | complete)
        if ($result.exit_code != 0) {
            ""
        } else {
            let default = ($result.stdout | split row -r '\s+' | get 0);
            $default
        }
    }
}

#export def rust_clean_repos [
#    folder?: string # Folder where to perform cleaning, recursively
#    --yes (-y) # Automatically confirm cleaning
#] {
#    let folder = (
#        if ($folder == null) {
#            pwd
#        } else {
#            $folder
#        }
#    )
#
#    print $"($folder): Entering..."
#}
