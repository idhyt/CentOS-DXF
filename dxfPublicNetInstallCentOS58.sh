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
    cur_ip=`curl -s --connect-timeout 3 http://members.3322.org/dyndns/getip`
    if [ -z $cur_ip ]; then
    cur_ip=`curl -s --connect-timeout 3 http://ifconfig.me`
    fi

    echo -n "$cur_ip 是否是你的外网IP？(如果不是你的外网IP或者出现两条IP地址，请回 n 自行输入) y/n [n] ?"
    read ans
    case $ans in
    y|Y|yes|Yes)
    ;;
    n|N|no|No)
    read -p "输入你的外网IP地址，回车（确保是英文字符的点号）：" myip
    $cur_ip=$myip
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
    cd ./dxf_server

    echo "同步/home环境..."
    rsync -avz --progress ./home /

    echo "同步/lib环境..."
    cp -rf ./lib/libGeoIP.so.1 /lib
    chmod 755 /lib/libGeoIP.so.1
    cp -rf ./lib/libnxencryption.so /lib
    chmod 755 /lib/libnxencryption.so

    echo "同步数据库..."
    tar -xzvf mysql.tar.gz
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
    wget -O ./dxf_server.tar.gz https://github.com/idhyt/CentOS-DXF/blob/master/dxf/dxf_server.tar.gz?raw=true
}


function install() {
    echo "Install only test for CentOS5.8(rpm -qi centos-release: centos-release-5-8.el5.centos.src.rpm)"

    getIP

    downloadDXF

    installSupportLibOnCentOS5

    addSwap

    installDOF

    mysqlFlush

    removeTemp
}

install

echo "IP = ${cur_ip}, install success..."
echo "重启的话需要使用命令 service iptables stop 重新关闭防火墙"
echo "PVF和publickey.pem请自行上传"
echo "\n"

