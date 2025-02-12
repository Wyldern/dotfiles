function _add_path_element --argument-names var path
    if not contains $$var $path
        set -gxp $var $path
    end
end

function _add_path
    for path in $argv
        if [ -d $path ]
            _add_path_element PATH $path
        end
    end
end

function _source_exists --argument-names file
    if [ -f $file ]
        source $file
    end
end

function _alias_to --argument-names cmd alias
    if command -q $cmd
        alias $alias (command -v $cmd)
    end
end

test -d "$HOME/.linuxbrew" && export HOMEBREW_ROOT="$HOME/.linuxbrew"
test -d "/home/linuxbrew/.linuxbrew" && export HOMEBREW_ROOT="/home/linuxbrew/.linuxbrew"
test -d "/opt/homebrew" && export HOMEBREW_ROOT="/opt/homebrew"

if [ -d "$HOMEBREW_ROOT" ]
    _add_path $HOMEBREW_ROOT/sbin $HOMEBREW_ROOT/bin
    _add_path_element MANPATH $HOMEBREW_ROOT/share/man
    _add_path_element INFOPATH $HOMEBREW_ROOT/share/info
    set -gx HOMEBREW_VERBOSE true
end

_add_path /run/current-system/sw/bin
_add_path $HOME/go/bin
_add_path $HOME/.local/bin
_add_path $HOME/.poetry/bin
_add_path $HOME/.arkade/bin
_add_path $HOME/.krew/bin
_add_path $HOME/.cargo/bin
_add_path "/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin"
_add_path "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
_add_path_element RUST_SRC_PATH $HOME/src/rust

# Use (n)vim
if command -q nvim
    set -gx EDITOR (command -v nvim)
    alias nv nvim
    alias vim nvim
    alias vi nvim
else if command -q vim
    set -gx EDITOR (command -v vim)
    alias vi vim
end

# asdf
_source_exists $HOMEBREW_ROOT/opt/asdf/libexec/asdf.fish
_source_exists $HOME/.asdf/plugins/java/set-java-home.fish
_source_exists $HOME/.asdf/plugins/golang/set-env.fish
set -gx ASDF_GOLANG_MOD_VERSION_ENABLED true

_source_exists ~/.local.fish

if status is-interactive
    # Commands to run in interactive sessions can go here

    _alias_to kubectl k
    _alias_to kubens kns
    _alias_to kubectx kctx
    _alias_to toxiproxy-cli toxi

    # We treat sudo's _ alias a bit different since _ is a reserved language keyword
    abbr -a _ --position command sudo

    if command -q gh
        alias prc "gh pr create"
        alias prs "gh pr status"
        alias prv "gh pr view"
        alias prw "gh pr view --web"
        alias prsc "gh pr checks"
        alias prm "gh pr merge -d"

        function ghclone --argument-names repo
            set -f path $HOME/ghdev/$repo
            [ -d $path ] || mkdir -p $path
            git clone git@github.com:{$path}.git $repo
        end

        if gh extension list | grep -q "gh copilot"
            alias ghcs "gh copilot suggest --hostname github.com"
            alias ghce "gh copilot explain --hostname github.com"
        end
    end

    if command -q bat
        set -x BAT_THEME TwoDark
        alias cat bat
    end

    if command -q eza
        alias ls eza
        alias la "eza -a"
        alias ll "eza -la"
    end

    if command -q git
        alias gs "git status"
        alias ga "git add"
        alias gd "git diff"
        alias gdd "git diff"
        alias gp "git pull"
        alias gpp "git pull --prune"
        alias gc "git commit"
        alias gr "git rebase"
        alias gri "git rebase -i"
        alias gm "git merge"
        alias gco "git checkout"

        function gppm
            git checkout (git symbolic-ref refs/remotes/origin/HEAD --short | cut -f 2 -d /) && git pull --prune
        end

        function gpo
            git push -u origin (git rev-parse --abbrev-ref HEAD)
        end

        # Oh shit, new branch - for when you start hacking on a merged branch by accident...
        function osnb --argument-names branch
            git stash && \
            gppm && \
            git checkout -b $branch && \
            git stash pop
        end
    end

    if command -q code
        function c
            if [ (count $argv) -gt 0 ]
                code $argv
            else
                code .
            end
        end
    end

    set -q KUBECONFIG || set -gx KUBECONFIG $HOME/.kube/config
    if not string match -q -r '^/(tmp|var)/' $KUBECONFIG && test -f $KUBECONFIG
        set -gx ORIGINAL_KUBECONFIG $KUBECONFIG
        set -gx KUBECONFIG (mktemp -t shell_kubeconfig)
        cp $ORIGINAL_KUBECONFIG $KUBECONFIG

        function _remove_shell_kubeconfig --on-event fish_exit
            rm $KUBECONFIG
        end
    end

    if command -q uv
        uv generate-shell-completion fish | source
    end

    # Set up Tide prompt
    # Note the `newline character` has to be last - that sets up the two-line prompt with prompt arrow
    set -g tide_left_prompt_items context pwd git jobs status newline character
    set -g tide_right_prompt_items cmd_duration kubectl aws terraform go java node python ruby rustc nix_shell
    set -g tide_git_truncation_length 100

    if command -q atuin
        atuin init fish --disable-up-arrow | source
    else
        echo "!! atuin not found"
    end

    if command -q zoxide
        zoxide init fish | source
    else
        echo "!! zoxide not found"
    end
end
