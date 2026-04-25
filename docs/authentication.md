# Authentication model

Gebruik voor OpenTofu een dedicated Proxmox API token.

## Keuze

- Geen root password in OpenTofu.
- Geen credentials in git.
- Een aparte `terraform@pve` gebruiker met API token.
- SSH staat standaard uit en wordt alleen aangezet voor resources die het nodig
  hebben.

## Bootstrap

Maak dit eenmalig aan via de Proxmox shell of UI.

```sh
pveum user add terraform@pve --comment "OpenTofu automation"
pveum aclmod / -user terraform@pve -role Administrator
pveum user token add terraform@pve opentofu --privsep=0
```

Zet de token daarna in `/Users/matthias/Dev/homelab/.env`:

```sh
PROXMOX_VE_ENDPOINT=https://10.0.1.12:8006/
PROXMOX_VE_API_TOKEN=terraform@pve!opentofu=...
PROXMOX_VE_INSECURE=true
```

Maak die file door `.env.example` te kopieren naar `.env`. De echte `.env`
wordt genegeerd door git.

Test daarna:

```sh
make env-check
make plan
```

De `Administrator` rol is een bewuste bootstrap-keuze. Zodra de eerste basislaag
stabiel is, kunnen we dit verstrakken naar een custom role met alleen de
privileges die de repo nodig heeft.

## SSH

Geen SSH key in git of in `terraform.tfvars` zetten.

Voorlopig is SSH niet nodig voor storage, repositories en later standaard VM/LXC
beheer. Als we snippets, bepaalde uploads of LXC idmaps gebruiken, maken we een
Linux user `terraform` op elke Proxmox node en gebruiken we je lokale SSH agent:

```sh
ssh-add ~/.ssh/id_ed25519
```

Daarna pas:

```hcl
proxmox_ssh_enabled  = true
proxmox_ssh_username = "terraform"
```
