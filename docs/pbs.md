# PBS automation plan

Deze configuratie gebruikt een x86_64 VM `pbs01` (`10.0.1.20`) in de Proxmox
cluster als Proxmox Backup Server. `tumuric` blijft alleen q-device, omdat de
officiele Proxmox Backup Server packages geen ARM-doelplatform zijn. De NAS
(`10.0.1.11`) blijft alleen storage-backend. De PBS datastore krijgt een eigen
NFS export, los van media, ISO's en gewone Proxmox NFS storage.

Dit document is geen permanent handmatig runbook. PBS moet volgens de vaste
repo-workflow worden opgezet:

1. OpenTofu maakt de VM `pbs01` en koppelt cloud-init.
2. Cloud-init maakt de VM bereikbaar.
3. Ansible configureert PBS, NFS, datastore, jobs, users en ACL's.
4. OpenTofu koppelt PBS als storage in Proxmox VE zodra het endpoint en de
   credentials bestaan.

## PBS host

Doel-VM die door OpenTofu moet worden aangemaakt:

| Instelling | Waarde |
| --- | --- |
| Naam | `pbs01` |
| IP | `10.0.1.20` |
| Platform | x86_64 VM |
| OS disk | Lokale Proxmox storage, niet de PBS NAS export |
| CPU | 2 vCPU |
| RAM | 4 GiB |
| Boot start | Enabled |

Deze VM hoort door OpenTofu te worden aangemaakt. Installeer PBS niet handmatig
als blijvende werkwijze.

## NAS export

Maak op de NAS een aparte gedeelde map/export. Dit is voorlopig day-0 totdat de
NAS-configuratie zelf geautomatiseerd wordt:

| Instelling | Waarde |
| --- | --- |
| Share/export | `/volume1/pbs` |
| Protocol | NFS |
| Toegang | Alleen `10.0.1.20` |
| Rechten | Read/write |
| Squash | No mapping / no root squash |
| Security | `sys` |
| Sync | Enabled, geen async |
| Subtree check | Disabled indien beschikbaar |
| Allowed clients | Geen wildcard, geen volledig subnet |

Gebruik geen bestaande media-share voor PBS. PBS maakt zeer veel chunk-bestanden
aan en heeft eigen retentie, garbage collection en verificatie nodig.

Voor Synology komt dit ongeveer overeen met:

- Shared Folder: `pbs`
- NFS Permissions:
  - Hostname or IP: `10.0.1.20`
  - Privilege: `Read/Write`
  - Squash: `No mapping`
  - Security: `sys`
  - Enable asynchronous: uit
  - Allow connections from non-privileged ports: uit
  - Allow users to access mounted subfolders: uit, tenzij je submounts gebruikt

## OpenTofu verantwoordelijkheden

OpenTofu moet uiteindelijk beheren:

- VM `pbs01` op een Proxmox node.
- VMID/naam/IP volgens `docs/ipam.md`.
- Cloud-init user-data en network config.
- Boot order, autostart, CPU, memory en OS disk.
- Eventueel een Proxmox storage resource `pbs_pbs01` nadat PBS klaar is.

## cloud-init verantwoordelijkheden

Cloud-init moet alleen de eerste boot doen:

- hostname `pbs01`
- statisch IP `10.0.1.20`
- SSH key/user voor Ansible
- basispackages voor remote beheer

## Ansible verantwoordelijkheden

Ansible moet idempotent beheren wat hieronder nu als doelconfiguratie staat.
De role-skeleton staat in `ansible/roles/pbs`.

### Mount op `pbs01`

Gewenste state:

| Onderdeel | State |
| --- | --- |
| Package | `nfs-common` installed |
| Mountpoint | `/mnt/pbs` directory exists |
| NFS export | `10.0.1.11:/volume1/pbs` mounted |
| Persistence | mount present in `/etc/fstab` |
| Write check | Ansible validation task succeeds |

Gewenste NFSv4 mount:

