#!/bin/bash

## CREATE HOST LIST
endIndex=$((`terraform output -raw numStudents`))
echo > attacks/web
echo > attacks/db

echo "[web]" >> attacks/web
for i in `seq 1 $endIndex`
do
    ip=`terraform output -json ip_addresses | jq .web[$i-1] | tr -d '"'`
    echo "web$i ansible_host=$ip" >> attacks/web
done

echo "[db]" >> attacks/db
for i in `seq 1 $endIndex`
do
    ip=`terraform output -json ip_addresses | jq .db[$i-1] | tr -d '"'`
    echo "db$i ansible_host=$ip" >> attacks/db
done

echo "
[web:vars]
ansible_connection=ssh" >> attacks/web

echo "
[db:vars]
ansible_python_interpreter=C:\Program Files\Python312\python" >> attacks/db

## CREATE EMPTY INVENTORY
cat attacks/web > attacks/web_redteam_password
cat attacks/web > attacks/web_redteam_key
cat attacks/web > attacks/web_plinko_password
cat attacks/web > attacks/web_plinko_key
cat attacks/db > attacks/db_plinko_winrm
cat attacks/db > attacks/db_redteam_winrm

## SET WEB VARIABLES
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

## SET DB VARIABLES
echo "
ansible_connection=winrm
ansible_user=plinko
ansible_password=Plink0P@ssw0rd
ansible_winrm_scheme=http
ansible_winrm_port=5985
ansible_winrm_transport=ntlm
ansible_winrm_server_cert_validation=ignore
" >> attacks/db_plinko_winrm
echo "
ansible_connection=winrm
ansible_user=redteam
ansible_password=Plink0P@ssw0rd
ansible_winrm_scheme=http
ansible_winrm_port=5985
ansible_winrm_transport=ntlm
ansible_winrm_server_cert_validation=ignore
" >> attacks/db_redteam_winrm
rm attacks/db
