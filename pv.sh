#!/bin/sh

CACHE="/home/pi/.cache/$(echo $1 | sed 's|/||g;s| ||g' | cut -d '.' -f -1)"

case "$1" in
    *.tar*) tar tf "$1";;
    *.zip) unzip -l "$1";;
    *.rar) unrar l "$1";;
    *.7z) 7z l "$1";;
    *.pdf) pdftotext "$1" -;;
    *.avi|*.mp4|*.wmv|*.dat|*.3gp|*.ogv|*.mkv|*.mpg|*.mpeg|*.vob|*.fl[icv]|*.m2v|*.mov|*.webm|*.ts|*.mts|*.m4v|*.r[am]|*.qt|*.divx)
        [ ! -f "${CACHE}.jpg" ] && \
            ffmpegthumbnailer -i "$1" -o "${CACHE}.jpg" -s 0 -q 5
        ~/.config/lf/draw_img.sh "${CACHE}.jpg"
        ~/jellyfin.sh "$1"
        ;;
    *.bmp|*.jpg|*.jpeg|*.png|*.xpm|*.webp|*.gif|*.jfif)
        ~/.config/lf/draw_img.sh "$1"
        ;;
    *) highlight -O ansi "$1";;
esac
