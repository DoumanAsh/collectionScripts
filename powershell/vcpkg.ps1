function vcpkg_upgrade() {
    if ((Get-Command "vcpkg.exe" -ErrorAction SilentlyContinue) -eq $null) {
        Write-Host "VCPKG is not in PATH"
    }

    $full_path = Get-Command "vcpkg.exe" | Select-Object -ExpandProperty Definition
    $vcpkg_dir = Split-Path "$full_path"

    $old_pwd = Get-Location | select -ExpandProperty Path

    Set-Location $vcpkg_dir

    git pull
    .\bootstrap-vcpkg.bat -disableMetrics -win64

    Set-Location $old_pwd
}
