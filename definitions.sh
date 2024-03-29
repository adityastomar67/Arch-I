WHITE="\033[0;37m"
PURPLE="\033[0;35m"
RED="\033[0;31m"
GREEN="\033[1;32m"
TAN="\033[0;33m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
BOLD="\033[4;37m"
UNDERLINE="\033[4;37m"
RESET="\033[0m"

##--> PRE-SETUP <--##
setup_variables() {
    ##--> Choose the root drive <--##
    echo
    echo "Choose the device you want to install Arch Linux on:"
    echo "NOTE: ${BOLD}${RED}The chosen device will be completely erased and all its data will be lost!${RESET}"
    echo 
    echo "${YELLOW}"
    lsblk
    echo "${RESET}"
    echo
    echo
    echo "Choose the root drive: "
    select drive in $(lsblk | sed '/\(^├\|^└\|^NAME\)/d' | cut -d " " -f 1)
    do
        if [ $drive ]; then
            export ROOT_DEVICE="/dev/$drive"
            break
        fi
    done

    ##--> Choose Dual-Boot partition <--##
    header
    echo
    echo "Choose your Windows partition to setup dual-boot: "
    select drive in $(lsblk | sed '/\(^├\|^└\)/!d' | cut -d " " -f 1 | cut -c7-) "None"
    do
        if [ "$drive" = "None" ]; then
            unset WIN_DEVICE
            break
        fi

        if [ $drive ]; then
            export WIN_DEVICE="/dev/$drive"
            break
        fi
    done

    ##--> Choose storage partition <--##
    header
    echo
    echo "Choose an extra partition to use as Storage: "
    select drive in $(lsblk | sed '/\(^├\|^└\)/!d' | cut -d " " -f 1 | cut -c7-) "None"
    do
        if [ "$drive" = "None" ]; then
            unset STRG_DEVICE
            break
        fi

        if [ $drive ]; then
            export STRG_DEVICE="/dev/$drive"
            break
        fi
    done

    ##--> Give out username <--##
    header
    echo
    read "USR?Enter your username: "

    ##--> Put the password <--##
    while
        echo "${YELLOW}"
        read -s "PASSWD?Enter your password: "
        echo ""
        read -s "CONF_PASSWD?Re-enter your password: "
        echo "${RESET}"
        [ "$PASSWD" != "$CONF_PASSWD" ]
    do echo "${RED}Passwords don't match${RESET}"; done
    echo "${GREEN}Passwords matched.${RESET}"
    sleep 2

    ##--> Give Hostname <--##
    header
    echo
    read "HOSTNAME?Enter this machine's hostname: "

    ##--> Select for gaming application <--##
    header
    echo
    echo "Do you want to install applications for gaming?: "
    select GAMING in "Yes" "No"
    do
        if [ $GAMING ]; then
            break
        fi
    done

    ##--> CHoose If you wants to install configs <--##
    header
    echo
    echo "Do you want to install dotfiles?: "
    select DOTFILES in "Yes" "No"
    do
        if [ $DOTFILES ]; then
            break
        fi
    done

    ##--> Detects Wifi Card if present <--##
    if [ "$(lspci -d ::280)" ]; then
        WIFI=y
    fi

    ##--> Choose Your DE <--##
    header
    echo
    echo "Choose your desktop environment: "
    select DE in ${ENVIRONMENTS[@]}
    do
        if [ $DE ]; then
            break
        fi
    done

    ##--> this: "<<-" ignores indentation, but only for tab characters <--##
    cat <<- EOL > vars.sh
		export DE=$DE
		export USR=$USR
		export PASSWD=$PASSWD
		export HOSTNAME=$HOSTNAME
		export WIFI=$WIFI
		export GAMING=$GAMING
		export DOTFILES=$DOTFILES
	EOL

    print_summary
}

print_summary() {
    header
    echo
    echo "${UNDERLINE}Summary:-${RESET}"
    echo "${BOLD}${RED}"
    echo "The installer will erase all data on the ${RESET}${YELLOW}$ROOT_DEVICE${RESET} drive."

    if [ $STRG_DEVICE ]; then
        echo "It will use ${YELLOW}$STRG_DEVICE${RESET} as a storage medium and mount it on ${YELLOW}/mnt/Storage${RESET}"
    fi


    if [ $WIN_DEVICE ]; then
        echo "It will use ${YELLOW}$WIN_DEVICE${RESET} as a Windows partition and mount it on ${YELLOW}/mnt/Windows${RESET}"
    fi

    echo "Your username will be ${YELLOW}$USR${RESET}"

    echo "The machine's hostname will be ${YELLOW}$HOSTNAME${RESET}"

    echo "Your Deskop Environment will be ${YELLOW}$DE${RESET}"

    if [ "${GAMING}" = "Yes" ]; then
        echo "${YELLOW}Installer will install gaming packages.${RESET}"
    fi

    if [ "${DOTFILES}" = "Yes" ]; then
        echo "${YELLOW}Installer will configure dotfiles.${RESET}"
    fi

    read "ANS?Proceed with installation? [y/N]: "
    if [ "$ANS" != "y" ]; then
        exit
    fi
}

