#!/bin/bash

#get IP
echo 'Enter the target IP: '
read IP 

#get wordlist
echo 'Enter wordlist: '
read wordlist

#run nmap
echo 'Running nmap scan on: '$IP
nmap -p 21,80,445 -Pn -n --disable-arp-ping $IP > nmap.txt
#check if port 80 is open
if grep -q '80/tcp' nmap.txt; then
	echo 'Port 80 is open. Running Nikto and Whatweb...'
	#run nikto on port 80
	nikto -h "http://$IP" > nikto.txt
	whatweb "http://$IP" >> nikto.txt
	
	#Test directory brute force
	echo 'Testing directory brute force on port 80...'
	dirb "http://$IP/" $wordlist -r > dirb.txt
else 
	echo 'Port 80 is closed.'
fi

#check if port 21 is open
if grep -q '21/tcp' nmap.txt; then
	echo 'Port 21 is open. Testing for anonymous FTP access ...'
	ftp -n "http://$IP" <<END_SCRIPT > ftp.txt
quote USER anonymous
quote PASS anonymous
quit
END_SCRIPT
else
	echo 'Port 21 is closed.'
fi

#check if port 445 is open
if grep -q '445/tcp' nmap.txt; then
	echo 'Port 445 is open. Testing for anonymous guest SMB access ...'
	smbclient -L "http://$IP" -N > smb.txt
else
	echo 'Port 445 is closed.'
fi

#Display results
echo
echo '---- Results ----'
echo 'Nmap Scan Results'
cat nmap.txt

if [[ -s nikto.txt ]]; then
	echo 'Nikto and Whatweb Result'
	cat nikto.txt
else 
	echo 'file doesnt exist'
fi

if [[ -s dirb.txt ]]; then
	echo 'Directory Brute Force Result'
	cat dirb.txt
fi

if [[ -s ftp.txt ]]; then
	echo 'FTP Result'
	cat ftp.txt
fi

if [[ -s smb.txt ]]; then
	echo 'SMB Result'
	cat smb.txt	
fi



