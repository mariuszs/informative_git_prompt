
function  __informative_git_prompt

    set -l branch (git rev-parse --abbrev-ref HEAD ^/dev/null)
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
        if test -n $remote_name
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
            set rev_git (git rev-list --left-right $remote_ref...HEAD)

            for i in $rev_git
                if echo $i | grep '>' >/dev/null
                   set isAhead $isAhead ">"
                end
            end

            set ahead (count $isAhead)
            set behind (math (count $rev_git) - $ahead)

            if [ $ahead != "0" ]
                echo "ahead $ahead"
                set remote "$remote$symbol_ahead_of$ahead"
            end

            if [ $behind != "0" ]
                echo "behind $behind"
                set remote "$remote$symbol_behind$behind"
            end

        end
    end

    if test -z $remote 
        set remote '.'
    end

    set out $branch $remote $staged $conlicts $changed $untracked $clean

    echo $out

end