configure_pacman() {
    sed -i 's/^#Color/Color/' /etc/pacman.conf
    sed -i 's/^#VerboseP/VerboseP/' /etc/pacman.conf
    sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
    sed -i "s/^#ParallelDownloads = 5/ParallelDownloads = 10\nILoveCandy/" /etc/pacman.conf
}

update_keyring() {
    timedatectl set-ntp true # sync clock
    hwclock --systohc
    # this is useful if installing from outdated ISO
    pacman --noconfirm --ask=127 -Sy archlinux-keyring
}

##--> PARTITIONING <--##
partition_and_mount() {

    if [ -d /sys/firmware/efi/efivars ]; then
        UEFI=y
        partition_and_mount_uefi
    else
        UEFI=n
        partition_and_mount_bios
    fi

    echo "UEFI=$UEFI" >> vars.sh
}

partition_and_mount_uefi() {
    # disk partitioning
    wipefs --all --force $ROOT_DEVICE
    # cut removes comments from heredoc
    # this: "<<-" ignores indentation, but only for tab characters
    cut -d " " -f 1 <<- EOL | fdisk --wipe always --wipe-partitions always $ROOT_DEVICE
		g           # gpt partition scheme
		n           # new partition
		            # partition number 1
		            # start of sector
		+512MB      # plus 512MB
		n           # new parition
		            # partition number 2
		            # start of sector
		            # end of sector
		w           # write
	EOL

    # get partition names
    PARTITIONS=($(for PARTITION in $(dirname /sys/block/$(basename $ROOT_DEVICE)/*/partition); do
        basename $PARTITION
    done))

    # partition formatting
    mkfs.fat -F 32 /dev/$PARTITIONS[1]     # boot
    mkfs.ext4 /dev/$PARTITIONS[2] -L ROOT  # root

    # mount partitions
    mkdir -pv /mnt
    mount /dev/$PARTITIONS[2] /mnt

    mkdir -pv /mnt/boot
    mount /dev/$PARTITIONS[1] /mnt/boot

    if [ $STRG_DEVICE ]; then
        mkdir -pv /mnt/mnt/Storage
        mount ${STRG_DEVICE} /mnt/mnt/Storage
    fi

    if [ $WIN_DEVICE ]; then
        mkdir -pv /mnt/mnt/Windows
        mount ${WIN_DEVICE} /mnt/mnt/Windows
    fi

    # get mirrors
    reflector > /etc/pacman.d/mirrorlist
}

partition_and_mount_bios() {
    # disk partitioning
    wipefs --all --force $ROOT_DEVICE
    # cut removes comments from heredoc
    # this: "<<-" ignores indentation, but only for tab characters
    cut -d " " -f 1 <<- EOL | fdisk --wipe always --wipe-partitions always $ROOT_DEVICE
		n           # new partition
		            # primary partition
		            # partition number 1
		            # start of sector
		            # end of sector
		w           # write
	EOL

    # get partition names
    PARTITIONS=($(for PARTITION in $(dirname /sys/block/$(basename $ROOT_DEVICE)/*/partition); do
        basename $PARTITION
    done))

    # partition formatting
    mkfs.ext4 /dev/$PARTITIONS[1] -L ROOT  # root/boot

    # mount partitions
    mkdir -pv /mnt
    mount  /dev/$PARTITIONS[1] /mnt

    if [ $STRG_DEVICE ]; then
        mkdir -pv /mnt/mnt/Storage
        mount ${STRG_DEVICE} /mnt/mnt/Storage
    fi

    if [ $WIN_DEVICE ]; then
        mkdir -pv /mnt/mnt/Windows
        mount ${WIN_DEVICE} /mnt/mnt/Windows
    fi

    # get mirrors
    reflector > /etc/pacman.d/mirrorlist
}

install_base() {
    pacstrap /mnt ${BASE[*]}
    reflector > /mnt/etc/pacman.d/mirrorlist
    genfstab -U /mnt | awk '{
        if($2 == "/mnt/Windows" || $2 == "/mnt/Storage") {
            $4 = $4",nofail"
        }
        print
    }' >> /mnt/etc/fstab
}

