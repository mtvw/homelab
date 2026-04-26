# Automation model

Deze repo is een automatiseringsrepo. Het doel is dat de homelab vanuit git
opnieuw opgebouwd kan worden met zo weinig mogelijk handwerk. Runbooks zijn
alleen tijdelijk toegestaan wanneer ze direct worden omgezet naar OpenTofu,
cloud-init, Ansible of idempotente scripts.

## Vaste workflow

Gebruik standaard deze lagen:

| Laag | Tool | Verantwoordelijkheid |
| --- | --- | --- |
| Day-0 bootstrap | Documentatie en kleine scripts | Zaken die nog geen API of remote executor hebben |
| Infra | OpenTofu | Proxmox resources, VM's, LXC's, storage, pools, firewall, cloud-init koppeling |
| Eerste boot | cloud-init | Hostname, netwerk, SSH, basispackages, bootstrap user |
| OS/serviceconfig | Ansible | Packages, configbestanden, mounts, services, gebruikers, idempotente CLI-acties |
| Apps | Ansible, Compose of later Kubernetes | Applicaties en workloads bovenop de hosts |

OpenTofu maakt machines en Proxmox-resources. Cloud-init maakt een nieuwe host
bereikbaar. Ansible configureert daarna de inhoud van de host. Vermijd
Terraform provisioners voor normale OS-configuratie; die zijn moeilijk opnieuw
betrouwbaar te draaien.

VM's en LXC's horen dus altijd in de OpenTofu-laag. Ansible mag ervan uitgaan
dat de host bestaat en bereikbaar is. Zie `docs/workloads.md`.

## Day-0 grens

Alleen deze zaken mogen handmatig blijven, tenzij we later expliciet automation
toevoegen:

- Proxmox VE basisinstallatie op fysieke nodes.
- Initiële Proxmox cluster creation/join.
- Initiële q-device join voor `tumuric`.
- Basisnetwerk, gateway en DNS waarop de Proxmox API bereikbaar wordt.
- NAS basisconfiguratie en exports waarvoor nog geen beheerde API-integratie in
  deze repo bestaat.
- Initiële credentials en secrets in lokale, niet-gecommitte bestanden.

Alles daarboven hoort in git als declaratieve resource, cloud-init template,
Ansible playbook, role of script.

## Regels voor nieuwe componenten

- Voeg geen permanente handmatige stappen toe zonder ook vast te leggen waar ze
  geautomatiseerd worden.
- Scripts en playbooks moeten idempotent zijn: opnieuw draaien mag geen schade
  doen.
- Secrets komen niet in git. Gebruik `.env`, Ansible Vault, SOPS of een andere
  expliciet gekozen secret backend.
- IP's, hostnames en VMID/CTID-keuzes worden in de repo vastgelegd.
- Een component is pas klaar wanneer er ook een verificatiestap bestaat.

## PBS patroon

PBS volgt dezelfde workflow:

1. OpenTofu maakt `pbs01` als x86_64 VM en injecteert cloud-init.
2. Cloud-init zet hostname, netwerk, SSH en basispackages.
3. Ansible installeert Proxmox Backup Server, mount `/volume1/pbs`, maakt de
   datastore, configureert retentie, verify jobs, users en ACL's.
4. OpenTofu koppelt `pbs01` daarna als Proxmox Backup Server storage zodra
   endpoint, datastore en token bekend zijn.
