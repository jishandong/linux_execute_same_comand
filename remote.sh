#! /bin/sh

bgexec=0


while getopts f:bc:o: OPT; do
        case $OPT in
                f|+f)
                        files="$OPTARG $files"
                        ;;
                b|+b)
                        bgexec=1;
                        ;;
        c|+c)
            command="$OPTARG"
            ;;
        o|+)
            output="$OPTARG"
            ;;

                *)
                        echo "usage: `basename $0` [-f hostfile] [-b] [-h] [-c cmd] [-o outputfile]"
                        exit 2
        esac
done

shift `expr $OPTIND - 1`

if [ "" = "$command" -o "" = "$files" ] ;then
        echo "usage: `basename $0` [-f hostfile] [-b] [-h] [-c cmd] [-o outputfile]"
    exit
fi

for file in $files
  do
  if [ ! -f "$file" ] ;then
        echo "no hostlist file:$file"
        exit
  fi
  hosts="$hosts `cat $file|grep -v '#'`"


done

if [ $bgexec -eq 1 ] ; then
        echo "execute remote shell forced in backgroud ...."
        sshparam=" -f "
else
        sshparam=""
fi


if [ "" = "$output" ] ;then
        logs="2>&1"
else
        logs="2>&1>${output}"
fi


for host in $hosts; do
        echo "do $host"
#       echo "$host"
#       echo "ssh $sshparam $host  $command $logs"
        #ssh $sshparam $host  $command $logs
        ssh $sshparam $host  "REMOTEHOST=$host ; $command" $logs
done

