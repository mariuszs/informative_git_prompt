Informative GIT Prompt for Fish shell
=====================================

This prompt is a port of the [Informative git prompt for bash][1] which is based on [Informative git prompt for zsh][2].
Original idea is from blog post [A zsh prompt for Git users][3].

[1]: https://github.com/magicmonty/bash-git-prompt              "Informative git prompt for bash"
[2]: https://github.com/olivierverdier/zsh-git-prompt           "Informative git prompt for zsh"
[3]: http://sebastiancelis.com/2009/nov/16/zsh-prompt-git-users "A zsh prompt for Git users"

## Examples

The prompt may look like the following:

* ``(master↑3|✚1)``: on branch ``master``, ahead of remote by 3 commits, 1 file changed but not staged
* ``(status|●2)``: on branch ``status``, 2 files staged
* ``(master|✚7…)``: on branch ``master``, 7 files changed, some files untracked
* ``(master|✖2✚3)``: on branch ``master``, 2 conflicts, 3 files changed
* ``(experimental↓2↑3|✔)``: on branch ``experimental``; your branch has diverged by 3 commits, remote by 2 commits; the repository is otherwise clean
* ``(:70c2952|✔)``: not on any branch; parent commit has hash ``70c2952``; the repository is otherwise clean


![screen](https://raw.github.com/mariuszs/informative_git_prompt/master/shell.png)

##  Prompt Structure

By default, the general appearance of the prompt is:

    (<branch> <branch tracking>|<local status>)

The symbols are as follows:

- Local Status Symbols
  - ``✔``: repository clean
  - ``●n``: there are ``n`` staged files
  - ``✖n``: there are ``n`` unmerged files
  - ``✚n``: there are ``n`` changed but *unstaged* files
  - ``…n``: there are ``n`` untracked files
- Branch Tracking Symbols
  - ``↑n``: ahead of remote by ``n`` commits
  - ``↓n``: behind remote by ``n`` commits
  - ``↓m↑n``: branches diverged, other by ``m`` commits, yours by ``n`` commits
- Branch Symbol:<br />
  	When the branch name starts with a colon ``:``, it means it's actually a hash, not a branch (although it should be pretty clear, unless you name your branches like hashes :-)

## Install

1. Move the file ``informative_git_prompt.fish`` into ``~/.config/fish/``.
1. Source the file ``informative_git_prompt.fish`` from your ``~/.config/fish/config.fish`` config file.
1. Configure your prompt in``~/.config/fish/config.fish``. For this you have to define function ``fish_prompt``. Example function is inside
``example_config.fish`` - simply copy is enough.
1. Go in a git repository and test it!

**Enjoy!**

### Example configuration (config.fish)

    . informative_git_prompt.fish

    function fish_prompt --description 'Write out the prompt'

      set_color $fish_color_cwd
      echo -n (prompt_pwd)
      set_color normal

      __informative_git_prompt

      if not test $last_status -eq 0
      set_color $fish_color_error
      end

      echo -n ' $ '
      set_color normal

    end