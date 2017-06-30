#!/bin/csh -f

# -------------------------------------------------------------------
# File: blocklist                                        /\
# Type: C Shell Script                                  /_.\
# By Fernando Gilli fernando<at>wekers(dot)org    _,.-'/ `",\'-.,_
# Last modified:2017-06-29                     -~^    /______\`~~-^~:
# ------------------------
# Get list of all blacklisted ip's (ssh brutefroce, robot, etc
# from http://lists.blocklist.de, uceprotect, etc and put them on pf firewall
# / OS : $FreeBSD
# -------------------------------------------------------------------

# for debug uncomment line below
#set nonomatch

set URL0="http://lists.blocklist.de/lists/all.txt"
set URL1="https://www.binarydefense.com/banlist.txt"
set URL2="http://wget-mirrors.uceprotect.net/rbldnsd-all/dnsbl-2.uceprotect.net.gz"
set URL3="https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level3.netset"
set URL4="https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/bruteforceblocker.ipset"

# Clean files
echo -n > /var/db/blocklist0.tmp
echo -n > /var/db/blocklist1.tmp
echo -n > /var/db/blocklist2.tmp
echo -n > /var/db/blocklist3.tmp
echo -n > /var/db/blocklist4.tmp
echo -n > /var/db/blocklist.tmp


# ***** URL0 ***************************************************************************************************
#echo "Fazendo download da blacklist da blocklist.de..."
echo "Downloading blacklist from blocklist.de..."
/usr/local/bin/wget --no-verbose -O - $URL0 > /var/db/blocklist0.tmp

if ($status == 0) then
        #echo "Download completo!"
        echo "Download complete!"
else

        @ again_URL0 = 1

again_URL0:
        #echo "Erro no download, tentando novamente..."
        echo "Download error, try again..."
        /bin/sleep 10
        /usr/local/bin/wget --no-verbose -O - $URL0 > /var/db/blocklist0.tmp

        if ($status != 0 && $again_URL0 < 3) then
        @ again_URL0++
        /bin/sleep 5
        goto again_URL0

        else if ( $again_URL0 == 3 && -z /var/db/blocklist0.tmp) then
                #echo "Falha nas 3 tentativas extras de efetuar o download"
                echo "Failed on three extra attempts to get download"
                #echo "Nada a ser feito, para essa blacklist.."
                echo "Nothing to do.."
                #echo "Falha ao fazer download dos ips nas 3 tentativas extras $URL0 no arquivo /usr/local/sbin/blocklist" \
                #                                                                                                 | mail -s "Script blocklist" root
                echo "Failure to try get download of ip's from $URL0 on three extra attempts in file /usr/local/sbin/blocklist" \
														 | mail -s "Script blocklist" root
        endif

endif
# **************************************************************************************************************


# ***** URL1 ***************************************************************************************************
#echo "Fazendo download da blacklist da binarydefense.com..."
echo "Downloading blacklist from binarydefense.com..."
/bin/sleep 5
/usr/local/bin/wget --no-verbose -O - $URL1 > /var/db/blocklist1.tmp

if ($status == 0) then
        #echo "Download completo!"
        echo "Download complete!"
else

        @ again_URL1 = 1

again_URL1:
        #echo "Erro no download, tentando novamente..."
        echo "Download error, try again..."
        /bin/sleep 10
        /usr/local/bin/wget --no-verbose -O - $URL1 > /var/db/blocklist1.tmp

        if ($status != 0 && $again_URL1 < 3) then
        @ again_URL1++
        /bin/sleep 12
        goto again_URL1

        else if ($again_URL1 == 3 && -z /var/db/blocklist1.tmp) then
                #echo "Falha nas 3 tentativas extras de efetuar o download"
                echo "Failed on three extra attempts to get download"
                #echo "Nada a ser feito.."
                echo "Nothing to do.."
                #echo "Falha ao fazer download dos ips nas 3 tentivas extras da $URL1 \
                #                                                no arquivo /usr/local/sbin/blocklist" \
                #                                                | mail -s "Script blocklist" root
                echo "Failure to try get download of ip's from $URL1 on three extra attempts in file /usr/local/sbin/blocklist" \
								| mail -s "Script blocklist" root
                
        endif

endif
# **************************************************************************************************************


# ***** URL2 ***************************************************************************************************
echo "Fazendo download da blacklist da uceprotect.net level 2..."
echo "Downloading blacklist from uceprotect.net level 2..."
/bin/sleep 5
/usr/local/bin/wget --no-verbose -O - $URL2 | /usr/bin/gunzip > /var/db/blocklist2.tmp

if ($status == 0) then
        #echo "Download completo!"
        echo "Download complete!"
else

        @ again_URL2 = 1

again_URL2:
        #echo "Erro no download, tentando novamente..."
        echo "Download error, try again..."
        /bin/sleep 10
        /usr/local/bin/wget --no-verbose -O - $URL2 | /usr/bin/gunzip > /var/db/blocklist2.tmp

        if ($status != 0 && $again_URL2 < 3) then
        @ again_URL2++
         /bin/sleep 12
        goto again_URL2

        else if ($again_URL2 == 3 && -z /var/db/blocklist2.tmp) then
                #echo "Falha nas 3 tentativas extras de efetuar o download"
                echo "Failed on three extra attempts to get download"
                #echo "Nada a ser feito, para essa blacklist.."
                echo "Nothing to do.."
                #echo "Falha ao fazer download dos ips nas 3 tentivas extras da $URL2 \
                #                                                no arquivo /usr/local/sbin/blocklist" \
                #                                                | mail -s "Script blocklist" root
                echo "Failure to try get download of ip's from $URL2 on three extra attempts in file /usr/local/sbin/blocklist" \
                                                                | mail -s "Script blocklist" root
                
        endif

