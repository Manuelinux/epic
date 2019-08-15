#!/bin/bash
user=panfilo
initialuser=manuel_aguirre@epam.com
getent passwd $user > /dev/null
if [ $? -eq 0 ]; then
	echo "The user exists"
else
	echo "The user does not exists... creating user $user as system user"
	useradd -r -m $user
fi
id $user| grep wheel > /dev/null
if [ $? -eq 0 ]; then
	echo "The user has sudo access"
else
	echo "Granting user $user sudo privileges"
	usermod -a -G wheel $user
	echo "Copying ssh-key"
	sudo cp -r /home/$initialuser/.ssh/authorized_keys /home/$user/.ssh/authorized_keys
	sudo chown $user:$user /home/$user/.ssh/authorized_keys
fi
echo "Disable root login on SSH"
grep '^PermitRootLogin no' /etc/ssh/sshd_config > /dev/null && echo "Root Login is already Disabled" || sed -i.bkp 's/.*PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
echo "Disable password authentication"
grep '^PasswordAuthentication no' /etc/ssh/sshd_config > /dev/null && echo "Authentication with password is already disabled" || sed -i.bkp 's/^PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
minlen=$(cat /etc/security/pwquality.conf | grep -e "minlen" | awk -F' ' '{print $3}')
maxday=$(cat /etc/login.defs | grep -e "^PASS_MAX_DAYS" | awk -F' ' '{print $2}')
 if [ "$minlen" -eq "8" ]
 then
       echo "Length is ok"
 else
       echo "Changing to 8"
       sed -i -e "s/minlen.*$/minlen = 8/g" /etc/security/pwquality.conf
 fi
 if [ "$maxday" -eq "90" ]
 then
       echo "Max Days is ok"
 else
       echo "Max Days is $maxday, changing to 90"
       sed -i -e "s/^PASS_MAX_DAYS.*$/PASS_MAX_DAYS\t90/g" /etc/login.defs
 fi
remset=$(cat /etc/pam.d/system-auth | grep -e "^password *sufficient *pam_unix.so *" | grep "remember=*")
if [ -z "$remset" ]
 then
 echo "Remember option is not configured in pam, configuring remember last 6 passwords..."
 sed -i "/^password *sufficient *pam_unix.so */ s/$/ remember=6/" /etc/pam.d/system-auth
 elif [ $(echo $remset | grep "remember" | cut -d= -f2) -eq "6" ]
 then
 echo "Remember password is ok"
 else
 echo "Password Remember is $(echo $remset | grep "remember" | cut -d= -f2), Changing to 6"
 sed -i "s/remember=$(echo $remset | grep "remember" | cut -d= -f2)/remember=6/g" /etc/pam.d/system-auth
 fi
systemctl restart sshd.service