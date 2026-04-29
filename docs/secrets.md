# Secrets

Secrets horen niet in role defaults, `.env.example`, inventory examples of
plain-text YAML. Voor deze single-user homelab gebruikt Ansible daarom een
encrypted Ansible Vault bestand voor service credentials die Ansible naar hosts
uitrolt.

## Waarvoor

Homepage gebruikt twee soorten integraties:

- Docker containerstatussen via de read-only Docker socket. Daarvoor is geen API
  key nodig.
- Service widgets via API keys of credentials. Deze waarden staan in de
  `docker_homepage_*` variabelen en worden naar
  `/opt/media-stack/config/homepage/services.yaml` gerenderd.

De klikbare `href` links mogen naar Traefik/DNS-hostnamen wijzen. De widget
`url` waarden moeten bereikbaar zijn vanuit de Homepage-container zelf. Voor
services in dezelfde Docker Compose stack gebruikt de role daarom standaard
Docker service-namen zoals `http://sonarr:8989`.

## Eerste keer opzetten

Maak de encrypted vault:

```sh
make vault-create
```

Kies een sterke Vault password/passphrase en bewaar die buiten deze repository,
bijvoorbeeld in je password manager. Commit de Vault password niet.

Bewerk daarna de waarden:

```sh
make vault-edit
```

Vul alleen de variabelen in voor widgets die je effectief wil tonen. Laat andere
waarden leeg of verwijder ze.

## Deployen

Zodra `ansible/group_vars/docker_hosts/vault.yml` bestaat, geven de Makefile
targets automatisch `--ask-vault-pass` mee:

```sh
make ansible-docker
```

Ansible rendert de Homepage configuratie naar de Docker host. De template-task
heeft `no_log` aan, zodat secrets niet in de Ansible output verschijnen. Omdat
de widget credentials in `services.yaml` terechtkomen, krijgt dat bestand op de
Docker host filemode `0600`.

## Secrets vinden in applicaties

- Radarr, Sonarr en Prowlarr: `Settings` -> `General` -> `Security` -> `API Key`.
- SABnzbd: `Config` -> `General` -> `Security` -> `API Key`.
- Jellyfin: dashboard/admin settings -> API keys.
- Seerr: settings/API of de beheerinstellingen voor API keys.
- Proxmox VE/PBS: gebruik bij voorkeur een dedicated, minimaal geprivilegieerde
  gebruiker of token voor dashboard-read-only gebruik.

## Regels

- Bewaar de Vault password buiten git.
- Gebruik aparte API keys/tokens voor Homepage waar de service dat ondersteunt.
- Geef alleen read-only of minimaal noodzakelijke rechten.
- Roteer een key als die ooit in plain text in logs, shell history of chat is
  beland.
- Commit alleen encrypted Vault content, nooit decrypted secretbestanden.
