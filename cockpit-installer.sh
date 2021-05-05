#!/bin/bash
# Tested on CentOS 7, CentOS 8, Ubuntu 18.04, Ubuntu 20.04, Fedora 32, Fedora 33, Fedora 34, Debian 9, Debian 10
# Some ISP block outgoing port 9090, change to 19090
function which_distro()
{
    case "$( grep -Eoi 'Debian|SUSE|Ubuntu' /etc/issue )" in
        "SUSE")
            echo "SUSE"
            ;;
        "Ubuntu")
            echo "Ubuntu"
            ;;
        "Debian")
            echo "Debian"
            ;;
    esac

    redhat_release_file=/etc/redhat-release
    if [ -e "$redhat_release_file" ]; then
        case "$( grep -Eoi 'CentOS' $redhat_release_file )" in "CentOS")
            echo "CentOS"
            ;;
        esac
        case "$( grep -Eoi 'Fedora' $redhat_release_file )" in "Fedora")
            echo "Fedora"
            ;;
        esac
    fi
}

case "$(which_distro)" in
    "Ubuntu")
        apt-get update
        apt-get install -y cockpit
        sed -i 's/^ListenStream=9090/ListenStream=19090/g' /lib/systemd/system/cockpit.socket
        firewall-cmd --add-port=19090
        firewall-cmd --permanent --add-port=19090
        systemctl daemon-reload
        systemctl enable --now cockpit.socket
        systemctl restart cockpit.socket
        ;;
    "Debian")
        if [ ! -f /etc/apt/sources.list.d/backports.list ]; then
            CODENAME=$(dpkg --status tzdata|grep Provides|cut -f2 -d'-')
            echo "deb http://deb.debian.org/debian ${CODENAME}-backports main" > /etc/apt/sources.list.d/backports.list
        fi
        apt-get update
        apt-get install -y cockpit
        sed -i 's/^ListenStream=9090/ListenStream=19090/g' /lib/systemd/system/cockpit.socket
        firewall-cmd --add-port=19090
        firewall-cmd --permanent --add-port=19090
        systemctl daemon-reload
        systemctl enable --now cockpit.socket
        systemctl restart cockpit.socket
        ;;
    "CentOS")
        yum install -y cockpit
        sed -i 's/^ListenStream=9090/ListenStream=19090/g' /lib/systemd/system/cockpit.socket
        semanage port -a -t websm_port_t -p tcp 19090
        semanage port -a -t websm_port_t -p udp 19090
        firewall-cmd --add-port=19090
        firewall-cmd --permanent --add-port=19090
        systemctl daemon-reload
        systemctl enable --now cockpit.socket
        systemctl restart cockpit.socket
        ;;
    "Fedora")
        dnf install -y cockpit policycoreutils-python-utils
        sed -i 's/^ListenStream=9090/ListenStream=19090/g' /lib/systemd/system/cockpit.socket
        semanage port -a -t websm_port_t -p tcp 19090
        semanage port -a -t websm_port_t -p udp 19090
        firewall-cmd --add-port=19090
        firewall-cmd --permanent --add-port=19090
        systemctl daemon-reload
        systemctl enable --now cockpit.socket
        systemctl restart cockpit.socket
        ;;
esac
