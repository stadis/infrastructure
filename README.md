<div align="center">
<h1>Stadis Infrastructure<br>
</h1></div>

Shell Scripts to Setup Server.

Requirements
* existing user stadisadm
* secrets (.env) and backup password (interactive)

**Application Server (stadis-app)**
```bash
git clone https://github.com/stadis/infrastructure.git && cd infrastructure/src
nano .env # set secrets
bash appserver.sh .env [sync] # should be root user when running this
```
