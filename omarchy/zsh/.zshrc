# zsh init for Omarchy.
# Ported from the old Arch setup (dotfiles root .zshrc): history, completion,
# zinit plugins (syntax-highlighting = red/green commands, autosuggestions,
# fzf-tab), oh-my-posh prompt, aliases.

# HISTORY
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# KEYBIND
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# AUTOCOMPLETE
autoload -Uz compinit
if [[ -n "$ZSH_COMPDUMP" ]]; then
  compinit -C
else
  compinit
fi

# COMPLETION STYLING
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


# PLUGINS
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

zinit cdreplay -q

# OH MY POSH (theme: ~/.config/ohmyposh/zen.toml)
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

# ALIASES
alias ls='ls --color'
alias vim='nvim'
alias c='clear'

alias cat='bat'

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch'
alias gi='git init'
alias gcl='git clone'

# paths
export PATH=$HOME/go/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