```fstab
10.0.1.11:/volume1/pbs /mnt/pbs nfs4 rw,hard,noatime,nconnect=4,_netdev,x-systemd.automount,x-systemd.requires=network-online.target 0 0
```

Fallback als de NAS geen NFSv4 exporteert:

```fstab
10.0.1.11:/volume1/pbs /mnt/pbs nfs rw,vers=3,hard,noatime,nconnect=4,_netdev,x-systemd.automount,x-systemd.requires=network-online.target 0 0
```

### Datastore

Gewenste state:

| Onderdeel | State |
| --- | --- |
| Directory | `/mnt/pbs/pbs-main`, owner `backup:backup`, mode `0750` |
| Datastore | `pbs-main` exists at `/mnt/pbs/pbs-main` |
| Prune schedule | `daily 03:00` |
| Retention | 14 daily, 8 weekly, 12 monthly, 2 yearly |
| GC schedule | `sun 04:00` |
| Verify new chunks | job `pbs-main-new`, `daily 05:00`, ignore already verified |
| Verify full | job `pbs-main-full`, monthly, verify all |

Implementatie hoort in Ansible. Waar PBS geen declaratieve module heeft, gebruikt
de role CLI-commando's met `changed_when` en voorafgaande read/check taken zodat
opnieuw draaien idempotent blijft.

### PBS access

Gewenste state:

| Onderdeel | State |
| --- | --- |
| User | `pve-backup@pbs` exists |
| Token | `pve-backup@pbs!pve` exists |
| Backup ACL | `DatastoreBackup` on `/datastore/pbs-main` |
| Restore ACL | `DatastoreReader` only when restore via this token is intended |

Token secrets mogen niet in git. Kies voor dit onderdeel nog een secret workflow:
Ansible Vault, SOPS, 1Password CLI of een andere lokale secret backend.

## Proxmox VE storage

OpenTofu moet uiteindelijk de Proxmox storage `pbs_pbs01` beheren:

| Instelling | Waarde |
| --- | --- |
| Type | Proxmox Backup Server |
| Storage ID | `pbs_pbs01` |
| Server | `10.0.1.20` |
| Datastore | `pbs-main` |
| Username | `pve-backup@pbs!pve` |
| Content | `backup` |

De PBS certificaat-fingerprint en token secret komen uit de geautomatiseerde
PBS-configuratie of uit de gekozen secret workflow, niet uit handmatige copy/paste
als eindtoestand.

Backup jobs horen later ook declaratief beheerd te worden:

| Instelling | Waarde |
| --- | --- |
| Storage | `pbs_pbs01` |
| Mode | Snapshot |
| Schedule | Dagelijks na je drukste gebruiksuren, bijvoorbeeld `02:00` |
| Selection | Eerst kritieke VM's/LXC's, daarna de rest |
| Compression | Zstd |
| Retention | Op PBS datastore, niet dubbel in elke job |

## Validatie

Validatie hoort als Makefile target, Ansible check of later CI-stap:

- PBS API bereikbaar op `https://10.0.1.20:8007`.
- Datastore `pbs-main` bestaat.
- NFS mount is actief en beschrijfbaar.
- Garbage collection status is opvraagbaar.
- Verify job bestaat.
- Proxmox VE ziet storage `pbs_pbs01`.
- Een restore naar tijdelijk VMID/CTID is getest.

## Operationele afspraken

- Houd `/volume1/pbs` exclusief voor PBS.
- Laat de NAS snapshots maken van `/volume1/pbs` als extra rollback-laag, maar
  behandel die niet als vervanging voor PBS verificatie.
- Monitor vrije ruimte op de NAS en in PBS; plan uitbreiding voordat de datastore
  boven ongeveer 80 procent vol raakt.
- Houd minstens een tweede kopie buiten deze NAS aan voor echt belangrijke data,
  bijvoorbeeld via PBS sync naar externe storage.
- Laat NAS disk-scrubbing en SMART-tests buiten de PBS backup-window draaien.
