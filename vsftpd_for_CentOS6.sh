#!/bin/bash

Install_Vsftpd()
{
    yum install -y db4* vsftpd
    yum install -y psmisc net-tools systemd-devel libdb-devel perl-DBI
    service vsftpd start
    chkconfig vsftpd on
    sed -i "s/anonymous_enable=YES/anonymous_enable=NO/g" '/etc/vsftpd/vsftpd.conf'
    sed -i "s/#anon_upload_enable=YES/anon_upload_enable=NO/g" '/etc/vsftpd/vsftpd.conf'
    sed -i "s/#anon_mkdir_write_enable=YES/anon_mkdir_write_enable=YES/g" '/etc/vsftpd/vsftpd.conf'
    sed -i "s/#chown_uploads=YES/chown_uploads=NO/g" '/etc/vsftpd/vsftpd.conf'
    sed -i "s/#async_abor_enable=YES/async_abor_enable=YES/g" '/etc/vsftpd/vsftpd.conf'
    sed -i "s/#ascii_upload_enable=YES/ascii_upload_enable=YES/g" '/etc/vsftpd/vsftpd.conf'
    sed -i "s/#ascii_download_enable=YES/ascii_download_enable=YES/g" '/etc/vsftpd/vsftpd.conf'
    sed -i "s/#ftpd_banner=Welcome to blah FTP service./ftpd_banner=Welcome to FTP service./g" '/etc/vsftpd/vsftpd.conf'
    echo -e "use_localtime=YES\nlisten_port=21\nchroot_local_user=YES\nidle_session_timeout=300\ndata_connection_timeout=1\nguest_enable=YES\nguest_username=www\nuser_config_dir=/etc/vsftpd/vconf\nvirtual_use_local_privs=YES\npasv_min_port=10045\npasv_max_port=10090\naccept_timeout=5\nconnect_timeout=1" >> /etc/vsftpd/vsftpd.conf
    touch /etc/vsftpd/virtusers
    db_load -T -t hash -f /etc/vsftpd/virtusers /etc/vsftpd/virtusers.db
    chmod 600 /etc/vsftpd/virtusers.db
    sed -i '1i\auth sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/virtusers\naccount sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/virtusers' /etc/pam.d/vsftpd
    mkdir  /etc/vsftpd/vconf
    service vsftpd restart
}

Vsftp_Ftp_User_Add()
{
    echo -n "Are you sure you want to add FTP users?(Y/N)"
    read ANS
    case $ANS in
    y|Y|yes|Yes)
    echo -e "Please enter your ftp name:"
    read name
    echo -e "Please enter your ftp home dir:"
    read ftphome
    echo -e "Please enter you ftp password:"
    read ftppasswd
    echo -e "$name\n$ftppasswd" >> /etc/vsftpd/virtusers
    db_load -T -t hash -f /etc/vsftpd/virtusers /etc/vsftpd/virtusers.db
    chmod 600 /etc/vsftpd/virtusers.db
    echo -e "local_root=${ftphome}\nwrite_enable=YES\nanon_world_readable_only=NO\nanon_upload_enable=YES\nanon_mkdir_write_enable=YES\nanon_other_write_enable=YES" >> /etc/vsftpd/vconf/$name

    service vsftpd restart

    echo "Your FTP username:$name"
    echo "FTP login password:$ftppasswd"
    echo "FTP home dir:$ftphome"
    echo "FTP port number:21"
;;
n|N|no|No)
    #exit 0
echo "Exit ..."
;;
esac
}

# Add
action=$1
[ -z $1 ] && action=tishi
case "$action" in
install)
    Install_Vsftpd
    ;;
add)
    Vsftp_Ftp_User_Add
    ;;
tishi)
    echo "Usage: `basename $0` {install|add}"
    ;;
*)
    echo "error! [${action}]"
    echo "Usage: `basename $0` {install|add}"
    ;;
esac