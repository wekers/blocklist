#!/bin/csh -f

# -------------------------------------------------------------------
# File: blocklist                                        /\
# Type: C Shell Script                                  /_.\
# By Fernando Gilli fernando<at>wekers(dot)org    _,.-'/ `",\'-.,_
# Last modified:2016-05-20                     -~^    /______\`~~-^~:
# ------------------------
# Get list of all blacklisted ip's (ssh brutefroce, robot, etc
# from http://lists.blocklist.de and put them on pf firewall
# / OS : $FreeBSD
# -------------------------------------------------------------------

set URL="http://lists.blocklist.de/lists/all.txt"

#echo "Fazendo download da blacklist..."
echo "Downloading blacklist..."
/usr/local/bin/wget --no-verbose -O - $URL > /var/db/blocklist.tmp

if ($status == 0) then
        #echo "Download completo!"
        echo "Download complete!"
else
        #echo "Erro no download, tentando novamente..."
        echo "Download error, try again..."
        /usr/local/bin/wget --no-verbose -O - $URL > /var/db/blocklist.tmp

        if ($status != 0) then
                #echo "Falha na segunda tentativa de efetuar o download"
                echo "Fail on the second attempt to try get download"
                #echo "Nada a ser feito.."
                echo "Nothing to do.."
                #echo "Falha ao fazer download dos ips no arquivo /usr/local/sbin/blocklist" | mail -s "Script blocklist" root
                echo "Fail to try get download of ip's on file /usr/local/sbin/blocklist" | mail -s "Script blocklist" root
                exit
        endif

endif

# Adiciona ips singulares, evitando repetições
# add singular ips, avoid repetitions
/usr/bin/sort /var/db/blocklist.tmp | uniq > /var/db/blocklist

set ips=`/bin/cat /var/db/blocklist | wc -l`

#echo "Efetuando update na tabela <blocklist> do firewall"
echo "Do update on <blocklist> table of firewall"

set table=`/sbin/pfctl -s Tables | grep blocklist | wc -l`
if ($table == 0) then
        #printf "\033[1;31mFalha!\033[0m Não existe nenhuma tabela <blocklist> no seu pf.conf\n"
        printf "\033[1;31mFail!\033[0m Have no one <blocklist> table on your pf.conf\n"
        #echo "Nada a ser feito, saindo.."
        echo "Nothing to do, leaving.."
        exit 0
endif

/sbin/pfctl -q -t blocklist -T replace -f /var/db/blocklist

printf "\033[1;32mUpdate \033[1;34m[ \033[1;32mOK \033[1;34m]\033[0m\n"
#printf "Total de \033[1;31m$ips \033[0mips adicionados\n"
printf "Total of \033[1;31m$ips \033[0mips added\n"
exit 0

#EOF

