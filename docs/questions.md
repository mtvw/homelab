# Open vragen

Deze vragen zijn nog niet beslist. Beantwoorde keuzes staan in
`docs/decisions.md`.

## Netwerk

- Welke subnetten/VLANs wil je voorzien voor management, guests, storage en
  eventueel DMZ/IoT?
- Moet `/etc/hosts` op de Proxmox nodes door OpenTofu beheerd worden?
- Is `vmbr0` de bridge voor toekomstige VMs/LXCs, en moet die VLAN-aware zijn?
- Waar komt later DNS te draaien: UniFi, een VM/LXC, de NAS, of iets extern?

## NAS / NFS

- Welke NFS-versie en mount options wil je gebruiken?
- Moet `/volume1/media` echt Proxmox VM/LXC disks toelaten, of is het enkel voor
  ISO/templates/backups/snippets bedoeld?
- Maak je een aparte `/volume1/pbs` export voor PBS?

## PBS

- Welke backup retentie wil je hanteren?
- Wil je PBS initieel alleen als storage in Proxmox koppelen, of ook backup jobs
  declaratief beheren?
- Wil je PBS users/tokens/datastores later ook in IaC, of blijft PBS bootstrap
  grotendeels handmatig?

## Workloads

- Welke base images/templates wil je standaard downloaden?
- Wil je cloud-init/snippets centraal beheren via OpenTofu?
- Wil je LXCs privileged of unprivileged als default?
- Welke naming convention wil je voor VMs/LXCs?

## Security

- Wanneer verstrakken we `terraform@pve` van `Administrator` naar een custom
  least-privilege role?
