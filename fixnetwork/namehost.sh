#########################
# !/usr/local/bin/bash
# by: wang_wentao
# at: 2014.03.05
# in: changsha
#########################

namehost()
{
   for host in `cat $2`
   do
      ipv4=`echo "$host" |awk -F";" '{print $1}'`
      echo "$ipv4"
      hostName=`echo $host |awk -F ";" '{print $2}'`
      echo "$hostName"
      ForbidIP="127.0.0.1" 
      if test "$ipv4" == "$ForbidIP" ;then
      echo "You must not use 127.0.0.1 as name service ip;Please use ip such as 192.168.1.1  "
      else      
      ssh $ipv4 "sed -i 's/HOSTNAME=.*/HOSTNAME=$hostName/g' /etc/sysconfig/network;hostname $hostName"
      ssh $ipv4 "sed -i '/$ipv4/'d /etc/hosts;sed -i '/$hostName/'d /etc/hosts;echo "$ipv4" "$hostName">>/etc/hosts"
      fi
      done
}
case "$1" in
   -f)
      namehost "$1" "$2"
      ;;
    *)
      echo -e "\033[35mexample: ./name-host.sh -f hostlist.txt\033[0m"
      printf "\n"
      echo -e "\033[31mthe hostlist.txt format is as follows:\033[0m"
      echo -e "\033[32m192.168.1.10;HNYD-OSS-ZXVE1\033[0m"
      echo -e "\033[32m192.168.1.11;HNYD-OSS-ZXVE2\033[0m"
      echo -e "\033[32m192.168.1.12;HNYD-OSS-ZXVE3\033[0m"
      echo -e "\033[32m... ...\033[0m"
      printf "\n\n"
esac
