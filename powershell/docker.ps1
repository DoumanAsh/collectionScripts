function run_docker {
    Param (
        [string]$tag,
        [switch]$h,
        [switch]$help,
        [string]$mount = ${pwd}
    )

    if ($h -Or $help -Or [string]::IsNullOrEmpty($tag)) {
        echo "Usage: docker [-mount <folder>] <tag>"
        return
    }

    docker run --rm --network host --name rust_build -v ${mount}:/mount -it $tag
}
