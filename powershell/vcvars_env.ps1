# Setups VC environment from bat.
# It runs environment in cmd and extract all variables into  temp file.
# which then is used to source environment.
function set_vc($arch) {
    $vc_env = "vcvars$arch.bat"
    if (Get-Command $vc_env -errorAction SilentlyContinue)
    {
        $tempFile = [IO.Path]::GetTempFileName()

        ## Store the output of cmd.exe. We also ask cmd.exe to output
        ## the environment table after the batch file completes
        cmd /Q /c " $vc_env  && set > $tempFile " | out-null

        ## Go through the environment variables in the temp file.
        ## For each of them, set the variable in our local environment.
        Get-Content $tempFile | Foreach-Object {
            if($_ -match "^(.*?)=(.*)$")
            {
                Set-Content "env:\$($matches[1])" $matches[2]
            }
        }

        Remove-Item $tempFile
    }
    else {
        echo "Cannot find vcvars.bat for your arch '$arch'"
    }
}
