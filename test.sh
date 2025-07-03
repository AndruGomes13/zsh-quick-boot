SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
touch "./test.txt"
PATCH_START="# >>> zsh-quick-boot import start >>>"
if ! grep -Fq "$PATCH_START" "./test.txt"; then
  cat >>"./test.txt" <<EOF

# >>> zsh-quick-boot import start (added by zqb) >>>
if [[ -f "${SCRIPT_DIR}/dotfiles/.zshrc" ]]; then
  source "${SCRIPT_DIR}/dotfiles/.zshrc"
fi
# <<< zsh-quick-boot import end <<<
EOF
fi