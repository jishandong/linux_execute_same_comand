ʹ��remote.sh��remotecopy.sh�ű�֮ǰ����Ҫ��linux���潨���ι�ϵ

1.sshkeygen_as5u2_64����Ľű������ι�ϵ
��1�������ļ��µ�iplist.txt����дIP��ַ�б��Լ��û������룬��ʽһ��Ҫ��ȷ
��2���ϴ��ű�����һ̨zxve������rootĿ¼��ִ��chmod -R 777 �����ִ��Ȩ�ޣ�ע�ⲻҪ��װ��cgsl������ϣ�
��3��ִ��./create-keygen.sh -i iplist.txt

iplist.txt
168.168.23.25;root;cgsl123

168.168.23.26;root;cgsl123


2.���������ι�ϵ���Ϳ���ʹ��remote�ű���,all_iplist����ʾ����������Ҫ��������ķ�������IP��ַ����
remotecopy.sh�÷�
./remotecopy.sh -f all_iplist /root/XXX  /etc/xxx  ��������/root/XXX ������all_iplist������������/etc/Ŀ¼

remote.sh�÷�
./remore.sh -f all_iplist -c "multipath -ll"   ����all_iplist������ִ��multipath -ll����ʾ���


all_iplist
168.168.23.4
168.168.23.5
168.168.23.6
168.168.23.7
168.168.23.8
168.168.23.9
168.168.23.10


3.fixnetworkĿ¼�����Զ�bond�ű����Զ��޸��������ű�
���cgsl����
./autobond.sh -t 0 3 168.168.23.1 255.255.255.0 168.168.23.253   bond0
./autobond.sh -b 0 3 168.168.23.1 255.255.255.0 168.168.23.253   bond0+br0 

���zxve����
./autotrunk.sh -t 0 3 168.168.23.1 255.255.255.0 168.168.23.253  trunk0
./autotrunk.sh -b 0 3 168.168.23.1 255.255.255.0 168.168.23.253  trunk0+br0

�����޸�������
./name-host.sh -f hostlist.txt

hostlist.txt
168.168.23.25;HNYD-OSS-ZXVE22

168.168.23.26;HNYD-OSS-ZXVE23