# Aero Linux - zsh completion settings

# Completion
autoload -Uz compinit
compinit -d "${ZDOTDIR}/.zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${ZDOTDIR}/.zcompcache"

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Fzf integration
if command -v fzf &>/dev/null; then
    source /usr/share/fzf/completion.zsh 2>/dev/null || true
    source /usr/share/fzf/key-bindings.zsh 2>/dev/null || true
fi
