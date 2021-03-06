#!/bin/bash

# Install ansible 
echo "Installing packages - vim-enhanced,ansible,git,cockpit, cockpit-machines,freeipa,bind,bind-chroot." 
dnf -yq install ansible git cockpit cockpit-machines freeipa-* bind bind-chroot
echo
echo "Adding variables into bash_profile and vimrc..."
echo
echo "alias vi=vim" >>  ~/.bash_profile
echo "alias asc='ansible-playbook --syntax-check'" >>  ~/.bash_profile
echo "alias ad=ansible-doc" >>  ~/.bash_profile
echo "autocmd FileType yaml setlocal ai ts=2 sw=2 et" >> ~/.vimrc
echo
source ~/.bash_profile
source ~/.vimrc
echo "done"
echo
echo " starting NTPD" 
echo
systemctl -q start ntpd
systemctl enable ntpd
echo

echo "Adding params for nested Virtualization.." 
cat << EOF > /etc/modprobe.d/kvm_intel.conf
options kvm-intel nested=1
options kvm-intel enable_shadow_vmcs=1
options kvm-intel enable_apicv=1
options kvm-intel ept=1
EOF

echo
echo " Disable Rev path filtering. ensure packets that are not routable to be dropped" 

cat << EOF > /etc/sysctl.d/98-rp-filter.conf
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.all.rp_filter = 0
EOF

echo
echo "Start and Enable Cockpit."
systemctl enable cockpit.socket
systemctl -q start cockpit.socket


echo "Setting up Git repo"
git clone https://github.com/devenshan/virt_ocp.git

echo "Finished."
