##############################################################################################
#                                                                                            #
#                          This file is part of the global dotfiles.                         #
#                         Make host-specific changes in .zshrc.local!                        #
#  If that file does not exist, clone dotfiles_local and checkout the branch for this host.  #
#                                                                                            #
##############################################################################################

if [[ ! -v ZDOTDIR ]]; then
  export ZDOTDIR="$HOME"
fi

#zmodload zsh/zprof

# Helpers
_cmd_exists() {
  type -p "$1" >/dev/null
  return $?
}

_alias_to() {
  for a in $@[2,-1]; do
    if ! _cmd_exists "$a"; then
      alias "$a"="$1"
    fi
  done
}

# Homebrew/Linuxbrew - this is set up early for GPG/Antibody
test -d "$HOME/.linuxbrew" && export HOMEBREW_ROOT="$HOME/.linuxbrew"
test -d "/home/linuxbrew/.linuxbrew" && export HOMEBREW_ROOT="/home/linuxbrew/.linuxbrew"
test -d "/opt/homebrew" && export HOMEBREW_ROOT="/opt/homebrew"

if [[ -d "$HOMEBREW_ROOT" ]]; then
  export PATH="$HOMEBREW_ROOT/bin:$HOMEBREW_ROOT/sbin:$PATH"
  export MANPATH="$HOMEBREW_ROOT/share/man:$MANPATH"
  export INFOPATH="$HOMEBREW_ROOT/share/info:$INFOPATH"

  # GOROOT
  if [[ -d "$HOMEBREW_ROOT/opt/go/libexec/bin" ]]; then
    export PATH="$HOMEBREW_ROOT/opt/go/libexec/bin:$PATH"
  fi
fi

# Antibody (package management)
if [[ -d "$HOMEBREW_ROOT" ]] && [[ -f "$HOMEBREW_ROOT/opt/antidote/share/antidote/antidote.zsh" ]]; then
  source "$HOMEBREW_ROOT/opt/antidote/share/antidote/antidote.zsh"
  antidote load
else
  echo "!! Antidote not found from Homebrew; install it with: brew install antidote"
fi

# GPG2
export GPG_TTY=$(tty)
if _cmd_exists gpg2-agent; then
  GPG_AGENT="gpg2-agent"
  alias gpg="gpg2" # Sod you old distros
elif _cmd_exists gpg-agent; then
  GPG_AGENT="gpg-agent"
else
  echo "warn: unable to locate gpg(2)-agent -- is GPG installed?"
fi

HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt append_history auto_cd extended_glob share_history correct_all auto_list auto_menu always_to_end hist_ignore_space
unsetopt correct correct_all
bindkey -e

# nix-darwin
if [[ -d "/run/current-system/sw/bin" ]]; then
  export PATH="/run/current-system/sw/bin:${PATH}"
fi

# Arkade
if [[ -d "$HOME/.arkade/bin" ]]; then
  export PATH="${HOME}/.arkade/bin:${PATH}"
fi

# Krew for kubectl
if [[ -d "$HOME/.krew/bin" ]]; then
  export PATH="${HOME}/.krew/bin:${PATH}"
fi

