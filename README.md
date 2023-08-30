<div align="center">
<h1>Stadis Infrastructure<br>
</h1></div>

Shell Scripts to setup Server.

Requirements
* existing user stadisadm
* secrets (.env) and backup password (interactive)

## Application Server (stadis-app)
Ubuntu 22.04.3 LTS @AMD EPYC™ 7702 (4 Cores), 8 GB DDR4 RAM (ECC), 160 GB SSD
```bash
git clone https://github.com/stadis/infrastructure.git && cd infrastructure/src
nano .env # set secrets
bash appserver.sh .env [sync] # should be root user when running this
```

## Main Server (stadis-main) (tbd)
 @AMD Ryzen™ 5 3600 (6 Cores), 64 GB DDR4 RAM, 2 x 512 GB NVMe SSD (software-RAID 1)

