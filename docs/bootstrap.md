# Bootstrap

Deze stappen blijven voorlopig expliciet buiten OpenTofu omdat ze credentials,
cluster-join state of package-installatie op machines vereisen voordat de API
betrouwbaar declaratief te beheren is.

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

## PBS op `tumuric`

1. Installeer Proxmox Backup Server op Debian.
2. Maak datastore(s), gebruiker(s) en token(s) aan.
3. Beslis of PBS door Proxmox via OpenTofu als `storage_pbs` wordt toegevoegd.

## OpenTofu bootstrap

1. Vul `environments/homelab/terraform.tfvars` lokaal in.
2. Vul `.env` lokaal in op basis van `.env.example`.
3. Run `make env-check`, `make init`, `make plan` en daarna pas `make apply`.
