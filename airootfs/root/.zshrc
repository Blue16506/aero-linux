# Aero Linux - Live environment zsh configuration

# Prompt
PROMPT='%F{cyan}%n@%m%f %F{blue}%~%f %# '

# Aliases
alias aero-install='sudo /usr/local/bin/aero-install'

# History
HISTSIZE=1000
SAVEHIST=1000

# Options
setopt AUTO_CD

# Welcome message
clear
printf "\033[1;36m"
printf "    █████╗ ███████╗██████╗  ██████╗ \n"
printf "   ██╔══██╗██╔════╝██╔══██╗██╔═══██╗\n"
printf "   ███████║█████╗  ██████╔╝██║   ██║\n"
printf "   ██╔══██║██╔══╝  ██╔══██╗██║   ██║\n"
printf "   ██║  ██║███████╗██║  ██║╚██████╔╝\n"
printf "   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ \n"
printf "\033[0m\n"
printf "  Welcome to Aero Linux Live!\n"
printf "\n"
printf "  Type 'aero-install' to start the installer.\n"
printf "\n"
