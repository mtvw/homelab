# Bootstrap

Deze stappen blijven expliciet buiten OpenTofu omdat er op dit punt nog geen
betrouwbare API, remote executor of beheerde host bestaat. Alles na deze day-0
grens hoort in OpenTofu, cloud-init, Ansible of idempotente scripts. Zie
[`automation.md`](automation.md).

## Proxmox cluster

De cluster lijkt al aangemaakt. Controleer dit op een Proxmox node:

```sh
pvecm status
```

Verwacht:

- cluster name: `homelab`
- nodes: `pepper`, `salt`
- quorum: yes

Daarna:

1. Maak een OpenTofu/API gebruiker en token aan.
2. Zet de token in `/Users/matthias/Dev/homelab/.env`.
3. Controleer API-toegang vanaf je werkstation met `make plan`.
4. Import bestaande resources die OpenTofu moet overnemen, zoals de enterprise
   APT repo entries, voordat je ze declaratief beheert.

## q-device op `tumuric`

1. Installeer en configureer `corosync-qnetd` op `tumuric`.
2. Voeg `tumuric` toe als q-device voor de Proxmox cluster.
3. Controleer quorumgedrag wanneer een van de twee Proxmox nodes offline is.

## PBS VM in de cluster

PBS draait niet op `tumuric`: die host is ARM en blijft alleen q-device.

De PBS VM zelf wordt niet handmatig opgezet. OpenTofu moet `pbs01` aanmaken,
cloud-init moet de VM bereikbaar maken en Ansible moet PBS configureren.

Day-0 blijft alleen:

1. Maak of bevestig de NAS export `/volume1/pbs`.
2. Geef alleen `pbs01` (`10.0.1.20`) read/write NFS-toegang.
3. Leg eventuele NAS-stappen vast totdat de NAS zelf ook geautomatiseerd wordt.

## OpenTofu bootstrap

1. Vul `environments/homelab/terraform.tfvars` lokaal in.
2. Vul `.env` lokaal in op basis van `.env.example`.
3. Run `make env-check`, `make init`, `make plan` en daarna pas `make apply`.
