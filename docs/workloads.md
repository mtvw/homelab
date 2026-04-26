# Workloads

VM's en LXC's worden door OpenTofu aangemaakt. Ansible verwacht dat de host al
bestaat, een IP heeft en via SSH bereikbaar is. De volgorde is dus altijd:

```text
OpenTofu maakt VM/LXC
cloud-init maakt VM bereikbaar
Ansible configureert OS/service
validatie controleert de werking
```

## Waar komen VM's en LXC's?

Gebruik deze indeling:

| Type | Locatie | Opmerking |
| --- | --- | --- |
| Core infra VM's | `environments/homelab/*.tf` | Bijvoorbeeld `pbs01`, DNS, monitoring |
| Gewone workloads | `environments/homelab/workloads.tf` of modules | Applicatie-VM's/LXC's |
| Herbruikbare patronen | `modules/` | Later toevoegen zodra meerdere workloads hetzelfde patroon delen |

`pbs01` is core infra en hoort daarom als OpenTofu-resource in
`environments/homelab/pbs.tf`.

## Lifecycle

1. Kies hostname, IP en VMID/CTID in `docs/ipam.md`.
2. Voeg de OpenTofu resource toe.
3. Koppel cloud-init voor hostname, netwerk en SSH.
4. Run `make plan` en `make apply`.
5. Wacht tot cloud-init klaar is en SSH werkt.
6. Run het bijbehorende Ansible playbook.
7. Run service-validatie.

## PBS

Voor PBS betekent dit:

1. OpenTofu maakt VM `pbs01` op `10.0.1.20`.
2. cloud-init zet `pbs01` klaar voor Ansible.
3. `make ansible-pbs` installeert en configureert PBS.
4. OpenTofu koppelt daarna PBS als Proxmox storage zodra token/fingerprint
   beschikbaar zijn.

Tot stap 1 en 2 bestaan, kan `make ansible-pbs` niet slagen. Dat is verwacht:
Ansible is configuratiebeheer, geen VM-provisioninglaag.

## Docker host

`docker01` is een Debian workload VM voor Docker containers.

1. OpenTofu maakt VM `docker01` op `10.0.1.21`.
2. cloud-init zet `docker01` klaar voor Ansible.
3. `make ansible-docker` installeert Docker en valideert de daemon.