# Cargo
if [[ -d "$HOME/.cargo/bin" ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# Rust src
if [[ -d "$HOME/src/rust" ]]; then
  export RUST_SRC_PATH="$HOME/src/rust/src"
fi

# Load Zsh completions
if [[ -d "$HOME/dotfiles/zsh_completions" ]]; then
  export fpath=($fpath "$HOME/dotfiles/zsh_completions")
fi

# Python pyenv
if _cmd_exists pyenv; then
  _evalcache pyenv init -
fi

# Ruby rbenv
if _cmd_exists rbenv; then
  _evalcache rbenv init - zsh
fi

# Sensible default env vars
if _cmd_exists nvim; then
  export EDITOR="$(which nvim)"
  alias nv=nvim
  alias vim=nvim
  alias vi=nvim
elif _cmd_exists vim; then
  export EDITOR="$(which vim)"
  alias vi=vim
fi
if _cmd_exists go; then
  export GOPATH="$HOME/go"
  export PATH="$GOPATH/bin:$PATH"
fi
if [[ -d "/snap/bin" ]]; then export PATH="/snap/bin:$PATH"; fi
if [[ -d "$HOME/bin" ]]; then export PATH="$HOME/bin:$PATH"; fi
if [[ -d "/Applications/Visual Studio Code - Insiders.app" ]]; then export PATH="/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin:$PATH"; fi
if [[ -d "/Applications/Visual Studio Code.app" ]]; then export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"; fi

## Clang/LLVM
if _cmd_exists clang; then
  export CC="clang"
  export CXX="clang++"
  export HOMEBREW_CC="clang"
  export HOMEBREW_CXX="clang++"
fi

# Virtualenv Wrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/dev/python

# Spark
if [ -d /usr/local/opt/apache-spark ]; then
  export SPARK_HOME="/usr/local/opt/apache-spark"
fi

# Pipx
if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Poetry
if [[ -d "$HOME/.poetry/bin" ]]; then
  export PATH="$HOME/.poetry/bin:$PATH"
fi

# Skip unnecessary bits for interactive shells
if [[ -o INTERACTIVE ]]; then

  # Setup completion
  autoload -Uz compinit
  setopt extendedglob local_options
  # Only compile compinit once per day
  for dump in ~/.zcompdump(N.mh+24); do
    compinit
  done
  compinit -C
  zmodload -i zsh/complist

  zstyle ':completion:*' menu select # select completions with arrow keys
  zstyle ':completion:*' group-name '' # group results by category
  zstyle ':completion:::::' completer _expand _complete _ignored _approximate # enable approximate matches for completion

  # Homebrew/Linuxbrew
  if _cmd_exists brew; then
    export HOMEBREW_VERBOSE="true"
  fi

  # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/tmp/zsh/.zshrc.
  # Initialization code that may require console input (password prompts, [y/n]
  # confirmations, etc.) must go above this block; everything else may go below.
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi

  # System banner (if present and populated)
  if [[ -s "$HOME/.banner" ]]; then
    RELEASE=$(lsb_release -ds 2>/dev/null || printf "unknown")
    KERNEL=$(cat /proc/version_signature 2>/dev/null || cat /proc/version 2>/dev/null || printf "unknown")
    cat "$HOME/.banner" | sed -e "s/@RELEASE@/$RELEASE/" -e "s/@KERNEL@/$KERNEL/"
  fi

  # GitHub CLI
  if _cmd_exists gh; then
    _evalcache gh completion -s zsh
    alias prc="gh pr create"
    alias prs="gh pr status"
    alias prv="gh pr view"
    alias prw="gh pr view --web"
    alias prsc="gh pr checks"
    alias prm="gh pr merge -d"
    function prd() {
      gh pr diff --patch $1 | delta
    }
    function ghclone() {
      local target="$HOME/ghdev/$1"
      [[ -d "$target" ]] || mkdir -p "$target"
      git clone "git@github.com:$1.git" "$target"
    }
  fi

  # bat, the better cat
  if _cmd_exists bat; then
    export BAT_THEME="TwoDark"
    alias cat=bat
  fi

  # thefuck
  if _cmd_exists thefuck; then
    _evalcache thefuck --alias
    _evalcache thefuck --alias arse
    _evalcache thefuck --alias shit
  fi

  # Aliases
  _alias_to kubectl k
  _alias_to kubectl kctl
  _alias_to kubens kns
  _alias_to kubectx kctx
  _alias_to toxiproxy-cli toxi

  _alias_to sudo _

  if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls="ls -h"
  else
    alias ls="ls --color=tty -h"
  fi

  # Filter out macOS, as that might be confused with the JDK apt tool
  if _cmd_exists apt && [[ "$OSTYPE" != "darwin"* ]]; then alias apt="sudo apt"; fi
  if _cmd_exists pacman; then alias pacman="sudo pacman"; fi
  if _cmd_exists zoxide; then _evalcache zoxide init zsh; fi
  if _cmd_exists eza; then
    alias ls="eza"
    alias la="eza -a"
    alias ll="eza -la"
  elif _cmd_exists exa; then
    echo "!! exa is unmaintained; switch to eza"
  fi

  # Git aliases
  if _cmd_exists git; then
    alias gs="git status"
    alias gd="git diff"
    alias gp="git pull"
    alias gpp="git pull --prune"
    alias gc="git commit"
    alias gr="git rebase"
    alias gri="git rebase -i"
    alias gm="git merge"
    alias gco="git checkout"

    gppm() {
      git checkout $(git symbolic-ref refs/remotes/origin/HEAD --short | cut -f 2 -d /) && git pull --prune
    }

    gpo() {
      git push -u origin $(git rev-parse --abbrev-ref HEAD)
    }

    # Oh shit, new branch - for when you start hacking on a merged branch by accident...
    osnb() {
      git stash && \
      gppm && \
      git checkout -b "$1" && \
      git stash pop
    }

    if _cmd_exists delta; then
      alias gdd="git diff --no-ext-diff | delta"
    fi
  fi

  if _cmd_exists uv; then
    eval "$(uv generate-shell-completion zsh)"
  fi

  # iTerm tools
  send_notification() {
    echo -n "\e]9;$1\007"
  }

  # Key bindings
  bindkey ";5C" forward-word
  bindkey ";5D" backward-word
  bindkey "^[[3~" delete-char
  bindkey "^[3;5~" delete-char

  # Selecta (see https://github.com/garybernhardt/selecta/blob/master/EXAMPLES.md)
  if _cmd_exists selecta; then
    # By default, ^S freezes terminal output and ^Q resumes it. Disable that so
    # that those keys can be used for other things.
    unsetopt flowcontrol
    # Run Selecta in the current working directory, appending the selected path, if
    # any, to the current command, followed by a space.
    function insert-selecta-path-in-command-line() {
        local selected_path
        # Print a newline or we'll clobber the old prompt.
        echo
        # Find the path; abort if the user doesn't select anything.
        selected_path=$(find * -type f | selecta) || return
        # Append the selection to the current command buffer.
        eval 'LBUFFER="$LBUFFER$selected_path "'
        # Redraw the prompt since Selecta has drawn several new lines of text.
        zle reset-prompt
    }
    # Create the zle widget
    zle -N insert-selecta-path-in-command-line
    # Bind the key to the newly created widget
    bindkey "^S" "insert-selecta-path-in-command-line"
  fi

  # Fuzzy Finder
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # To customize prompt, run `p10k configure` or edit ~/tmp/zsh/.p10k.zsh.
  [[ ! -f "$ZDOTDIR/.p10k.zsh" ]] || source "$ZDOTDIR/.p10k.zsh"

fi # End of Interactive block

# eval (http://superuser.com/a/230090)
# Invoke with 'zsh -is eval 'commandhere''
if [[ $1 == eval ]]
then
  "$@"
  set --
fi

# local profile
if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi

# Load asdf
[[ -d "$HOMEBREW_ROOT" && -f "$HOMEBREW_ROOT/opt/asdf/libexec/asdf.sh" ]] && source "$HOMEBREW_ROOT/opt/asdf/libexec/asdf.sh"
[[ -f "$HOME/.asdf/plugins/java/set-java-home.zsh" ]] && source "$HOME/.asdf/plugins/java/set-java-home.zsh"
[[ -f "$HOME/.asdf/plugins/golang/set-env.zsh" ]] && source "$HOME/.asdf/plugins/golang/set-env.zsh"
