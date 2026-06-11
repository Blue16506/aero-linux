# Aero Linux - zsh main configuration
# ZDOTDIR is set to ~/.config/zsh by /etc/zsh/zshenv

source ~/.config/zsh/plugins.zsh
source ~/.config/zsh/completion.zsh
source ~/.config/zsh/keybindings.zsh
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/theme.zsh

# History
HISTFILE="${ZDOTDIR}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# General options
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt MENU_COMPLETE
setopt CORRECT_ALL
