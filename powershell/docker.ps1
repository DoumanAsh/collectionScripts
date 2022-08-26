function run_docker {
    Param (
        [string]$tag,
        [switch]$h,
        [switch]$help,
        [switch]$docker_sock,
        [string]$mount = ${pwd},
        [string]$name = $tag
    )

    if ($h -Or $help -Or [string]::IsNullOrEmpty($tag)) {
        echo "Usage: docker [-mount <folder>] [-docker_sock] <tag>"
        return
    }

    $name = $name -replace '/','_' -replace ':','_'

    $extra_args = ""
    if ($docker_sock) {
        $extra_args = "$extra_args -v //var/run/docker.sock:/var/run/docker.sock"
    }

    $cmd = "docker run --rm --network host --name $name -v ${mount}:/mount $extra_args -it $tag"
    echo "> $cmd"
    iex $cmd
}
