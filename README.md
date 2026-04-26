# Homelab IaC

Deze repo beheert de homelab-infrastructuur als automation-first IaC project.
Het doel is reproduceerbaarheid: zo weinig mogelijk handwerk en alle blijvende
configuratie in git via OpenTofu, cloud-init, Ansible of idempotente scripts.

## Voorziene topologie

| Hostname | IP | Rol | OS |
| --- | --- | --- | --- |
| `pepper` | `10.0.1.12` | Proxmox VE node | Proxmox VE 9 |
| `salt` | `10.0.1.13` | Proxmox VE node | Proxmox VE 9 |
| `tumuric` | `10.0.1.14` | q-device | Debian/ARM |
| `pbs01` | `10.0.1.20` | Proxmox Backup Server VM | Debian/x86_64 |
| NAS | `10.0.1.11` | NFS storage | Extern |

## Repo-indeling

| Pad | Doel |
| --- | --- |
| `environments/homelab` | OpenTofu root module voor deze homelab |
| `cloud-init` | Eerste-boot templates voor door OpenTofu gemaakte hosts |
| `ansible` | OS- en serviceconfiguratie na cloud-init |
| `docs/automation.md` | Vaste automatiseringsworkflow en day-0 grens |
| `docs/bootstrap.md` | Handmatige day-0 stappen die OpenTofu niet betrouwbaar zelf kan doen |
| `docs/authentication.md` | API-token en SSH-keuzes |
| `docs/decisions.md` | Vastgelegde keuzes voor deze homelab |
| `docs/ipam.md` | IP-plan voor nodes en toekomstige workloads |
| `docs/pbs.md` | PBS automatiseringsplan |
| `docs/questions.md` | Open vragen voordat resources effectief worden aangemaakt |
| `docs/storage.md` | NAS/NFS en PBS storageplan |

## Eerste gebruik

```sh
cd environments/homelab
cp terraform.tfvars.example terraform.tfvars
```

Vul daarna `terraform.tfvars` aan en zet credentials in een lokale `.env` in de
repo-root:

```sh
cd /Users/matthias/Dev/homelab
cp .env.example .env
```

Open `.env` en vervang `replace-with-token-secret` door de tokenwaarde uit
Proxmox. De `.env` wordt genegeerd door git.

SSH support in de provider staat standaard uit. Zet `proxmox_ssh_enabled = true`
en vul `proxmox_ssh_username` pas in wanneer we resources toevoegen die SSH
nodig hebben, zoals snippets of bepaalde file uploads.

Daarna:

```sh
make env-check
make init
make validate
make plan
make apply
```

## Belangrijke keuzes

- Dit is een automatiseringsrepo, geen verzameling permanente handmatige
  runbooks. Handmatige stappen horen alleen in day-0 bootstrap of als tijdelijke
  overgang naar automation.
- De vaste workflow is OpenTofu voor infra, cloud-init voor eerste boot en
  Ansible/idempotente scripts voor OS- en serviceconfiguratie.
- Credentials worden niet in git gezet. Gebruik environment variables of een
  genegeerde `terraform.tfvars`.
- De Proxmox cluster zelf en de q-device join zijn day-0 bootstrap-stappen.
  OpenTofu documenteert en beheert daarna de clusterbrede configuratie die via de
  Proxmox API ondersteund wordt.
- OpenTofu gebruikt een dedicated Proxmox API token. SSH staat standaard uit.
- Proxmox nodes gebruiken de `no-subscription` repository; de enterprise repo
  wordt na import declaratief uitgeschakeld.
- Workload IPs starten bij `10.0.1.21`; allocations worden later centraal in de
  repo bijgehouden.
- Workloads komen later in aparte bestanden/modules, zodat de basislaag stabiel
  blijft.
