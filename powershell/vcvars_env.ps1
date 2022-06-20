# Setups VC environment from bat.
function set_vc_from_bat($arch) {
    $vc_env = "vcvars$arch.bat"
    echo "Load MSVC environment $vc_env"
    if (Get-Command $vc_env -errorAction SilentlyContinue)
    {
        ## Store the output of cmd.exe. We also ask cmd.exe to output
        ## the environment table after the batch file completes
        ## Go through the environment variables in the temp file.
        ## For each of them, set the variable in our local environment.
        cmd /Q /c "$vc_env && set" 2>&1 | Foreach-Object {
            if ($_ -match "^(.*?)=(.*)$") {
                Set-Content "env:\$($matches[1])" $matches[2]
            }
        }

        echo "Successfully finished"
    }
    else {
        echo "Cannot find vcvars.bat for your arch '$arch'"
    }
}

# Setups environment using vswhere
# Check VsDevCmd.bat -? for available architectures
function set_vc($arch) {
    echo "Loading MSVC environment $arch..."

    if (Get-Command vswhere -ErrorAction SilentlyContinue) {
        $vswhere_path = Get-Command vswhere | Select-Object -ExpandProperty Definition
    } elseif (Test-Path("${Env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe")) {
        $vswhere_path = "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    } elseif (Test-Path("${Env:ProgramFiles}\Microsoft Visual Studio\Installer\vswhere.exe")) {
        $vswhere_path = "${Env:ProgramFiles}\Microsoft Visual Studio\Installer\vswhere.exe"
    } else {
        echo "vswhere.exe is not available in PATH. Cannot load"
        return
    }

    echo "Using vswhere: $vswhere_path"

    $installPath = (& "$vswhere_path" -products * -latest -property installationpath)
    echo "Found msvc installation: $installPath"

    Import-Module (Join-Path $installPath "Common7\Tools\Microsoft.VisualStudio.DevShell.dll")
    $null = Enter-VsDevShell -SkipAutomaticLocation -VsInstallPath $installPath -Arch $arch -HostArch $arch
}
