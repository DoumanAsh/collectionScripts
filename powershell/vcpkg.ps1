function vcpkg_upgrade() {
    if ((Get-Command "vcpkg.exe" -ErrorAction SilentlyContinue) -eq $null) {
        Write-Host "VCPKG is not in PATH"
    }

    $full_path = Get-Command "vcpkg.exe" | Select-Object -ExpandProperty Definition
    $vcpkg_dir = Split-Path "$full_path"

    $old_pwd = Get-Location | select -ExpandProperty Path

    Set-Location $vcpkg_dir

    $GIT_OUT=git pull

    if ($GIT_OUT -Match "up to date") {
        echo "vcpkg is up to date"
    } else  {
        .\bootstrap-vcpkg.bat -disableMetrics -win64
    }

    Set-Location $old_pwd
}
