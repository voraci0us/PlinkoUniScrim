# Plinko Uni 2024 Scrimmage Deployment

This is designed for an individual competition.
Each student will have two systems: \
`webX` - Ubuntu 22.04 with two scorechecks (WordPress and SSH) \
`dbX` - Windows Server 2022 with two scorechecks (MySQL and SSH)

The WordPress check relies on the MySQL server running on `dbX`.

There are several red team preplants. Refer to the "Red Team Guide" section of this doc.

This deployment also automatically stands up a ScoreStack deployment for scoring.

## Deployment
```
git clone 
terraform init
terraform apply -auto-approve
./generateHosts.sh
```
At this point you may need to wait a bit for Windows hosts to come up, Linux will come up faster. \
From the same directory, run:
```
ansible-playbook web/web.yml
ansible-playbook scorestack/main.yml
ansible-playbook db/db.yml
```
Finally, start the checks:
```
ansible-playbook scorestack/configure.yml
```
This playbook will hang indefinitely, kill it to stop scorechecks from running.
You can access ScoreStack in the web browser, `https://<scorestack-ip>:5601`.

## Blue Team Packet

You have two systems: \
`webX` - Ubuntu 22.04 with two scorechecks (WordPress and SSH) \
`dbX` - Windows Server 2022 with two scorechecks (MySQL and SSH)

### Access 
The default password for all system accounts is `Plink0P@ssw0rd`. The administrator account `plinko` can be used to RDP into `dbX` and SSH into `webX`. These credentials will also work for logging into the WordPress dashboard (`/wp-login.php`). 

The default database credential is `wordpress:wordpress`. This is how your WordPress site on `webX` is connecting to your MySQL database on `dbX`.

### Scoring
You can access ScoreStack in the web browser, `https://<scorestack-ip>:5601`, to see in more details about scorechecks. Click the hamburger menu in the top left -> `scorestack` to change passwords for scorechecks. Each check is weighted equally.

You have console access via OpenStack. Do with that what you will.

## Red Team Packet
Each student will have two systems, where X is their "team number": \
`webX` - Ubuntu 22.04 with two scorechecks (WordPress and SSH) \
`dbX` - Windows Server 2022 with two scorechecks (MySQL and SSH)

### Default Creds
Check the `web/web.yml` and `db/db.yml` for the full list of system user accounts, they all have the password `Plink0P@ssw0rd` by default.

MySQL database default account is `wordpress:wordpress`, and WordPress dashbaord default account is `plinko:Plink0P@ssw0rd`.

### SSH Keys
All user accounts on `dbX` are in the Administrator group and have the `redteam.pub` SSH key planted (`C:\ProgramData\ssh\administrators_authorized_keys`). \
Some user accounts on `webX` have the `redteam.pub` SSH key planted in `~/.ssh/authorized_keys`) - reference the `key_users` list in `web/web.yml`.
### Webshells
The WordPress sites have two webshells (`/shell.php` and `wp-execute.php`). Since passwordless sudo is set, you can `sudo` commands in here.



