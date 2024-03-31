# Plinko Uni 2024 Scrimmage Deployment

This is designed for an individual competition.
Each student will have two systems:
`web` - Ubuntu 22.04 with two scorechecks (WordPress and SSH)
`db` - Windows Server 2016 with one scorecheck (MySQL)

The WordPress check relies on the MySQL server running on `db`.

There are several red team preplants.
- Malicious user accounts
- Planted SSH keys
- Web shells

In the "red team" folder there are scripts to automatically check and exploit these.

This deployment also automatically stands up a ScoreStack deployment for scoring.

## Deployment
git clone 
terraform init
terraform apply
./generateHosts.sh
