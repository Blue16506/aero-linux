# Aero Linux - zsh aliases

# Directory
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ls='eza --icons=always'
alias ll='eza -l --icons=always'
alias la='eza -la --icons=always'
alias lt='eza -T --icons=always'
alias tree='eza -T --icons=always'

# File operations
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'
alias mkdir='mkdir -p'

# System
alias update='sudo pacman -Syu'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || true'
alias pacman='sudo pacman'
alias unlock='sudo rm /var/lib/pacman/db.lck'
alias snap='sudo snapper'
alias snap-list='sudo snapper -c root list'

# Yay
alias yay='yay --editmenu'

# Editor
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Bat
alias cat='bat'

# Fzf
alias f='fzf'
alias ff='find . -type f | fzf'

# Git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'
alias gd='git diff'

# Network
alias ip='ip -color'
alias myip='curl -s ifconfig.me'

# Tools
alias top='btop'
alias du='dust'
alias ps='procs'
alias grep='rg'
alias find='fd'
alias r='source ~/.config/zsh/.zshrc'
