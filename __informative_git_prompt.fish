#
# Written by Mariusz Smykula <mariuszs at gmail.com>
#
# This is fish port of Informative git prompt for bash (https://github.com/magicmonty/bash-git-prompt)
#

set -g __fish_prompt_git_prefix " ("
set -g __fish_prompt_git_suffix ")"
set -g __fish_prompt_git_separator "|"
set -g __fish_prompt_git_ahead_of "↑"
set -g __fish_prompt_git_behind  "↓"
set -g __fish_prompt_git_prehash ":"
set -g __fish_prompt_git_color_changed "blue"
set -g __fish_prompt_git_color_clean "green"
set -g __fish_prompt_git_color_conflicts "red"

set -g __fish_prompt_git_prompt_staged (set_color red)"●"
set -g __fish_prompt_git_prompt_conflicts (set_color red)"✖"
set -g __fish_prompt_git_prompt_changed (set_color blue)"✚"

set -g __fish_prompt_git_prompt_branch (set_color -o magenta)
set -g __fish_prompt_git_prompt_remote " "
set -g __fish_prompt_git_prompt_clean (set_color -o green)"✔"
set -g __fish_prompt_git_prompt_untracked "…"

function  __informative_git_prompt

    set -l reset_color (set_color $fish_color_normal)

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

    echo -n "$__fish_prompt_git_prefix$__fish_prompt_git_prompt_branch$branch$reset_color"

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
        set STATUS "$STATUS$__fish_prompt_git_prompt_remote$remote$reset_color"
    end

    set STATUS "$STATUS$__fish_prompt_git_separator"

    if [ $staged != "0" ]
        set STATUS "$STATUS$__fish_prompt_git_prompt_staged$staged$reset_color"
    end

    if [ $conflicts != "0" ]
        set STATUS "$STATUS$__fish_prompt_git_prompt_conflicts$conflicts$reset_color"
    end

    if [ $changed != "0" ]
        set STATUS "$STATUS$__fish_prompt_git_prompt_changed$changed$reset_color"
    end

    if [ "$untracked" != "0" ]
        set STATUS "$STATUS$__fish_prompt_git_prompt_untracked$untracked$reset_color"
    end

    if [ "$clean" = "0" ]
        set STATUS "$STATUS$__fish_prompt_git_prompt_clean"
    end

    set STATUS "$STATUS$reset_color$__fish_prompt_git_suffix"

    echo -e -n "$STATUS"

    set_color normal

end