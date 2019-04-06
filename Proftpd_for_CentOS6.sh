#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script!"
    exit 1
fi
clear
echo "+----------------------------------------------------------+"
echo "|Author:jingyihome                                         |"
echo "+----------------------------------------------------------+"
echo "|E-mail:webmaster@zhanghaijun.com                          |"
echo "+----------------------------------------------------------+"
echo "|Website:http://www.zhanghaijun.com                        |"
echo "+----------------------------------------------------------+"
echo "|Usage: ./proftpd.sh or ./proftpd.sh install|uninstall     |"
echo "+----------------------------------------------------------+"
cur_dir=$(pwd)

Proftpd_Ver='proftpd-1.3.6rc2'
installdir="/usr/local/proftpd"

Install_Proftpd()
{
    echo -e "\033[32m Installing dependent packages... \033[0m"
      yum -y install make gcc gcc-c++ gcc-g77 openssl openssl-devel wget

    echo -e "\033[32m Download files... \033[0m"
    cd ${cur_dir}/
    wget --no-check-certificate https://soft.loveyan.com/ftp/proftpd/${Proftpd_Ver}.tar.gz ${cur_dir}/${Proftpd_Ver}.tar.gz
    if [ $? -eq 0 ]; then
        echo "Download ${Proftpd_Ver}.tar.gz successfully!"
    else
        wget ftp://ftp.proftpd.org/distrib/source/${Proftpd_Ver}.tar.gz ${cur_dir}/${Proftpd_Ver}.tar.gz
    fi

    echo -e "\033[32m Installing proftpd... \033[0m"
    tar xzvf ${Proftpd_Ver}.tar.gz ${Proftpd_Ver}
    cd ${Proftpd_Ver}
    ./configure --prefix=${installdir}

    make && make install

    cd ${cur_dir}/
    echo -e "\033[32m Create configure files... \033[0m"
    mv ${installdir}/etc/proftpd.conf ${installdir}/etc/bak_proftpd.conf
    wget --no-check-certificate https://soft.loveyan.com/ftp/proftpd/proftpd.conf
    if [ $? -eq 0 ]; then
         sed -i "s#/usr/local/ftp/proftpd#${installdir}#g" ${cur_dir}/proftpd.conf
         mv ${cur_dir}/proftpd.conf ${installdir}/etc/
    else
        echo -e "\033[31m Download proftpd.conf failed! \033[0m"
        exit 1
    fi

    if [ -L /etc/init.d/proftpd ]; then
        rm -f /etc/init.d/proftpd
    fi

    wget --no-check-certificate https://soft.loveyan.com/ftp/proftpd/proftpdinit
    if [ $? -eq 0 ]; then
         sed -i "s#/usr/local/ftp/proftpd#${installdir}#g" ${cur_dir}/proftpdinit
         mv ${cur_dir}/proftpdinit /etc/init.d/proftpd
         chmod +x /etc/init.d/proftpd
         touch ${installdir}/etc/ftpd.passwd
         chmod 600 ${installdir}/etc/ftpd.passwd
    else
        echo -e "\033[31m Download proftpdinit failed! \033[0m"
        exit 1
    fi

    rm -rf ${cur_dir}/${Proftpd_Ver}

    if [ -s /sbin/iptables ]; then
       /sbin/iptables -I INPUT -p tcp --dport 20 -j ACCEPT
       /sbin/iptables -I INPUT -p tcp --dport 21 -j ACCEPT
       /sbin/iptables -I INPUT -p tcp --dport 50000:53000 -j ACCEPT
    else
       echo -e "\033[32m iptables was not installed! \033[0m"
    fi

    service iptables save

    if [[ -s ${installdir}/sbin/proftpd && -s ${installdir}/etc/proftpd.conf && -s /etc/init.d/proftpd ]]; then
        echo "Starting proftpd..."
        /etc/init.d/proftpd start
        ln -s ${installdir}/bin/ftpasswd /bin/ftpasswd
        echo "+----------------------------------------------------------------------------------------------------------------------------+"
        echo "| Install ProFTPd completed,enjoy it!"
        echo "| =>use:ftpasswd --passwd --file=${installdir}/etc/ftpd.passwd --name=X --uid=X --gid=X --home=dir --shell=/bin/false"
        echo "+----------------------------------------------------------------------------------------------------------------------------+"
        echo "| For more information please visit http://www.zhanghaijun.com/post/975/"
        echo "+----------------------------------------------------------------------------------------------------------------------------+"
    else
        echo -e "\033[31m Proftpd install failed! \033[0m"
    fi
}

Uninstall_Proftpd()
{
    if [ ! -f $installdir/sbin/proftpd ]; then
        echo -e "\033[31m Proftpd was not installed! \033[0m"
        exit 1
    fi
    echo "Stop proftpd..."
    /etc/init.d/proftpd stop
    echo "Remove service..."
    rm -f /etc/init.d/proftpd
    echo "Delete files..."
    rm -rf ${installdir}
    rm -rf /bin/ftpasswd
    /sbin/iptables -D INPUT -p tcp --dport 20 -j ACCEPT
    /sbin/iptables -D INPUT -p tcp --dport 21 -j ACCEPT
    /sbin/iptables -D INPUT -p tcp --dport 50000:53000 -j ACCEPT
    service iptables save
    echo "Proftpd uninstall completed."
}

action=$1
[ -z $1 ] && action=install
case "$action" in
install)
    Install_Proftpd 2>&1 | tee /root/proftpd-install.log
    ;;
uninstall)
    Uninstall_Proftpd
    ;;
*)
    echo -e "\033[31m error! [${action}] \033[0m"
    echo -e "\033[32m Usage: `basename $0` {install|uninstall} \033[0m"
    ;;
esac