endif
# **************************************************************************************************************


# ***** URL3 ***************************************************************************************************
#echo "Fazendo download da blacklist da firehol_level3..."
echo "Downloading blacklist from firehol_level3..."

/usr/local/bin/wget --no-verbose -O - $URL3 > /var/db/blocklist3.tmp

if ($status == 0) then
        #echo "Download completo!"
        echo "Download complete!"
else
        @ again_URL3 = 1

again_URL3:
        #echo "Erro no download, tentando novamente..."
        echo "Download error, try again..."
        /bin/sleep 10
        /usr/local/bin/wget --no-verbose -O - $URL3 > /var/db/blocklist3.tmp

        if ($status != 0 && $again_URL3 < 3) then
        @ again_URL3++
        /bin/sleep 12
        goto again_URL3

        else if ($again_URL3 == 3 && -z /var/db/blocklist3.tmp) then
                #echo "Falha nas 3 tentativas extras de efetuar o download"
                echo "Failed on three extra attempts to get download"
                #echo "Nada a ser feito, para essa blacklist.."
                echo "Nothing to do.."
                #echo "Falha ao fazer download dos ips nas 3 tentivas extras da $URL3 no arquivo /usr/local/sbin/blocklist" \
                #                                                   
                echo "Failure to try get download of ip's from $URL3 on three extra attempts in file /usr/local/sbin/blocklist" \
								  | mail -s "Script blocklist" root
        endif

endif
# **************************************************************************************************************


# ***** URL4 ***************************************************************************************************
#echo "Fazendo download da blacklist da danger.rulez.sk bruteforceblocker..."
echo "Downloading blacklist from danger.rulez.sk bruteforceblocker..."

/usr/local/bin/wget --no-verbose -O - $URL4 > /var/db/blocklist4.tmp

if ($status == 0) then
        #echo "Download completo!"
        echo "Download complete!"
else
        @ again_URL4 = 1

again_URL4:
        #echo "Erro no download, tentando novamente..."
        echo "Download error, try again..."
        /bin/sleep 10
        /usr/local/bin/wget --no-verbose -O - $URL4 > /var/db/blocklist4.tmp


        if ($status != 0 && $again_URL4 < 3) then
        @ again_URL4++
        /bin/sleep 5
        goto again_URL4

        else if ( $again_URL4 == 3 && -z /var/db/blocklist4.tmp) then
                #echo "Falha nas 3 tentativas extras de efetuar o download"
                echo "Failed on three extra attempts to get download"
                #echo "Nada a ser feito, para essa blacklist.."
                echo "Nothing to do.."
                #echo "Falha ao fazer download dos ips nas 3 tentativas extras da $URL4 no arquivo /usr/local/sbin/blocklist" \
                echo "Failure to try get download of ip's from $URL4 on three extra attempts in file /usr/local/sbin/blocklist" \
                                                                                                 | mail -s "Script blocklist" root
        endif

endif
# **************************************************************************************************************


# Adiciona ips singulares, evitando repetições
# add singular ips, avoid repetitions
echo "join ips from blocklist.de to blocklist file"
/usr/bin/sort /var/db/blocklist0.tmp | uniq > /var/db/blocklist.tmp

echo "join ips from binarydefense.com to blocklist file"
/bin/cat /var/db/blocklist1.tmp | sed '/^#/ d' >> /var/db/blocklist.tmp

echo "join ips from uceprotect.net level 2 to blocklist file"
/bin/cat /var/db/blocklist2.tmp | sed '/^\!/ d;/^#/ d;/^$NS/ d;/^$SOA/ d;/^:/ d;/^127.0.0.2/ d' | awk '{print $1}' >> /var/db/blocklist.tmp

echo "join ips from firehol_level3 to blocklist file"
/usr/bin/sort /var/db/blocklist3.tmp | sed '/^#/ d' >> /var/db/blocklist.tmp

echo "join ips from danger.rulez.sk bruteforceblocker to blocklist file"
/bin/cat /var/db/blocklist4.tmp | sed '/^#/ d' >> /var/db/blocklist.tmp


# add only uniq ips
echo "Applying filter for keep only uniq ips"
/usr/bin/sort /var/db/blocklist.tmp | uniq > /var/db/blocklist



# Clean file
echo -n > /var/db/blocklist0.tmp
echo -n > /var/db/blocklist1.tmp
echo -n > /var/db/blocklist2.tmp
echo -n > /var/db/blocklist3.tmp
echo -n > /var/db/blocklist4.tmp
echo -n > /var/db/blocklist.tmp

set ips=`/bin/cat /var/db/blocklist | wc -l`

#echo "Efetuando update na tabela <blocklist> do firewall"
echo "Doing update on <blocklist> table of firewall"

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

