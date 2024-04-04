#!/bin/bash

## CREATE HOST LIST
endIndex=$((`terraform output -raw numStudents`))
echo > attacks/web

echo "[web]" >> attacks/web
for i in `seq 1 $endIndex`
do
    ip=`terraform output -json ip_addresses | jq .web[$i-1] | tr -d '"'`
    echo "web$i ansible_host=$ip" >> attacks/web
done

echo "
[web:vars]
ansible_connection=ssh" >> attacks/web

## CREATE EMPTY INVENTORY
cat attacks/web > attacks/web_redteam_password
cat attacks/web > attacks/web_redteam_key
cat attacks/web > attacks/web_plinko_password
cat attacks/web > attacks/web_plinko_key

## SET VARIABLES
echo "
ansible_user=redteam
ansible_ssh_password=Plink0P@ssw0rd
" >> attacks/web_redteam_password
echo "
ansible_user=redteam
ansible_ssh_private_key_file=../redteam
" >> attacks/web_redteam_key
echo "
ansible_user=plinko
ansible_ssh_password=Plink0P@ssw0rd
" >> attacks/web_plinko_password
echo "
ansible_user=plinko
ansible_ssh_private_key_file=../redteam
" >> attacks/web_plinko_key

rm attacks/web