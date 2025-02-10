rm -rf ~/.config/hypr ~/.config/rofi ~/.config/swaylock ~/.config/waybar
cp ~/dotfiles/config/* ~/.config -r && hyprctl reload

chmod +x ~/.config/swaylock/lock.sh