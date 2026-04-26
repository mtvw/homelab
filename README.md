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
| `docs/workloads.md` | Waar VM's/LXC's worden aangemaakt en hoe ze doorstromen naar Ansible |

## Hoe Je Deze Repo Leest

Begin altijd hier:

1. Lees [docs/automation.md](docs/automation.md) voor het model: wat doet
   OpenTofu, wat doet cloud-init en wat doet Ansible.
2. Lees [docs/bootstrap.md](docs/bootstrap.md) voor de kleine set day-0 stappen
   die nog buiten automation vallen.
3. Controleer [docs/decisions.md](docs/decisions.md) en [docs/ipam.md](docs/ipam.md)
   zodat hostnames, IP's en gemaakte keuzes duidelijk zijn.
4. Voer daarna de workflow hieronder uit.

Een nieuwe component hoort altijd dezelfde route te volgen:

```text
day-0 alleen indien nodig
OpenTofu resource toevoegen
cloud-init bootstrap toevoegen indien het een nieuwe host is
Ansible role/playbook toevoegen voor OS- en serviceconfiguratie
validatie toevoegen
```

## Workflow

### 1. Day-0 bootstrap

Voer alleen de stappen uit [docs/bootstrap.md](docs/bootstrap.md) handmatig uit.
Dat zijn de ankers die nodig zijn voordat automation kan praten met Proxmox, de
NAS of het netwerk.

Voor PBS betekent dit voorlopig alleen: de NAS export `/volume1/pbs` bestaat en
geeft read/write NFS-toegang aan `pbs01` (`10.0.1.20`). De PBS VM zelf hoort
niet handmatig te worden aangemaakt.

### 2. OpenTofu

OpenTofu beheert Proxmox-infra: VM's, LXC's, storage resources, cloud-init
koppelingen en clusterbrede instellingen die via de Proxmox API kunnen.
Nieuwe VM's en LXC's worden dus hier aangemaakt, niet in Ansible. Zie
[docs/workloads.md](docs/workloads.md).

Eerste lokale setup:

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

### 3. cloud-init

cloud-init wordt door OpenTofu aan nieuwe VM's gekoppeld. Gebruik dit alleen voor
eerste boot: hostname, netwerk, SSH-toegang en minimale packages zodat Ansible
kan overnemen.

Templates horen in [cloud-init](cloud-init/). Een gebruiker voert cloud-init
niet apart uit; Proxmox doet dat tijdens de eerste boot van een VM.

### 4. Ansible

Ansible configureert hosts nadat OpenTofu ze heeft gemaakt en cloud-init ze
bereikbaar heeft gemaakt.

Voor PBS is de bedoelde flow:

```sh
make ansible-pbs
```

Dit werkt pas nadat OpenTofu de VM `pbs01` heeft aangemaakt en cloud-init SSH
toegang heeft klaargezet.

Het PBS playbook staat in [ansible/playbooks/pbs.yml](ansible/playbooks/pbs.yml)
en gebruikt de role onder [ansible/roles/pbs](ansible/roles/pbs/README.md).

### 5. Validatie

Run lokale checks voordat je wijzigingen vertrouwt:

```sh
make check
```

`make check` doet bewust alleen checks die geen provider execution nodig hebben.
Gebruik `make validate` apart voor OpenTofu schema-validatie; er is momenteel
een lokale provider-handshake issue met de Proxmox provider die nog opgelost
moet worden.

Voor echte services hoort er daarnaast een functionele validatie te zijn. Voor
PBS betekent dat onder andere: PBS API bereikbaar, datastore bestaat, NFS mount
beschrijfbaar, Proxmox ziet de PBS storage en een restore-test is uitgevoerd.

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
