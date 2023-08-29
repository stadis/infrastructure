<div align="center">
<h1>Stadis Infrastructure<br>
</h1></div>

Shell Scripts to Setup Server.

Requirements
* Existing user stadisadm
* Secrets and Passwords

```bash
git clone https://github.com/stadis/infrastructure.git && cd infrastructure/src
nano .env # set secrets
bash appserver.sh .env [sync] # should be root user when running this
```
