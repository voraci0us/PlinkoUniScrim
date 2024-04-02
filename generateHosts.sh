#!/bin/bash
endIndex=$((`terraform output -raw numStudents`-1))
echo > inventory # clear out old inventory file


ip=`terraform output -json scorestackip | tr -d '"'`
echo "[scorestack]" >> inventory
echo "scorestack ansible_host=$ip" >> inventory

echo "[db]" >> inventory
for i in `seq 0 $endIndex`
do
    ip=`terraform output -json ip_addresses | jq .db[$i] | tr -d '"'`
    echo "db$i ansible_host=$ip" >> inventory
done

echo "[web]" >> inventory
for i in `seq 0 $endIndex`
do
    ip=`terraform output -json ip_addresses | jq .web[$i] | tr -d '"'`
    echo "web$i ansible_host=$ip" >> inventory
done

echo "
[linux:children]
web
scorestack
" >> inventory

echo "
[linux:vars]
ansible_connection=ssh
ansible_user=plinko
ansible_ssh_private_key_file=./terraform_key

[db:vars]
ansible_connection=winrm
ansible_user=plinko
ansible_password=Plink0P@ssw0rd
ansible_winrm_scheme=http
ansible_winrm_port=5985
ansible_winrm_transport=ntlm
ansible_winrm_server_cert_validation=ignore
ansible_python_interpreter=C:\Program Files\Python312\python
" >> inventory
cat inventory | grep ansible_host | sed s/ansible_host=//g | awk '{print $2" "$1}' > hosts
