# Homelab IaC

Deze repo beheert de homelab-infrastructuur met OpenTofu. De eerste scope is de
Proxmox-basislaag: clusterconfiguratie, gedeelde storage, gebruikers/rollen en
later LXC/VM-workloads.

## Voorziene topologie

| Hostname | IP | Rol | OS |
| --- | --- | --- | --- |
| `pepper` | `10.0.1.12` | Proxmox VE node | Proxmox VE 9 |
| `salt` | `10.0.1.13` | Proxmox VE node | Proxmox VE 9 |
| `tumuric` | `10.0.1.14` | q-device + PBS | Debian |
| NAS | `10.0.1.11` | NFS storage | Extern |

## Repo-indeling

| Pad | Doel |
| --- | --- |
| `environments/homelab` | OpenTofu root module voor deze homelab |
| `docs/bootstrap.md` | Handmatige day-0 stappen die OpenTofu niet betrouwbaar zelf kan doen |
| `docs/authentication.md` | API-token en SSH-keuzes |
| `docs/decisions.md` | Vastgelegde keuzes voor deze homelab |
| `docs/ipam.md` | IP-plan voor nodes en toekomstige workloads |
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

- Credentials worden niet in git gezet. Gebruik environment variables of een
  genegeerde `terraform.tfvars`.
- De Proxmox cluster zelf en de q-device join zijn day-0 bootstrap-stappen.
  OpenTofu documenteert en beheert daarna de clusterbrede configuratie die via de
  Proxmox API ondersteund wordt.
- OpenTofu gebruikt een dedicated Proxmox API token. SSH staat standaard uit.
- Proxmox nodes gebruiken de `no-subscription` repository; de enterprise repo
  wordt na import declaratief uitgeschakeld.
- Workload IPs starten bij `10.0.1.20`; allocations worden later centraal in de
  repo bijgehouden.
- Workloads komen later in aparte bestanden/modules, zodat de basislaag stabiel
  blijft.
