#!/usr/bin/env bash
set -euo pipefail

sync_newer() {
  local a=$1
  local b=$2

  # nothing to do if both files are missing
  [[ -f $a || -f $b ]] || return 0

  # copy if only one file exists
  [[ -f $a && ! -f $b ]] && { cp -f "$a" "$b"; return; }
  [[ -f $b && ! -f $a ]] && { cp -f "$b" "$a"; return; }

  # both exist: copy the newer one
  [[ $a -nt $b ]] && cp -f "$a" "$b" || cp -f "$b" "$a"
}

. .env

packages=(
  # terminal basics
  bash-completion less man-pages mandoc

  # archives
  zip unzip p7zip rsync

  # tui tools
  tmux ncdu htop btop cmus fastfetch

  # networking / dev
  openssh netcat perl-rename git

  # runtimes
  # jdk-openjdk maven
  python python-pip python-pipx nodejs npm

  # data processing
  jq xmlstarlet cloc

  # media
  exiv2 imagemagick libheif ffmpeg opus-tools yt-dlp id3v2
)

cp files/.bashrc ~/.bashrc
cp files/.profile ~/.bash_profile
mkdir -p ~/.{config,cache}/gallery-dl
cp files/gallery-dl.conf ~/.config/gallery-dl/config.json

sync_newer files/cache.sqlite3 ~/.cache/gallery-dl/cache.sqlite3

u=${USER?}
if [[ ! -e ~/.gitconfig && -f "/mnt/c/Users/$u/.gitconfig" ]]; then
  ln -s "/mnt/c/Users/$u/.gitconfig" ~/.gitconfig
fi

git config --global init.defaultBranch dev
git config --global push.autoSetupRemote true
git config --global core.autocrlf input

pacman -Sy --needed --ask=4 archlinux-keyring
pacman -Su --ask=4
pacman -Su --needed --ask=4 "${packages[@]}"

pipx install gallery-dl
pipx ensurepath

if ! locale -a | grep -qx 'en_US.utf8'; then
  sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
  locale-gen
  localectl set-locale LANG=en_US.UTF-8
fi

if [[ "$SHELL" != "/bin/bash" ]]; then
  chsh -s /bin/bash
  reboot
fi
