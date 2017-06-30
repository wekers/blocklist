# blocklist
_ _ _
###### Get bad ip's list from blocklist.de, uceprotect.net, binarydefense, firehol, danger.rulez.sk put them on Firewall and keep robots, bruteforces, etc, so far away..

_ _ _

- - -
- - -
- - -

##### The List:
- the download is for what type of bad ips? The ips try get access the following ports or services:

	- 21
	- 22
	- 23
	- 25
	- 80
	- 110
	- 143
	- 443
	- 993
	- apache
	- asterisk
	- bots
	- bruteforcelogin
	- courierimap
	- courierpop3
	- dnsbl
	- email
	- ftp
	- imap
	- ircbot
	- pop3
	- submission
	- postfix
	- sip
	- ssh


### ====Usage:====

##### Automatic blocklist on Firewall:



Create:
- a table `<blocklist>` on your "**pf.conf**"


```bash
table <blocklist> persist file "/var/db/blocklist"
```
- a rule to block
- ie: assume ext_if="em0"


```bash
block drop in log quick on $ext_if from <blocklist> to any

```

if you want not block 'maybe' a some legitimate email and sender notified "why was rejected" by your mail system
change rule to:

```bash
block drop in log quick on $ext_if proto tcp from <blocklist> to any port != smtp
block drop in log quick on $ext_if proto { udp, icmp } from <blocklist> to any

```



First run script manually, if all will be ok
Then Add on crontab to run
ie: every 2 hours

```bash
#minute (0-59)
#|	   hour (0-23)
#|      |       day of the month (1-31)
#|      |       |       month of the year (1-12 or Jan-Dec)
#|      |       |       |       day of the week (0-6 with 0=Sun or Sun-Sat)
#|      |       |       |       |       who
#|      |       |       |       |       |       commands
#|      |       |       |       |       |       |
00      */2     *       *       *       root    /usr/local/sbin/blocklist > /dev/null 2>&1

#to execute script on startup
@reboot root    /usr/local/sbin/blocklist > /dev/null 2>&1
```
- - -
- - -
- - -

- - -

- - -
##### Check if get all:

"**`pfctl -t blocklist -T show | wc -l`**"
- - -
- - -
- - -
- - -
- - -


* * *

* Tools:
	+ FreeBSD/OpenBSD
	+ Wget

 - **doesn't work on bash**

* * *
- - -
- - -

[^]: The **.csh** extension in file it is not necessary, has placed only for github detect correct syntax highlighting language on source