##--> NETWORK <--##
setup_network() {
    # timezone
    ln -sfv /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

    configure_locale

    echo "${HOSTNAME}" > /etc/hostname

    # this: "<<-" ignores indentation, but only for tab characters
    cat >> /etc/hosts <<- EOL
		127.0.0.1   localhost
		::1         localhost
		127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
	EOL

    echo -e "${PASSWD}\n${PASSWD}\n" | passwd
}

configure_locale() {
    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    sed -i 's/^#es_AR.UTF-8 UTF-8/es_AR.UTF-8 UTF-8/' /etc/locale.gen

    locale-gen

    echo "LANG=en_US.UTF-8" > /etc/locale.conf
}

##--> BASE <--##
prepare_system() {
    # install basic system components
    if [ "$WIFI" = "y" ]; then
        BASE_APPS+=('wpa_supplicant' 'wireless_tools')
    fi

    # download database
    pacman --needed --noconfirm -Sy
    pacman --noconfirm --ask=127 --needed -S ${BASE_APPS[*]}
    # update pacman keys
    pacman-key --init
    pacman-key --populate

    install_cpu_ucode

    # install grub
    if [ "$UEFI" == y ]; then
        grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
    elif [ "$UEFI" == n ]; then
        grub-install --target=i386-pc $ROOT_DEVICE
    fi

    # configure grub
    echo -e '\nGRUB_DISABLE_OS_PROBER=false\n' >> /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
}

install_cpu_ucode() {
    CPU=$(lscpu | awk '/Vendor ID:/ {print $3}')

    if [ "$CPU" == AuthenticAMD ]; then
        pacman --needed --noconfirm -S amd-ucode
    elif [ "$CPU" == GenuineIntel ]; then
        pacman --needed --noconfirm -S intel-ucode
    fi
}

##--> USERS <--##
setup_users() {
    useradd -mG wheel,video,audio,optical,storage,games -s /bin/zsh ${USR}
    echo -e "${PASSWD}\n${PASSWD}\n" | passwd ${USR}

    export USR_HOME=$(getent passwd ${USR} | cut -d\: -f6)

    # let wheel group use sudo
    echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel_sudo
    # add insults to injury
    echo 'Defaults insults' > /etc/sudoers.d/insults
}

##--> GUI <--##
prepare_gui() {
    # add the default DM to the list of services to be enabled
    # and set up the DE variable
    case $DE in

        AWESOME)
            DE=${AWESOME[@]}
            SERVICES+=('lightdm')
            ;;
        BUDGIE)
            DE=${BUDGIE[@]}
            SERVICES+=('lightdm')
            ;;
        BSPWM)
            DE=${BSPWM[@]}
            ;;
        CINNAMON)
            DE=${CINNAMON[@]}
            SERVICES+=('lightdm')
            ;;
        DEEPIN)
            DE=${DEEPIN[@]}
            SERVICES+=('lightdm')
            ;;
        ENLIGHTENMENT)
            DE=${ENLIGHTENMENT[@]}
            SERVICES+=('lightdm')
            ;;
        GNOME)
            DE=${GNOME[@]}
            SERVICES+=('gdm')
            ;;
        KDE)
            DE=${KDE[@]}
            SERVICES+=('sddm')
            ;;
        LXQT)
            DE=${LXQT[@]}
            SERVICES+=('sddm')
            ;;
        MATE)
            DE=${MATE[@]}
            SERVICES+=('lightdm')
            ;;
        QTILE)
            DE=${QTILE[@]}
            SERVICES+=('lightdm')
            ;;
        XFCE)
            DE=${XFCE[@]}
            SERVICES+=('lightdm')
            ;;
    esac
}

##--> CUSTOMIZATION <--##
install_applications() {
    ins='paru --needed --useask --ask=127 --noconfirm -S'

    # let regular user run comands without password
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel_sudo

    # paru is needed for some AUR packages
    install_paru

    # install the chosen DE and GPU drivers
    sudo su ${USR} -s /bin/zsh -lc "$ins ${DE[*]}"

    detect_drivers
    if [ $GPU_DRIVERS ]; then
        sudo su ${USR} -s /bin/zsh -lc "$ins ${GPU_DRIVERS[*]}"
    fi

    # install user applications
    sudo su ${USR} -s /bin/zsh -lc "$ins ${APPS[*]}"

    if [ $GAMING == "Yes" ]; then
        sudo su ${USR} -s /bin/zsh -lc "$ins ${GAMING_APPS[*]}"
    fi

    # remove unprotected root privileges
    echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel_sudo
}

