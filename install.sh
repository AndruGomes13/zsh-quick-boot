#!/usr/bin/env bash
set -euo pipefail

# --- Config Paths ---
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DOT_ZSHRC_ABS="${SCRIPT_DIR}/dotfiles/.zshrc"
DOT_P10K_ABS="${SCRIPT_DIR}/dotfiles/.p10k.zsh"

PATCH_START="# >>> zsh-quick-boot import start >>>"
PATCH_END="# <<< zsh-quick-boot import end <<<"

if [[ ! -f "$DOT_ZSHRC_ABS" ]]; then
  echo "❌ Missing ${DOT_ZSHRC_ABS}" >&2
  exit 1
fi



# --- Helper Functions ---
has_sudo() {
  if [ "$EUID" -eq 0 ]; then return 0; fi
  command -v sudo >/dev/null 2>&1 || return 1
  sudo -n true >/dev/null 2>&1 || { sudo -v && sudo -n true >/dev/null 2>&1; }
}


write_minimal_stub() {
  local stub="$HOME/.zshrc"
  # Remove any previous managed block
  local tmp="$(mktemp)"
  awk -v s="$PATCH_START" -v e="$PATCH_END" '
    BEGIN{skip=0}
    $0 ~ s {skip=1; next}
    $0 ~ e {skip=0; next}
    skip==0 {print}
  ' "$stub" 2>/dev/null > "$tmp" || true
  mv "$tmp" "$stub"
  # Append fresh block with baked absolute path (no env vars)
  {
    echo
    echo "$PATCH_START"
    echo "if [[ -f \"$DOT_ZSHRC_ABS\" ]]; then"
    echo "  source \"$DOT_ZSHRC_ABS\""
    echo "fi"
    echo "$PATCH_END"
  } >> "$stub"
}

install_if_missing_brew() {
  local pkg="$1"
  brew list --versions "$pkg" >/dev/null 2>&1 || brew install "$pkg"
}

# --- Platform ---
case "$(uname -s)" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *) echo "❌ Unsupported OS" >&2; exit 1 ;;
esac

# --- System Deps ---
install_macos_deps() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "❌ Homebrew not found. Install from https://brew.sh" >&2
    exit 1
  fi

  install_if_missing_brew git
  install_if_missing_brew curl
  install_if_missing_brew zsh
  install_if_missing_brew fzf
}


install_linux_deps() {
  if ! has_sudo; then
    echo "⚠️  No sudo; skipping system package installs." >&2
    return 0
  fi

  # Noninteractive for Debian-based
  export DEBIAN_FRONTEND=noninteractive

  if   command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y git curl zsh fzf
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf -y install git curl zsh fzf
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --needed --noconfirm git curl zsh fzf
  else
    echo "⚠️  No supported package manager; install git/curl/zsh/fzf manually." >&2
  fi
}

echo "Installing Dependencies for: $PLATFORM"
if [[ "$PLATFORM" == "macos" ]]; then
  install_macos_deps || echo "⚠️ macOS deps step returned non-zero; continuing."
else
  install_linux_deps
fi
echo "Installed depedencies."


# --- Install Oh My Zsh + Plugins ---

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install Powerlevel10k
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

# fzf (Linux fallback if not installed above)
if ! command -v fzf >/dev/null 2>&1; then
  if [[ ! -d "$HOME/.fzf" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  fi
  "$HOME/.fzf/install" --bin --no-key-bindings --no-completion --no-update-rc
fi

# --- p10k config ---
if [[ -f "$DOT_P10K_ABS" && ! -f "$HOME/.p10k.zsh" ]]; then
  cp "$DOT_P10K_ABS" "$HOME/.p10k.zsh"
fi

# --- .zshrc patch ---
write_minimal_stub


# --- default shell to zsh ---
ZSH_BIN="$(command -v zsh || true)"

if [[ -n "${ZSH_BIN}" ]]; then
  # Ensure zsh is listed in /etc/shells; otherwise chsh will fail
  if [[ -f /etc/shells ]] && ! grep -qxF "$ZSH_BIN" /etc/shells; then
    if has_sudo; then
      echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
    fi
  fi
  if [[ "${SHELL:-}" != "$ZSH_BIN" ]] && tty -s; then
    chsh -s "$ZSH_BIN" || true
  fi
fi

echo "✅ Done. Open a new terminal or run: exec zsh -l"
