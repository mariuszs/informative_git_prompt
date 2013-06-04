#
# Written by Mariusz Smykula <mariuszs at gmail.com>
#
# This is fish port of Informative git prompt for bash (https://github.com/magicmonty/bash-git-prompt)
#

set -gx __fish_prompt_git_prefix " ("
set -gx __fish_prompt_git_suffix ")"
set -gx __fish_prompt_git_separator "|"
set -gx __fish_prompt_git_ahead_of "↑"
set -gx __fish_prompt_git_behind  "↓"
set -gx __fish_prompt_git_prehash ":"
set -gx __fish_prompt_git_color_changed "blue"
set -gx __fish_prompt_git_color_clean "green"
set -gx __fish_prompt_git_color_conflicts "red"
set -gx __fish_prompt_git_color_staged "red"
set -gx __fish_prompt_git_color_branch "magenta"

function  __informative_git_prompt

    set -l reset_color (set_color $fish_color_normal)

    set -l color_branch (set_color -o $__fish_prompt_git_color_branch)
    set -l color_clean (set_color -o $__fish_prompt_git_color_clean)

    set -l color_staged (set_color $__fish_prompt_git_color_staged)
    set -l color_conflicts (set_color $__fish_prompt_git_color_conflicts)
    set -l color_changed (set_color $__fish_prompt_git_color_changed)

    set -l prompt_branch "$color_branch"
    set -l prompt_staged "$color_staged●"
    set -l prompt_conflicts "$color_conflicts✖"
    set -l prompt_changed "$color_changed✚"
    set -l prompt_remote " "
    set -l prompt_untracked "…"
    set -l prompt_clean "$color_clean✔"

    set -l branch (eval "git rev-parse --abbrev-ref HEAD" ^/dev/null)
    if test -z $branch
        return
    end

    set -l branch (git symbolic-ref -q HEAD | cut -c 12-)

    set -l changedFiles (git diff --name-status | cut -c 1-2)
    set -l stagedFiles (git diff --staged --name-status | cut -c 1-2)

    set -l changed (math (count $changedFiles) - (count (echo $changedFiles | grep "U")))
    set -l conflicts (count (echo $stagedFiles | grep "U"))
    set -l staged (math (count $stagedFiles) - $conflicts)
    set -l untracked (count (git ls-files --others --exclude-standard))

    if [ (math $changed + $conflicts + $staged + $untracked) = 0 ]
        set clean '0'
    else
        set clean '1'
    end

    if test -z $branch

        set hash (git rev-parse --short HEAD | cut -c 2-)
        set branch $__fish_prompt_git_prehash$hash

    end

    echo -n "$__fish_prompt_git_prefix$prompt_branch$branch$reset_color"

    set -l remote_name  (git config branch.$branch.remote)

    if test -n "$remote_name"
        set merge_name (git config branch.$branch.merge)
        set merge_name_short (echo $merge_name | cut -c 12-)
    else
        set remote_name "origin"
        set merge_name "refs/heads/$branch"
        set merge_name_short $branch
    end

    if [ $remote_name = '.' ]  # local
        set remote_ref $merge_name
    else
        set remote_ref "refs/remotes/$remote_name/$merge_name_short"
        set rev_git (eval "git rev-list --left-right $remote_ref...HEAD" ^/dev/null)

        if test $status = 0
            set rev_git (git rev-list --left-right $merge_name...HEAD)
        end

        for i in $rev_git
            if echo $i | grep '>' >/dev/null
               set isAhead $isAhead ">"
            end
        end

        set ahead (count $isAhead)
        set behind (math (count $rev_git) - $ahead)

        if [ $ahead != "0" ]
            set remote "$remote$__fish_prompt_git_ahead_of$ahead"
        end

        if [ $behind != "0" ]
            set remote "$remote$__fish_prompt_git_behind$behind"
        end

    end

    if set -q remote
        set STATUS "$STATUS$prompt_remote$remote$reset_color"
    end

    set STATUS "$STATUS$__fish_prompt_git_separator"

    if [ $staged != "0" ]
        set STATUS "$STATUS$prompt_staged$staged$reset_color"
    end

    if [ $conflicts != "0" ]
        set STATUS "$STATUS$prompt_conflicts$conflicts$reset_color"
    end

    if [ $changed != "0" ]
        set STATUS "$STATUS$prompt_changed$changed$reset_color"
    end

    if [ "$untracked" != "0" ]
        set STATUS "$STATUS$prompt_untracked$untracked$reset_color"
    end

    if [ "$clean" = "0" ]
        set STATUS "$STATUS$prompt_clean"
    end

    set STATUS "$STATUS$reset_color$__fish_prompt_git_suffix"

    echo -e -n "$STATUS"

    set_color normal

end