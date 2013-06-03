# Colors
# Reset
set ResetColor (set_color normal)       # Text Reset

# Regular Colors
set Red (set_color red)                 # Red
set Yellow (set_color yellow);          # Yellow
set Blue (set_color blue)               # Blue
set WHITE (set_color white)

# Bold
set BGreen (set_color -o green)         # Green

# High Intensty
set IBlack (set_color -o black)         # Black

# Bold High Intensty
set Magenta (set_color -o purple)       # Purple

# Default values for the appearance of the prompt. Configure at will.
set GIT_PROMPT_PREFIX "("
set GIT_PROMPT_SUFFIX ")"
set GIT_PROMPT_SEPARATOR "|"
set GIT_PROMPT_BRANCH "$Magenta"
set GIT_PROMPT_STAGED "$Red●"
set GIT_PROMPT_CONFLICTS "$Red✖"
set GIT_PROMPT_CHANGED "$Blue✚"
set GIT_PROMPT_REMOTE " "
set GIT_PROMPT_UNTRACKED "…"
set GIT_PROMPT_CLEAN "$BGreen✔"


function  __informative_git_prompt

    set -l branch (eval "git rev-parse --abbrev-ref HEAD" ^/dev/null)
    if test -z $branch
        return
    end

    set branch (git symbolic-ref HEAD | cut -c 12-)

    set symbol_ahead_of "↑"
    set symbol_behind  "↓"
    set prehash ":"

    set changedFiles (git diff --name-status | cut -c 1-2)

    set stagedFiles (git diff --staged --name-status | cut -c 1-2)

    set changed (math (count $changedFiles) - (count (echo $changedFiles | grep "U")))
    set conflicts (count (echo $stagedFiles | grep "U"))
    set staged (math (count $stagedFiles) - $conflicts)
    set untracked (count (git ls-files --others --exclude-standard))

    set nb_changed2 (count (echo $staged | grep "M"))

    if [ (math $changed + $conflicts + $staged + $untracked) = 0 ]
        set clean '0'
    else
        set clean '1'
    end

    if test -z $branch

        set hash (git rev-parse --short HEAD | cut -c 2-)
        set branch $prehash$hash

    else

        set remote_name  (git config branch.$branch.remote)

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
                set remote "$remote$symbol_ahead_of$ahead"
            end

            if [ $behind != "0" ]
                set remote "$remote$symbol_behind$behind"
            end

        end
    end

    if test -n "$branch"
        set STATUS " $GIT_PROMPT_PREFIX$GIT_PROMPT_BRANCH$branch$ResetColor"

        if set -q remote
            set STATUS "$STATUS$GIT_PROMPT_REMOTE$remote$ResetColor"
        end

        set STATUS "$STATUS$GIT_PROMPT_SEPARATOR"

        if [ $staged != "0" ]
            set STATUS "$STATUS$GIT_PROMPT_STAGED$staged$ResetColor"
        end

        if [ $conflicts != "0" ]
            set STATUS "$STATUS$GIT_PROMPT_CONFLICTS$conflicts$ResetColor"
        end

        if [ $changed != "0" ]
            set STATUS "$STATUS$GIT_PROMPT_CHANGED$changed$ResetColor"
        end

        if [ "$untracked" != "0" ]
            set STATUS "$STATUS$GIT_PROMPT_UNTRACKED$untracked$ResetColor"
        end

        if [ "$clean" = "0" ]
            set STATUS "$STATUS$GIT_PROMPT_CLEAN"
        end

        set STATUS "$STATUS$ResetColor$GIT_PROMPT_SUFFIX"

        echo -e -n "$STATUS"
        
        set_color normal
    end

end
