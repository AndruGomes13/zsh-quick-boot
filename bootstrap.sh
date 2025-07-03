#!/usr/bin/env bash
set -euo pipefail

# 1. detect platform
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *)
    echo "❌ Unsupported OS: $OS" >&2
    exit 1
    ;;
esac

# 2. install prerequisites
install_pkgs() {
  if [[ "$PLATFORM" == "macos" ]]; then
    if ! command -v brew &>/dev/null; then
      echo "❌ Homebrew not found! Install it first: https://brew.sh" >&2
      exit 1
    fi
    brew update
    brew install git curl zsh fzf
  else
    if   command -v apt   &>/dev/null; then sudo apt update && sudo apt install -y git curl zsh
    elif command -v dnf   &>/dev/null; then sudo dnf install -y git curl zsh
    elif command -v pacman&>/dev/null; then sudo pacman -Sy --noconfirm git curl zsh
    else
      echo "❌ No supported package manager (apt, dnf, pacman) found. Install git/curl/zsh manually." >&2
      exit 1
    fi
  fi
}
install_pkgs

# Install Oh My Zsh (unattended)
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

## Install Plugins ##
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
# install Powerlevel10k
P10K_DIR="${ZSH_CUSTOM}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# Install zsh-autosuggestions 
ZSH_AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
if [[ ! -d "$ZSH_AUTOSUGGESTIONS_DIR" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
fi

# Install zsh-syntax-highlighting
ZSH_SYNTAX_HIGHLIGHTING_DIR="${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
if [[ ! -d "$ZSH_SYNTAX_HIGHLIGHTING_DIR" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_HIGHLIGHTING_DIR"
fi

# Install fzf
if ! command -v fzf &>/dev/null; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --bin --no-key-bindings --no-completion --no-update-rc
fi

# Include zsh-quick-boot on the .zshrc
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
touch "$HOME/.zshrc"
PATCH_START="# >>> zsh-quick-boot import start >>>"
if ! grep -Fq "$PATCH_START" "$HOME/.zshrc"; then
  cat >>"$HOME/.zshrc" <<EOF

# >>> zsh-quick-boot import start (added by zqb) >>>
if [[ -f "${SCRIPT_DIR}/dotfiles/.zshrc" ]]; then
  source "${SCRIPT_DIR}/dotfiles/.zshrc"
fi
# <<< zsh-quick-boot import end <<<
EOF
fi

# Set zsh as the default shell
ZSH_BIN="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_BIN" ]]; then
  chsh -s "$ZSH_BIN"
fi

echo "✅ All done! Restart your shell or run: exec zsh"