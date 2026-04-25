# Open vragen

Beantwoord liefst deze vragen voordat we de eerste echte Proxmox resources laten
aanmaken.

## Cluster

- De cluster lijkt al aangemaakt: beide nodes zijn zichtbaar in beide web UIs.
- Clusternaam: `homelab`.
- Voorlopig is `https://10.0.1.12:8006/` goed genoeg als endpoint.
- Gebruik je enterprise repositories/subscription, of moeten we no-subscription
  repositories declaratief beheren? Antwoord: no-subscription/community.

## Authenticatie

- Keuze: OpenTofu gebruikt een dedicated API token.
- Bootstrap-keuze: tijdelijk `Administrator` op `terraform@pve`; later
  verstrakken naar een custom role.
- SSH blijft voorlopig uit en wordt pas toegevoegd als een resource het nodig
  heeft.

## Netwerk

- Welke subnetten/VLANs wil je voorzien voor management, guests, storage en
  eventueel DMZ/IoT?
- DNS komt later; voorlopig gebruiken we IP-adressen.
- Moet `/etc/hosts` op de Proxmox nodes door OpenTofu beheerd worden?
- Is `vmbr0` de bridge voor toekomstige VMs/LXCs, en moet die VLAN-aware zijn?

## NAS / NFS

- Bestaande export: `/volume1/media`.
- Voorlopige storage ID: `nas_media`.
- Voorlopige content types: `images`, `iso`, `vztmpl`, `backup`, `snippets`.
- Welke NFS-versie en mount options wil je gebruiken?

## PBS

- Voorstel: maak aparte NAS export `/volume1/pbs`.
- Voorstel PBS datastore naam: `pbs-main`.
- Welke backup retentie wil je hanteren?
- Wil je PBS initieel alleen als storage in Proxmox koppelen, of ook backup jobs
  declaratief beheren?

## Workloads later

- Workload IPs starten vanaf `10.0.1.20`.
- Voorlopige Proxmox VMID/CTID start: `120`.
- Welke base images/templates wil je standaard downloaden?
- Wil je cloud-init/snippets centraal beheren via OpenTofu?
