# repo/dotfiles/.zshrc — minimal Oh-My-Zsh + plugins + Powerlevel10k

# point to your Oh-My-Zsh install
export TERM=xterm-256color
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# the only plugins you need
# plugins=(git fzf z)
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf)

# load Oh-My-Zsh (core, theme, plugin system)
source "$ZSH/oh-my-zsh.sh"

# load your one-and-done p10k config
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"