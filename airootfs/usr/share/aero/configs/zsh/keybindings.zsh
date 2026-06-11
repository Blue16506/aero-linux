# Aero Linux - zsh keybindings

# Vi mode
bindkey -v

# Reduce ESC delay
export KEYTIMEOUT=1

# Use vim-style navigation in menu completion
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Ctrl+arrows for word navigation
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Home / End
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Delete
bindkey '^[[3~' delete-char

# History search with arrows
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

# Ctrl+R for history search
bindkey '^R' history-incremental-search-backward
