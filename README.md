## Omarchy setup (current system)

Customizations live in `omarchy/` and are applied by `apply-omarchy.sh`
(Hyprland bindings, kitty, zsh, tmux, oh-my-posh, shell bar, idle timings,
custom themes + wallpapers, NvChad + theme hook, Limine timeout, plymouth).
Safe to re-run: replaced files are backed up with a timestamp first.

```bash
# Clone wherever you keep it (example: ~/dotfiles)
git clone https://github.com/Kevinrestrepoh/dotfiles.git ~/dotfiles
cd ~/dotfiles

chmod +x apply-omarchy.sh
./apply-omarchy.sh
```

Notes:

- **Password:** the script asks for your sudo password **once** up front and
  keeps it cached while it runs (package installs, Limine timeout, theme
  pruning, plymouth all need privilege). Optional, to skip passwords
  permanently for these steps, add a file like `/etc/sudoers.d/omarchy-apply`
  (via `visudo`) with `NOPASSWD` rules for the exact commands — e.g.
  `kevin ALL=(ALL) NOPASSWD: /usr/bin/pacman, /usr/bin/rm`.
- **Stock themes:** a plain run manages only your themes in
  `~/.config/omarchy/themes/` (the 9 declared + `nord`). Stock themes in
  `/usr/share/omarchy/themes/` are owned by the omarchy package and come back
  on every `omarchy update`, so hiding them is opt-in and ephemeral:
  `PRUNE_STOCK_THEMES=1 ./apply-omarchy.sh`.

## 0. Legacy manual Arch setup (pre-Omarchy, kept for reference)

## 1. Install Arch Linux

You can either follow the **manual installation** or use `archinstall` to simplify the process.

## 2. Install Graphic Drivers

Ensure that you install the correct drivers for your graphics card:
- **NVIDIA** / **AMD** / **Intel**

If you used `archinstall`, make sure to select the following during the setup:
- **Profile**: Choose `xorg`
- **Graphics**: Select your specific graphics card (NVIDIA/AMD/Intel)
- If wifi is not working, install: sudo pacman -S networkmanager and after reboot sudo systemctl enable --now NetworkManager, then execute nmtui

---

## 3. Clone and Set Up Your Dotfiles

Once you have your system installed and running, you can set up your dotfiles.

First, open a terminal and run the following commands:

```bash
# Install Git if it is not already installed
sudo pacman -S git

# Clone the dotfiles repository
git clone https://github.com/Kevinrestrepoh/dotfiles.git ~/dotfiles

# Change to the dotfiles directory
cd ~/dotfiles

# Make the install script executable
chmod +x install.sh

# Run the installation script
./install.sh

# Reboot the system
sudo reboot
```
Once finished you can delete the dotfiles folder
