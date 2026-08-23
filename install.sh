DOTFILES_DIR=~/dotfiles

#INSTALLING
  #hyprland
sudo pacman -S --needed --noconfirm hyprland hyprpaper hyprlock hypridle pipewire pipewire-pulse waybar wofi rofi
  #apps
sudo pacman -S --needed --noconfirm kitty alacritty firefox git zsh nautilus neovim wl-clipboard btop lazygit spotify-launcher cava
  #tools (screenshots, bluetooth, notification, calendar, audiotui, etc)
sudo pacman -S --needed --noconfirm swappy grim slurp bluez bluez-utils swaync calcurse power-profiles-daemon impala bluetui wiremix playerctl brightnessctl jq

# Networking: iwd + systemd-resolved
sudo mkdir -p /etc/iwd
sudo tee /etc/iwd/main.conf > /dev/null <<'EOF'
[General]
EnableNetworkConfiguration=true

[Network]
NameResolvingService=systemd
EOF

sudo systemctl disable --now NetworkManager 2>/dev/null || true
sudo systemctl disable --now wpa_supplicant 2>/dev/null || true

sudo systemctl enable --now iwd
sudo systemctl enable --now systemd-resolved


git config --global init.defaultBranch main

sudo systemctl enable --now bluetooth

if ! command -v yay &> /dev/null; then
    sudo pacman -S --needed --noconfirm base-devel binutils
    git clone https://aur.archlinux.org/yay.git ~/yay
    cd ~/yay
    makepkg -si --noconfirm
    cd -
    rm -rf ~/yay
fi

yay -S --needed --noconfirm nwg-look github-cli oh-my-posh xdg-desktop-portal-hyprland hyprpolkitagent light lazydocker

# tmux
sudo pacman -S --noconfirm tmux fzf bat
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# TS nvim
sudo pacman -S --noconfirm nodejs npm
sudo npm install -g tree-sitter-cli

#CONFIG
cp $DOTFILES_DIR/.zshrc ~/
cp -r $DOTFILES_DIR/config/hypr ~/.config/
cp -r $DOTFILES_DIR/config/kitty ~/.config/
cp -r $DOTFILES_DIR/config/nvim ~/.config/
cp -r $DOTFILES_DIR/config/ohmyposh ~/.config/
cp -r $DOTFILES_DIR/config/alacritty ~/.config/
cp -r $DOTFILES_DIR/config/Kvantum ~/.config/
cp -r $DOTFILES_DIR/config/qt6ct ~/.config/
cp -r $DOTFILES_DIR/config/gtk-3.0 ~/.config/
cp -r $DOTFILES_DIR/config/nwg-look ~/.config/
cp -r $DOTFILES_DIR/config/waybar ~/.config/
cp -r $DOTFILES_DIR/config/rofi ~/.config/
cp -r $DOTFILES_DIR/config/tmux ~/.config/
cp -r $DOTFILES_DIR/config/scripts ~/.config/
cp -r $DOTFILES_DIR/config/themes ~/.config/

chmod +x ~/.config/waybar/scripts/audio.sh
chmod +x ~/.config/waybar/scripts/bluetooth.sh
chmod +x ~/.config/waybar/scripts/wifi.sh
chmod +x ~/.config/waybar/scripts/calendar.sh

chmod +x ~/.config/scripts/battery_notification.sh
chmod +x ~/.config/scripts/change-theme.sh
chmod +x ~/.config/scripts/powermenu.sh
chmod +x ~/.config/scripts/options.sh
chmod +x ~/.config/scripts/options/battery.sh
chmod +x ~/.config/scripts/options/monitor.sh

#LOCAL
mkdir -p ~/.local/share

cp -r $DOTFILES_DIR/local/share/fonts ~/.local/share/fonts/
cp -r $DOTFILES_DIR/local/share/themes ~/.local/share/themes/

sudo mkdir -p /usr/share
sudo cp -r $DOTFILES_DIR/local/Kvantum/* /usr/share/Kvantum/
sudo cp -r $DOTFILES_DIR/local/share/themes/* /usr/share/themes/

#PICTURES
mkdir -p ~/Pictures
cp -r $DOTFILES_DIR/pictures/* ~/Pictures/

#AUTOLOGIN
sudo cp $DOTFILES_DIR/autologin/autologin-first-user /usr/local/bin/
sudo chmod +x /usr/local/bin/autologin-first-user

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
sudo cp $DOTFILES_DIR/autologin/autologin.conf /etc/systemd/system/getty@tty1.service.d/

sudo systemctl daemon-reload

cp $DOTFILES_DIR/autologin/.bash_profile ~/
cp $DOTFILES_DIR/autologin/.zprofile ~/

# Making zsh default shell
chsh -s $(which zsh)

#programming languages
  #go
sudo pacman -S --needed --noconfirm go
go install golang.org/x/tools/gopls@latest 
go install mvdan.cc/gofumpt@latest 
go install golang.org/x/tools/cmd/goimports@latest 
go install github.com/segmentio/golines@latest
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
  #rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup component add rustfmt rust-analyzer

echo "completed, now reboot"
