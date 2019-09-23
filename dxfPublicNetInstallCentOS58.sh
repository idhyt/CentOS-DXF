#!/bin/sh

#  installDOFCentOS.sh
#  
#
#  Created by idhyt. 
#  For testing only, do not use for illegal purpose!!! 
#
#

default_ip="192.168.200.213"
cur_ip="0.0.0.0"
cur_dir=`pwd`

function getIP() {
    echo "获取IP..."
    # cur_ip=`curl -s --connect-timeout 3 http://members.3322.org/dyndns/getip`
        cur_ip=`wget http://members.3322.org/dyndns/getip -q -O -`
    if [ -z $cur_ip ]; then
    # cur_ip=`curl -s --connect-timeout 3 http://ifconfig.me`
        cur_ip=`wget http://ifconfig.me -q -O -`
    fi

    echo -n "$cur_ip 是否是你的外网IP？(如果不是你的外网IP或者出现两条IP地址，请回 n 自行输入) y/n [n] ?"
    read ans
    case $ans in
    y|Y|yes|Yes)
    ;;
    n|N|no|No)
    read -p "输入你的外网IP地址，回车（确保是英文字符的点号）：" myip
    cur_ip=$myip
    ;;
    *)
    ;;
    esac
    echo "当前IP: $cur_ip"
}

function installSupportLibOnCentOS5() {
    echo "安装运行库..."

    wget --no-check-certificate -O /etc/yum.repos.d/CentOS-Base.repo https://raw.githubusercontent.com/idhyt/CentOS-DXF/master/CentOS-Base.repo/CentOS-Base.repo.5.8
    yum clean all
    yum makecache

    yum -y update
    yum -y upgrade
    yum -y install mysql-server
    yum -y install gcc gcc-c++ make zlib-devel libc.so.6 libstdc++ glibc.i686

    chkconfig mysqld on
    service mysqld start
    service mysqld enable
}

function addSwap() {
    echo "添加Swap交换空间8G，耐心等待……"
    /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=8000
    mkswap /var/swap.1
    swapon /var/swap.1
    sed -i '$a /var/swap.1 swap swap default 0 0' /etc/fstab
    echo "添加Swap成功"
}

function mysqlFlush() {
    HOSTNAME="127.0.0.1"
    PORT="3306"
    USERNAME="game"
    PASSWORD="uu5!^%jg"
    DBNAME="mysql"
    TABLENAME="user"
    refresh="flush privileges;";
    delete_user_root6686="delete from mysql.user where user='root9326686' and host='%';"
    #  delete_user_cash="delete from mysql.user where user='cash' and host='127.0.0.1';"
    mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "${delete_user_root6686}"
    #  mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "${delete_user_cash}"
    grant_all_priv="GRANT ALL PRIVILEGES ON *.* TO 'game'@'%' IDENTIFIED BY 'uu5!^%jg' WITH GRANT OPTION;"
    mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "${grant_all_priv}"

    mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "${refresh}"

}

function removeTemp() {
    echo -n -t 5 "完成安装，是否删除临时文件 y/n [n] ?"
    read ANS
    case $ANS in
    y|Y|yes|Yes)
    rm -rf $cur_dir/dxf_server.tar.gz
    rm -rf $cur_dir/mysql.tar.gz
    ;;
    n|N|no|No)
    ;;
    *)
    ;;
    esac
}

function installDOF() {
    echo "解压安装包..."
    tar -xzvf dxf_server.tar.gz
    tar -xzvf mysql.tar.gz

    echo "同步/home环境..."
    rsync -avz --progress ./dxf_server/home /

    echo "同步/lib环境..."
    cp -rf ./dxf_server/lib/libGeoIP.so.1 /lib
    chmod 755 /lib/libGeoIP.so.1
    cp -rf ./dxf_server/lib/libnxencryption.so /lib
    chmod 755 /lib/libnxencryption.so

    echo "同步数据库..."
    chown -R mysql:mysql mysql
    rsync -avz --progress ./mysql /var/lib
    service mysqld restart

    echo "安装so库..."
    cd /home/GeoIP-1.4.8
    make clean && ./configure
    make && make check && make install

    # echo "安装PVF..."
    # cp ./df_game_r /home/neople/game/
    # cp ./Script.pvf /home/neople/game/
    # cp ./publickey.pem /home/neople/game/

    echo "替换IP: ${default_ip} -> ${cur_ip}"
    cd /home/neople/
    sed -i "s/${default_ip}/${cur_ip}/g" `find . -type f -name "*.tbl"`
    sed -i "s/${default_ip}/${cur_ip}/g" `find . -type f -name "*.cfg"`

    echo "设置防火墙..."
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 8000 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 10013 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 30303 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 30403 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 10315 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 30603 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 20203 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 7215 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 20303 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 40401 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 30803 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 20403 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 31100 -j ACCEPT' /etc/sysconfig/iptables
    service iptables stop
}

function downloadDXF() {
    echo "下载安装包..."
    wget -O ./dxf_server.tar.gz http://pxlyjtrp1.bkt.clouddn.com/dxf_server.tar.gz

    echo "下载数据库..."
    wget -O ./mysql.tar.gz http://pxlyjtrp1.bkt.clouddn.com/mysql.tar.gz
}


function exists() {
    command -v "$1" >/dev/null 2>&1
}


function checkCmd() {
    # if exists curl; then
    #     echo 'curl exists!'
    # else
    #     echo 'Your system does not have curl, abort!'
    #     exit
    # fi

    if exists wget; then
        echo 'wget exists!'
    else
        echo 'Your system does not have wget, abort!'
        exit
    fi

}


function install() {
    checkCmd

    downloadDXF

    getIP

    installSupportLibOnCentOS5

    addSwap

    installDOF

    mysqlFlush

    removeTemp
}

echo -e -n "\033[31m 仅供测试, 请勿用于非法用途!!! 是否同意 y/n [n] ?\033[0m"
read ans
case $ans in
n|N|no|No)
exit
;;
y|Y|yes|Yes)
;;
*)
exit
;;
esac

echo -e "\033[33m Install only test for CentOS5.8(rpm -qi centos-release: centos-release-5-8.el5.centos.src.rpm) \033[0m"
echo -e "\033[33m Make sure 'wget' already installed! \033[0m"
sleep 2

install

echo -e "\033[33m IP = ${cur_ip}, install success... \033[0m"
echo -e "\033[33m PVF和publickey.pem请自行上传 \033[0m"
echo -e "\033[33m 重启的话需要使用命令 service iptables stop 重新关闭防火墙 \033[0m"
