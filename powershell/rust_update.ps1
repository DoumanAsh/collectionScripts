# Script requires 7z
# It should be placed in directory with Rust

$work_directory = $(Split-Path -parent $PSCommandPath)

cd $work_directory

$rust_dist_link = "https://static.rust-lang.org/dist/"

$channel = "channel-rust-stable"

$version = iex ".\bin\rustc.exe --version"
$version = $version.split()[1].split(".")
$version = [System.Tuple]::Create($version[0], $version[1], $version[2])

echo "Current Rust version: $version"

$latest_version = Invoke-WebRequest "$rust_dist_link$channel"
$latest_version = $latest_version.ToString().split('-')[1].split('.')
$latest_version = [System.Tuple]::Create($latest_version[0], $latest_version[1], $latest_version[2])

echo "Latest Rust version: $latest_version"

if ($latest_version -gt $version) {
    echo ">>>Update Rust version:"
    $rust_name = ("rust-{0}.{1}.{2}-x86_64-pc-windows-gnu" -f $latest_version.Item1,$latest_version.Item2,$latest_version.Item3)
    $rust_link = "https://static.rust-lang.org/dist/$rust_name.tar.gz"
    Invoke-WebRequest $rust_link -O "update.tar.gz"
    iex "7z x -y update.tar.gz"
    mkdir temp
    iex "7z x -y update.tar"
    echo ""
    echo "Unpacked, installing..."
    Remove-Item bin  -Force -Recurse
    Remove-Item lib  -Force -Recurse
    Remove-Item share  -Force -Recurse
    $list_to_copy = dir $rust_name -Directory | Dir -Directory | Select-Object FullName
    ForEach ($path In $list_to_copy) {
        Copy-Item $path.FullName . -Force -Recurse
    }

    Remove-Item $rust_name -Force -Recurse
    Remove-Item "update.*" -Force -Recurse

    echo ""
    echo "Rust is updated!"
}
