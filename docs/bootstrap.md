# Bootstrap

Deze stappen blijven expliciet buiten OpenTofu omdat er op dit punt nog geen
betrouwbare API, remote executor of beheerde host bestaat. Alles na deze day-0
grens hoort in OpenTofu, cloud-init, Ansible of idempotente scripts. Zie
[`automation.md`](automation.md).

## Proxmox single-node

`pepper` is de enige actieve Proxmox VE node. Controleer dit op `pepper`:

```sh
pvecm status
```

Verwacht:

- cluster name: `homelab`
- nodes: `pepper`
- quorum: yes

Daarna:

1. Maak een OpenTofu/API gebruiker en token aan.
2. Zet de token in `/Users/matthias/Dev/homelab/.env`.
3. Controleer API-toegang vanaf je werkstation met `make plan`.
4. Import bestaande resources die OpenTofu moet overnemen, zoals de enterprise
   APT repo entries, voordat je ze declaratief beheert.

## Cold standby `salt`

`salt` is geen actieve Proxmox node meer en wordt niet door OpenTofu beheerd.
Bewaar hostname en IP als gereserveerd hersteldoel. Als `pepper` faalt:

1. Installeer Proxmox VE opnieuw op `salt`.
2. Configureer basisnetwerk zodat Proxmox bereikbaar is.
3. Maak een OpenTofu/API gebruiker en token aan of herstel die volgens
   [`authentication.md`](authentication.md).
4. Koppel PBS of herstel eerst `pbs01`, afhankelijk van welke backups nog
   beschikbaar zijn.
5. Restore kritieke VM's/LXC's uit PBS.

## PBS VM

De PBS VM zelf wordt niet handmatig opgezet. OpenTofu moet `pbs01` op `pepper`
aanmaken, cloud-init moet de VM bereikbaar maken en Ansible moet PBS
configureren.

Day-0 blijft alleen:

1. Maak of bevestig de NAS export `/volume1/pbs`.
2. Geef alleen `pbs01` (`10.0.1.20`) read/write NFS-toegang.
3. Leg eventuele NAS-stappen vast totdat de NAS zelf ook geautomatiseerd wordt.

## OpenTofu bootstrap

1. Vul `environments/homelab/terraform.tfvars` lokaal in.
2. Vul `.env` lokaal in op basis van `.env.example`.
3. Run `make env-check`, `make init`, `make plan` en daarna pas `make apply`.
