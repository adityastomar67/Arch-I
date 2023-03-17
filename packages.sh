# core system components
BASE=(
    'base'                          # NEEDED: Base Arch Linux system
    'linux'                         # NEEDED: Linux Kernel
    'linux-firmware'                # NEEDED: Firmware files for Linux
)

# basic system components
BASE_APPS=(
    'archlinux-keyring'             # NEEDED  : Arch Linux PGP key ring
    'pacman-contrib'
    'base-devel'                    # NEEDED  : Various development utilities, needed for Paru and all AUR packages
    'cronie'                        # OPTIONAL: Run jobs periodically
    'dialog'                        # NEEDED  : Dependency for many TUI programs
    'dosfstools'                    # OPTIONAL: Utilities for DOS filesystems
    'efibootmgr'                    # OPTIONAL: Modify UEFI systems from CLI
    'git'                           # OPTIONAL: Version Control System, needed for the Grub theme, Dotfiles, and Paru
    'grub'                          # NEEDED  : Bootloader
    'linux-headers'                 # OPTIONAL: Scripts for building kernel modules
    'man-db'                        # OPTIONAL: Manual database
    'mtools'                        # OPTIONAL: Utilities for DOS disks
    'mtpfs'                         # OPTIONAL: Media Transfer Protocol support
    'network-manager-applet'        # OPTIONAL: Applet for managing the network
    'networkmanager'                # OPTIONAL: Network connection manager
    'openssh'                       # OPTIONAL: Remotely control other systems
    'os-prober'                     # OPTIONAL: Scan for other operating systems
    'python'                        # NEEDED  : Essential package for many programs
    'reflector'                     # OPTIONAL: Get download mirrors
    'usbutils'                      # OPTIONAL: Various tools for USB devices
    'wget'                          # OPTIONAL: Utility to download files
    'zsh'                           # OPTIONAL: An alternate shell to bash
)

# user applications
APPS=(
    'alsa-utils'                    # OPTIONAL: Utilities for managing alsa cards
    'exa'                           # OPTIONAL: Replacement for the ls command
    'ffmpeg'                        # OPTIONAL: Audio and video magic
    'firefox'                       # OPTIONAL: Web browser
    'flameshot'                     # OPTIONAL: Screenshot utility
    'mpv'                           # OPTIONAL: Suckless video player
    'musikcube'
    'neofetch'                      # OPTIONAL: Display system information, with style
    'neovim'                        # OPTIONAL: Objectively better than Emacs
    'ntfs-3g'                       # OPTIONAL: Driver for NTFS file systems
    'numlockx'                      # OPTIONAL: Set numlock from CLI
    'p7zip'                         # OPTIONAL: Support for 7zip files
    'pavucontrol'                   # OPTIONAL: Pulse Audio volume control
    'pipewire'                      # OPTIONAL: Modern audio router and processor
    'pipewire-alsa'                 # OPTIONAL: Pipewire alsa configuration
    'pipewire-pulse'                # OPTIONAL: Pipewire replacement for pulseaudio
    'python-pynvim'                 # OPTIONAL: Python client for neovim
    'ripgrep'                       # OPTIONAL: GNU grep replacement
    'unrar'                         # OPTIONAL: Support for rar files
    'unzip'                         # OPTIONAL: Support for zip files
    'xclip'                         # OPTIONAL: Copy to clipboard from CLI
    'zathura'                       # OPTIONAL: Document viewer
    'zathura-pdf-mupdf'             # OPTIONAL: PDF ePub and OpenXPS support for zathura
    'zenity'                        # OPTIONAL: Basic GUIs from CLI
    'zip'                           # OPTIONAL: Support for zip files
)

GAMING_APPS=(
    'discord'                       # OPTIONAL: Communication software
    'gamescope'                     # OPTIONAL: WM container for games
    'lutris'                        # OPTIONAL: Game launcher and configuration tool
    'mangohud'                      # OPTIONAL: HUD for monitoring system and logging
    'steam'                         # OPTIONAL: Game storefront
    'steam-native-runtime'          # OPTIONAL: A native runtime for Steam
    'wine'                          # OPTIONAL: Run Windows applications on Linux
    'wine-gecko'                    # OPTIONAL: Wine's replacement for Internet Explorer
    'wine-mono'                     # OPTIONAL: Wine's replacement for .Net Framework
    'winetricks'                    # OPTIONAL: Script to install libraries in Wine
)

