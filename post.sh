#!/usr/bin/env bash

# sync clock
sudo timedatectl set-ntp true
sudo hwclock --systohc

# update mirrors
sudo reflector --country Canada --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

# open firewall ports
# sudo firewall-cmd --add-port=1025-65535/tcp --permanent
# sudo firewall-cmd --add-port=1025-65535/udp --permanent
# sudo firewall-cmd --reload

# Install repo packages
sudo pacman -S xorg-server xorg-xinit xorg-xsetroot xorg-xrandr libxss xwallpaper picom unclutter lsd tmux xclip firefox sxiv zathura zathura-pdf-mupdf mpv weechat yt-dlp jq fzf cmatrix ttf-font-awesome ttf-linux-libertine ttf-inconsolata ttf-roboto noto-fonts

# Install suckless programs
mkdir ~/repos && cd ~/repos
repos=( "dwm" "slstatus" "slock" "xssstate" "dmenu" "st" )
for repo in ${repos[@]}
do
    git clone git://git.suckless.org/$repo
    cd $repo;make;sudo make install;cd ..
done

# deploy dotfiles and scripts
cd ~/repos
git clone https://github.com/xerifeazeitona/dots_n_scripts.git
sudo cp dots_n_scripts/scripts/* /usr/local/bin/
cp -r dots_n_scripts/dotfiles/* ~/
rm -rf dots_n_scripts

printf "\e[1;32mDone! \n\e[0m"
