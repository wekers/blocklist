#!/bin/csh -f

# -------------------------------------------------------------------
# File: blocklist                                        /\
# Type: C Shell Script                                  /_.\
# By Fernando Gilli fernando<at>wekers(dot)org    _,.-'/ `",\'-.,_
# Last modified:2016-06-15                     -~^    /______\`~~-^~:
# ------------------------
# Get list of all blacklisted ip's (ssh brutefroce, robot, etc
# from http://lists.blocklist.de & uceprotect level 2,
# them put on pf firewall
# / OS : $FreeBSD
# -------------------------------------------------------------------

set URL="http://lists.blocklist.de/lists/all.txt"
set URL2="http://wget-mirrors.uceprotect.net/rbldnsd-all/dnsbl-2.uceprotect.net.gz"

# Clean files
echo -n > /var/db/blocklist.tmp
echo -n > /var/db/blocklist2.tmp


#echo "Fazendo download da blacklist..."
echo "Downloading blacklist from blocklist.de ..."
/usr/local/bin/wget --no-verbose -O - $URL > /var/db/blocklist.tmp

if ($status == 0) then
        #echo "Download completo!"
        echo "Download complete!"
else

        @ again_URL= 1

again_URL:
        #echo "Erro no download, tentando novamente..."
        echo "Download error, try again..."
        /bin/sleep 10
        /usr/local/bin/wget --no-verbose -O - $URL > /var/db/blocklist.tmp

        if ($status != 0 && $again_URL < 3) then
                @ again_URL++
                /bin/sleep 5
                goto again_URL

        else if ($again_URL == 3 && -z /var/db/blocklist.tmp) then
                #echo "Falha nas 3 tentativas extras  de efetuar o download"
                echo "Failed on three extra attempts to get download"
                #echo "Nada a ser feito.."
                echo "Nothing to do.."
                #echo "Falha ao fazer download dos ips nas 3 tentativas extras de blocklist.de no arquivo /usr/local/sbin/blocklist" \
                #                                                                                  | mail -s "Script blocklist" root
                echo "Failure to try get download of ip's from blocklist.de on three extra attempts in file /usr/local/sbin/blocklist" \
                                                                                                    | mail -s "Script blocklist" root
                exit
        endif

endif

echo "Downloading blacklist from uceprotect.net ..."
/bin/sleep 5
/usr/local/bin/wget --no-verbose -O - $URL2 | /usr/bin/gunzip > /var/db/blocklist2.tmp

if ($status == 0) then
        echo "Download complete!"
else

        @ again_URL2 = 1

again_URL2:
        echo "Download error, try again..."
        /bin/sleep 10
        /usr/local/bin/wget --no-verbose -O - $URL2 | /usr/bin/gunzip > /var/db/blocklist2.tmp

        if ($status != 0 && $again_URL2 < 3) then
                @ again_URL2++
                /bin/sleep 12
                goto again_URL2

        else if ($again_URL2 == 3 && -z /var/db/blocklist2.tmp) then
                #echo "Falha nas 3 tentativas extras  de efetuar o download"
                echo "Failed on three extra attempts to get download"
                #echo "Nada a ser feito.."
                echo "Nothing to do.."
                #echo "Falha ao fazer download dos ips nas 3 tentativas extras de blocklist.de no arquivo /usr/local/sbin/blocklist" \
                #                                                                                  | mail -s "Script blocklist" root
                echo "Failure to try get download of ip's from uceprotect.net on three extra attempts in file /usr/local/sbin/blocklist" \
                                                                                                      | mail -s "Script blocklist" root
                exit
        endif

endif


# Adiciona ips singulares, evitando repetições
# add singular ips, avoid repetitions
/usr/bin/sort /var/db/blocklist.tmp | uniq > /var/db/blocklist

echo "join ips from uceprotect.net to blocklist file"
/bin/cat /var/db/blocklist2.tmp | sed '/^\!/ d;/^#/ d;/^$NS/ d;/^$SOA/ d;/^:/ d;/^127.0.0.2/ d' | awk '{print $1}' >> /var/db/blocklist

# Clean files
echo -n > /var/db/blocklist.tmp
echo -n > /var/db/blocklist2.tmp


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