install_paru() {
    OG_DIR=$(pwd)
    cd /home/${USR}

    # clone the repo
    sudo -u ${USR} git clone https://aur.archlinux.org/paru-bin.git paru
    cd paru

    # make the package
    sudo -u ${USR} makepkg -si --noconfirm

    # clean up
    cd ..
    rm -rf paru
    cd $OG_DIR
}

detect_drivers(){
    GPU=$(lspci | grep VGA | cut -d " " -f 5-)

    if [[ "${GPU}" == *"NVIDIA"* ]]; then
        GPU_DRIVERS+=('nvidia' 'nvidia-utils' 'lib32-nvidia-utils')
    elif [[ "${GPU}" == *"AMD"* ]]; then
        GPU_DRIVERS+=('mesa' 'lib32-mesa' 'mesa-vdpau' 'lib32-mesa-vdpau'\
            'xf86-video-amdgpu' 'vulkan-radeon' 'lib32-vulkan-radeon'\
            'libva-mesa-driver' 'lib32-libva-mesa-driver')
    elif [[ "${GPU}" == *"Intel"* ]]; then
        GPU_DRIVERS+=('mesa' 'lib32-mesa' 'vulkan-intel')
    fi
}

install_dotfiles() {

    if [ $DOTFILES == "Yes" ]; then
        install_dotfiles
    else
        return
    fi

    # add some scripts for cronie
    mkdir -p /etc/cron.daily/
    cat <<- EOL > /etc/cron.daily/updatedb.sh
		# update mlocate database
		updatedb
	EOL

    cat <<- EOL > /etc/cron.daily/clean_cache.sh
		# clean old cache
		find /home/**/.cache -mtime +7 -exec rm -f {} \;
		find /root/.cache -mtime +7 -exec rm -f {} \;
	EOL

    chmod +x /etc/cron.daily/{updatedb.sh,clean_cache.sh}

    # this creates the default profiles for firefox
    # it's needed to have a directory to drop some configs
    sudo su ${USR} -s /bin/zsh -lc "timeout 1s firefox --headless"

    # git clone https://github.com/adityastomar67/.dotfiles ${USR_HOME}/.dotfiles
    # chmod +x ${USR_HOME}/.dotfiles/install.sh
    # chown -R ${USR}:${USR} ${USR_HOME}
    # sudo -u ${USR} ${USR_HOME}/.dotfiles/install.sh --noconfirm

    echo "Which dotfiles would you like to install?: [a/B]"
    read -rp "a. gh0stzk  b. adityastomar67" res
    echo ""
    if [[ $res == "a" ]]; then
        curl https://raw.githubusercontent.com/adityastomar67/dots/master/Installer -o $HOME/gh0stzkRice
        chmod +x gh0stzkRice
        ./gh0stzkRice
    else
        curl -sL https://bit.ly/Fresh-Install | sh -s -- --dots
    fi
}

##--> SERVICES <--##
enable_services() {
    for service in ${SERVICES[*]}
    do
        systemctl enable $service
    done
}

##--> OTHERS <--##
header() {

    clear
    printf "%${COLUMNS}s\n" "█████╗ ██████╗  █████╗ ██╗  ██╗      ██╗    ██████╗██╗  ██╗"
    printf "%${COLUMNS}s\n" "██╔══██╗██╔══██╗██╔══██╗██║  ██║      ██║   ██╔════╝██║  ██║"
    printf "%${COLUMNS}s\n" "███████║██████╔╝██║  ╚═╝███████║█████╗██║   ╚█████╗ ███████║"
    printf "%${COLUMNS}s\n" "██╔══██║██╔══██╗██║  ██╗██╔══██║╚════╝██║    ╚═══██╗██╔══██║"
    printf "%${COLUMNS}s\n" "██║  ██║██║  ██║╚█████╔╝██║  ██║      ██║██╗██████╔╝██║  ██║"
    printf "%${COLUMNS}s\n" "╚═╝  ╚═╝╚═╝  ╚═╝ ╚════╝ ╚═╝  ╚═╝      ╚═╝╚═╝╚═════╝ ╚═╝  ╚═╝"
    printf "%${COLUMNS}s\n" "█▄▄ █▄█   ▄▄   ▄▀█ █▀▄ █ ▀█▀ █▄█ ▄▀█ █▀ ▀█▀ █▀█ █▀▄▀█ ▄▀█ █▀█ █▄▄ ▀▀█"
    printf "%${COLUMNS}s\n" "█▄█  █         █▀█ █▄▀ █  █   █  █▀█ ▄█  █  █▄█ █ ▀ █ █▀█ █▀▄ █▄█   █"
}
