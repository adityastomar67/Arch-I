#!/bin/zsh
# adityastomar67's Arch installation script

##--> Fetch Scripts <--##
if ! [ -f definitions.sh ]; then
    curl -LO "https://raw.githubusercontent.com/adityastomar67/Arch-I/master/definitions.sh"
fi

if ! [ -f packages.sh ]; then
    curl -LO "https://raw.githubusercontent.com/adityastomar67/Arch-I/master/packages.sh"
fi

source definitions.sh
source packages.sh

##--> Calling functions <--##
header
setup_variables
configure_pacman
update_keyring
partition_and_mount
install_base

cat packages.sh vars.sh definitions.sh > /mnt/definitions.sh

##--> All the following will be ran inside the chroot <--##
cat << EOF | arch-chroot /mnt
source definitions.sh
configure_pacman
setup_network
prepare_system
setup_users
prepare_gui
install_applications
enable_services
install_dotfiles
exit
EOF

##--> Clean Up <--##
rm -fv /mnt/definitions.sh
umount -R /mnt
reboot