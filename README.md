### Warn

**dxf public net install for centos5.8**

**For testing only, do not use for illegal purpose!!!**


### Install

SSH to your server, Make sure 'wget' already installed!

```
cd ~

bash <(wget --timeout=10 https://raw.githubusercontent.com/idhyt/CentOS-DXF/master/dxfPublicNetInstallCentOS58.sh -q -O - )
```

upload you `pvf` and `publickey.pem`, run `/home/run`

```
...
GeoIP Allow Country Code : CN
GeoIP Allow Country Code : HK
GeoIP Allow Country Code : KR
GeoIP Allow Country Code : MO
GeoIP Allow Country Code : TW
[!] Connect To Monitor Server ...
[!] Connect To Guild Server ...
[!] Connect To Monitor Server ...
[!] Connect To Guild Server ...

```


### Issue

If have any problems, please create [issue](https://github.com/idhyt/CentOS-DXF/issues) with your install logs.

#### Degrade CentOS5.8x64

```
yum install -y xz openssl gawk coreutils file
wget https://db.ci/os/CentOSNET.sh && chmod a+x CentOSNET.sh
bash CentOSNET.sh -c 5.8 -v 64 -a --mirror 'http://archive.kernel.org/centos-vault'
```
Your can see the installation progress by VNC (ip:5901)

After install, default user/password: root/Vicer
