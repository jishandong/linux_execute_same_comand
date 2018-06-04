使用remote.sh和remotecopy.sh脚本之前，需要在linux上面建信任关系

1.sshkeygen_as5u2_64下面的脚本建信任关系
（1）按照文件下的iplist.txt，编写IP地址列表以及用户名密码，格式一定要正确
（2）上传脚本至第一台zxve主机的root目录，执行chmod -R 777 赋予可执行权限（注意不要安装在cgsl管理机上）
（3）执行./create-keygen.sh -i iplist.txt

iplist.txt
168.168.23.25;root;cgsl123

168.168.23.26;root;cgsl123


2.建立好信任关系，就可以使用remote脚本了,all_iplist按照示例填入你需要批量处理的服务器的IP地址即可
remotecopy.sh用法
./remotecopy.sh -f all_iplist /root/XXX  /etc/xxx  将本机上/root/XXX 拷贝至all_iplist的所有主机的/etc/目录

remote.sh用法
./remore.sh -f all_iplist -c "multipath -ll"   所有all_iplist的主机执行multipath -ll并显示结果


all_iplist
168.168.23.4
168.168.23.5
168.168.23.6
168.168.23.7
168.168.23.8
168.168.23.9
168.168.23.10


3.fixnetwork目录下是自动bond脚本和自动修改主机名脚本
针对cgsl主机
./autobond.sh -t 0 3 168.168.23.1 255.255.255.0 168.168.23.253   bond0
./autobond.sh -b 0 3 168.168.23.1 255.255.255.0 168.168.23.253   bond0+br0 

针对zxve主机
./autotrunk.sh -t 0 3 168.168.23.1 255.255.255.0 168.168.23.253  trunk0
./autotrunk.sh -b 0 3 168.168.23.1 255.255.255.0 168.168.23.253  trunk0+br0

批量修改主机名
./name-host.sh -f hostlist.txt

hostlist.txt
168.168.23.25;HNYD-OSS-ZXVE22

168.168.23.26;HNYD-OSS-ZXVE23