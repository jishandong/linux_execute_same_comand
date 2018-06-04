#########################
# !/usr/local/bin/bash
# by: zhu_shixiang
# at: 2012.11.10
# in: suzhou
#########################
checkexpect()
{
   bStatus=`find /usr/bin/ -name "expect"`
   if [ -z "$bStatus" ]; then
      bStatus=`find /usr/sbin/ -name "expect"`
      if [ -z "$bStatus" ]; then
         rpm -ivh expect-5.42.1-1.x86_64.rpm
      fi
   fi
}
keygen()
{
   expect keygen.exp
   for host in `cat $2`
   do
      ipv4=`echo $host | cut -d ";" -f 1`
      login=`echo $host | cut -d ";" -f 2`
      passwd=`echo $host | cut -d ";" -f 3`
      expect batch.exp -i $ipv4 -u $login -p $passwd -cp /root/.ssh/id_rsa.pub -s /tmp/
      expect batch.exp -i $ipv4 -u $login -p $passwd -c "mkdir -p /root/.ssh/; cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys; rm -rf /tmp/id_rsa.pub"
   done
}
case "$1" in
   -i)
      checkexpect
      keygen "$1" "$2"
      ;;
    *)
      echo -e "\033[35mexample: ./create-keygen.sh -i iplist.txt\033[0m"
      printf "\n"
      echo -e "\033[31mthe iplist.txt format is as follows:\033[0m"
      echo -e "\033[32m192.168.1.10;root;123456\033[0m"
      echo -e "\033[32m192.168.1.11;root;123456\033[0m"
      echo -e "\033[32m192.168.1.12;root;123456\033[0m"
      echo -e "\033[32m... ...\033[0m"
      printf "\n\n"
esac

