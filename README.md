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
