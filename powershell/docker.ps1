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

    $name = $tag.replace('/', "_")

    $cmd = "docker run --rm --network host --name $name -v ${mount}:/mount -it $tag"
    echo "> $cmd"
    iex $cmd
}
