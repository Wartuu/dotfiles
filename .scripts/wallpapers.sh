#!/bin/bash

wallpaper_dir="$HOME/.wallpapers"
interval=1800

while true; do
  for wallpaper in "$wallpaper_dir"/*; do
    [[ -f "$wallpaper" ]] || continue
    swww img "$wallpaper" --transition-type=grow --transition-fps=60 --transition-duration 3
    sleep "$interval"
  done
done
