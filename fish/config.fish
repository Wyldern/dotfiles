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

# Homebrew needs to override nix-darwin so do this first
_add_path /run/current-system/sw/bin

test -d "$HOME/.linuxbrew" && export HOMEBREW_ROOT="$HOME/.linuxbrew"
test -d "/home/linuxbrew/.linuxbrew" && export HOMEBREW_ROOT="/home/linuxbrew/.linuxbrew"
test -d "/opt/homebrew" && export HOMEBREW_ROOT="/opt/homebrew"

if [ -d "$HOMEBREW_ROOT" ]
    _add_path $HOMEBREW_ROOT/sbin $HOMEBREW_ROOT/bin
    _add_path_element MANPATH $HOMEBREW_ROOT/share/man
    _add_path_element INFOPATH $HOMEBREW_ROOT/share/info
    set -gx HOMEBREW_VERBOSE true

    # Common Fate Granted
    if [ -f $HOMEBREW_ROOT/bin/assume.fish ]
        alias assume="source $HOMEBREW_ROOT/bin/assume.fish"
    end
end

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

# uv
set -gx UV_PYTHON_PREFERENCE only-managed

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
            git clone git@github.com:{$repo}.git $path
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
        alias gd "git diff"
        alias gdd "git diff"
        alias gp "git pull"
        alias gpp "git pull --prune"
        alias gc "git commit"
        alias gr "git rebase"
        alias gri "git rebase -i"
        alias gm "git merge"
        alias gco "git checkout"

        function ga --wraps "git add"
            if [ (count $argv) -gt 0 ]
                git add $argv
            else
                git add .
            end
        end

        function gnb -a branch -d "New git branch from upstream HEAD"
            if [ -z $branch ]
                echo "missing parameter: branch"
                return -1
            end
            git fetch && git checkout -b $branch refs/remotes/origin/HEAD
        end

        function gppm -d "Checkout and pull main git branch"
            git checkout (git symbolic-ref refs/remotes/origin/HEAD --short | cut -f 2 -d /) && git pull --prune
        end

        function gpo -d "Push current git branch to origin and track"
            git push -u origin (git rev-parse --abbrev-ref HEAD)
        end

        # Oh shit, new branch - for when you start hacking on a merged branch by accident...
        function osnb -a branch -d "Stash changes, create new git branch from upstream HEAD, and re-apply stashed changes"
            git fetch  # Fetch first, since this is the most likely bit to fail
            and git stash
            and git checkout -b $branch refs/remotes/origin/HEAD
            and git stash pop
        end
    end

    if command -q code
        function c --wraps "code"
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
        switch (uname)
            case Darwin FreeBSD NetBSD DragonFly
                set -gx KUBECONFIG (mktemp -t shell_kubeconfig)
            case '*'
                set -gx KUBECONFIG (mktemp -t shell_kubeconfig.XXXXXX)
        end
        cp $ORIGINAL_KUBECONFIG $KUBECONFIG

        function _remove_shell_kubeconfig --on-event fish_exit
            rm $KUBECONFIG
        end
    end

    if command -q uv
        uv generate-shell-completion fish | source
    end

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
