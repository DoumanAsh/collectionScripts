$ESC = [char]27

# Simple ps prompt with git status
function prompt {
    $current_location = $(Get-Location | select -ExpandProperty Path | % {$_.replace("$env:HOMEDRIVE$env:HOMEPATH", "~")})

    $git_branch = $(git rev-parse --abbrev-ref HEAD 2> $null)
    if ([string]::IsNullOrEmpty($git_branch)) {
        "$ESC[33m$($current_location)$ESC[0m$("`n$(Get-Date -Format 'HH:mm') $" * ($nestedPromptLevel + 1)) "
    } else {
        $git_dirt = $(git diff-index --name-only --ignore-submodules HEAD --)

        if ([string]::IsNullOrEmpty($git_dirt)) {
            $status_color = "$ESC[32m"
        } else {
            $status_color = "$ESC[31m"
        }

        $commit_diff_line = ""

        $git_commits_to_push = $(git rev-list head...origin/$git_branch  --left-right --ignore-submodules --count 2> $null)

        if ([string]::IsNullOrEmpty($git_commits_to_push)) {
        } else {
            $git_commits_ahead,$git_commits_behind = $git_commits_to_push.Split('')

            if ([int]$git_commits_ahead -gt 0) {
                $commit_diff_line = " ^ $git_commits_ahead"
            }

            if ([int]$git_commits_behind -gt 0) {
                if ([string]::IsNullOrEmpty($commit_diff_line)) {
                    $commit_diff_line = " ^ -$git_commits_behind"
                } else {
                    $commit_diff_line = "$commit_diff_line -$git_commits_behind"
                }
            }
        }

        "$ESC[33m$($current_location)$ESC[0m [$status_color$git_branch$commit_diff_line$ESC[0m]$("`n$(Get-Date -Format 'HH:mm') $" * ($nestedPromptLevel + 1)) "
    }
}
