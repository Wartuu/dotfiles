#!/bin/bash

wallpaper_dir="$HOME/.wallpapers"
interval=600

while true; do
  for wallpaper in "$wallpaper_dir"/*; do
    [[ -f "$wallpaper" ]] || continue
    swww img "$wallpaper" --transition-type fade --transition-fps 60 --transition-duration 1
    sleep "$interval"
  done
done
