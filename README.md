# zsh-quick-boot

**zsh-quick-boot** is a fast, minimal, and automated setup for a beautiful, productive Zsh shell. It installs Oh My Zsh, Powerlevel10k, essential plugins, and provides a clean, ready-to-go configuration with a single script.

## Features

- **One-command install**: Just run `install.sh` and get a fully configured Zsh environment.
- **Cross-platform**: Supports macOS and major Linux distributions.
- **Modern prompt**: Powerlevel10k theme for a fast, informative, and beautiful prompt.
- **Essential plugins**:
  - `zsh-autosuggestions`
  - `zsh-syntax-highlighting`
  - `fzf` (fuzzy finder)
  - `git`
- **Minimal, readable config**: Ships with a simple `.zshrc` and Powerlevel10k config.
- **Safe**: Only appends to your `.zshrc` if not already present, and backs up your previous config.

## Installation

```sh
git clone https://github.com/yourusername/zsh-quick-boot.git
cd zsh-quick-boot
./install.sh
```

- On **macOS**, Homebrew is required.
- On **Linux**, supports `apt`, `dnf`, or `pacman` package managers.

## What it does

- Installs required packages: `git`, `curl`, `zsh` and `fzf`.
- Installs [Oh My Zsh](https://ohmyz.sh) (unattended).
- Installs [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme.
- Installs plugins: [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting), and [fzf](https://github.com/junegunn/fzf).
- Copies the provided `.zshrc` and `.p10k.zsh` config files to your home directory.
- Appends a block to your `.zshrc` to source the custom config.
- Sets Zsh as your default shell.

## Included dotfiles

- **dotfiles/.zshrc**: Minimal config that loads Oh My Zsh, Powerlevel10k, and the essential plugins.
- **dotfiles/.p10k.zsh**: Pre-generated Powerlevel10k configuration for a clean, lean prompt.

## Customization

- You can further customize your prompt by running `p10k configure` after installation.
- Edit `dotfiles/.zshrc` to add or remove plugins as you like.

## Uninstallation

To revert, remove the lines between the `# >>> zsh-quick-boot import start >>>` and `# <<< zsh-quick-boot import end <<<` markers in your `~/.zshrc`, and restore your previous shell if desired.

---

Let me know if you want to add badges, screenshots, or more advanced usage notes!
