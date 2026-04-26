# PBS role

Deze role moet de PBS host idempotent configureren.

Gewenste verantwoordelijkheden:

- Proxmox Backup Server repository en package installeren.
- NFS client installeren.
- `/volume1/pbs` mounten op `/mnt/pbs`.
- Datastore-directory `/mnt/pbs/pbs-main` beheren.
- PBS datastore `pbs-main` aanmaken of updaten.
- Prune, garbage collection en verify jobs configureren.
- Dedicated PBS user/token/ACL's voor Proxmox VE beheren.
- Validatiecommando's uitvoeren of documenteren als check target.

Secrets zoals tokenwaarden horen niet in deze role als plain text. De role
schrijft de gegenereerde PBS token naar `.secrets/pbs_pve_token.json`, buiten
git.

## Variabelen

Standaardwaarden staan in `defaults/main.yml`. Environment-specifieke waarden
horen later in inventory, group vars of een secret backend.