# all of these will get enabled
SERVICES=(
    'NetworkManager'
    'cronie'
    'mpd'
    'sshd'
)

# this will get populated automatically
GPU_DRIVERS=()


# DESKTOP ENVIRONMENTS #
ENVIRONMENTS=(
    'AWESOME'
    'BUDGIE'
    'BSPWM'
    'CINNAMON'
    'DEEPIN'
    'ENLIGHTENMENT'
    'GNOME'
    'KDE'
    'LXQT'
    'MATE'
    'QTILE'
    'XFCE'
)

AWESOME=(
    'alacritty'
    'awesome-git'
    'breeze-gtk'
    'dex'
    'dunst'
    'engrampa'
    'feh'
    'gnome-keyring'
    'light'
    'lightdm'
    'lightdm-gtk-greeter'
    'mate-polkit'
    'mpd'
    'papirus-icon-theme'
    'picom-pijulius-git'
    'rofi'
    'thunar'
    'wmctrl'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gtk'
    'xorg-server'
    'xorg-xrandr'
)

BUDGIE=(
    'budgie-desktop'
    'lightdm'
    'lightdm-gtk-greeter'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gtk'
    'xorg-server'
)

BSPWM=(
    'bspwm' 
    'polybar' 
    'sxhkd' 
    'alacritty' 
    'brightnessctl' 
    'dunst' 
    'rofi' 
    'lsd' 
    'jq' 
    'polkit-gnome' 
    'git playerctl' 
    'mpd' 
    'ncmpcpp' 
    'geany' 
    'ranger' 
    'mpc' 
    'picom' 
    'feh' 
    'ueberzug'
    'maim'
    'pamixer'
    'libwebp'
    'webp-pixbuf-loader'
    'xorg-xprop'
    'xorg-xkill'
    'physlock'
    'papirus-icon-theme'
    'ttf-jetbrains-mono'
    'ttf-jetbrains-mono-nerd'
    'ttf-terminus-nerd'
    'ttf-inconsolata'
    'ttf-joypixels'
)

CINNAMON=(
    'cinnamon'
    'lightdm'
    'lightdm-gtk-greeter'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gtk'
    'xorg-server'
)

DEEPIN=(
    'deepin'
    'deepin-extra'
    'lightdm'
    'lightdm-gtk-greeter'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gtk'
    'xorg-server'
)

ENLIGHTENMENT=(
    'enlightenment'
    'lightdm'
    'lightdm-gtk-greeter'
    'terminology'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gtk'
    'xorg-server'
)

GNOME=(
    'gdm'
    'gnome'
    'gnome-tweaks'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gnome'
)

KDE=(
    'ark'
    'dolphin'
    'dolphin-plugins'
    'ffmpegthumbs'
    'filelight'
    'gwenview'
    'kcalc'
    'kcharselect'
    'kcolorchooser'
    'kcron'
    'kdeconnect'
    'kdegraphics-thumbnailers'
    'kdenetwork-filesharing'
    'kdesdk-thumbnailers'
    'kdialog'
    'kmix'
    'kolourpaint'
    'konsole'
    'kontrast'
    'okular'
    'packagekit-qt5'
    'plasma'
    'print-manager'
    'sddm'
    'xdg-desktop-portal'
    'xdg-desktop-portal-kde'
)

LXQT=(
    'breeze-icons'
    'lxqt'
    'lxqt-connman-applet'
    'sddm'
    'slock'
    'xdg-desktop-portal'
    'xdg-desktop-portal-kde'
)

MATE=(
    'lightdm'
    'lightdm-gtk-greeter'
    'mate'
    'mate-extra'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gtk'
    'xorg-server'
)

QTILE=(
    'alacritty'
    'breeze-gtk'
    'dex'
    'dunst'
    'engrampa'
    'feh'
    'gnome-keyring'
    'light'
    'lightdm'
    'lightdm-gtk-greeter'
    'mate-polkit'
    'mpd'
    'papirus-icon-theme'
    'picom'
    'qtile'
    'rofi'
    'thunar'
    'wmctrl'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gtk'
    'xorg-server'
    'xorg-xrandr'
)

XFCE=(
    'lightdm'
    'lightdm-gtk-greeter'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gtk'
    'xfce4'
    'xfce4-goodies'
    'xorg-server'
)
