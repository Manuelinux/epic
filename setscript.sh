#!/bin/bash
initialuser=manuel_aguirre@epam.com
host=10.6.193.0
user=panfilo
test -e ~/.ssh/id_rsa
if [ $? -eq 0 ]; then
echo "Key already exists"
else
echo "Generating ssh-key"
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa -q
fi
ssh-copy-id -i ~/.ssh/id_rsa.pub $initialuser"@"$host
scp usrchk.sh $initialuser"@"$host:/home/$initialuser/
ssh -t -l $initialuser $host "chmod a+x usrchk.sh && sudo sh usrchk.sh"
