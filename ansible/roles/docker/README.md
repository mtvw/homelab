# Docker role

Deze role configureert Debian hosts als Docker hosts.

Verantwoordelijkheden:

- Docker packages installeren vanuit de Debian repositories.
- De Docker service inschakelen en starten.
- Beheergebruikers toevoegen aan de `docker` group.
- Valideren dat de Docker daemon bereikbaar is.
- Optioneel de media NAS export mounten op de Docker host.
- Traefik als lokale reverse proxy voor de Docker services beheren.
- Watchtower in monitor-only modus beheren voor image update-detectie.
- WUD als webdashboard beheren voor beschikbare container image updates.
- De Radarr, Sonarr, SABnzbd, Prowlarr, Seerr, Readarr, Audiobookshelf,
  Wealthfolio en Homepage containers beheren als systemd-backed Compose stack.

## Media stack

Standaard maakt de role `/opt/media-stack/compose.yml` aan en beheert systemd
unit `media-stack.service`.

| Service | Poort |
| --- | --- |
| Radarr | `7878` |
| Sonarr | `8989` |
| SABnzbd | `8080` |
| Prowlarr | `9696` |
| Seerr | `5055` |
| Readarr | `8787` |
| Audiobookshelf | `13378` |
| Wealthfolio | `8088` |
| Homepage | `3000` |
| WUD | `3001` |
| Traefik HTTP entrypoint | `80` |
| Traefik dashboard | `8081` |

WUD, "What's up Docker", draait standaard op `3001` en toont in een web UI
welke containers nieuwe image-versies beschikbaar hebben. WUD gebruikt de Docker
socket read-only en bewaart state onder `/opt/media-stack/config/wud`. De
standaard Traefik URL is:

| Service | Traefik URL |
| --- | --- |
| WUD | `http://wud.thuis.infinita.be` |

Watchtower draait standaard mee zonder poort en met
`WATCHTOWER_MONITOR_ONLY=true`. Het controleert dagelijks om 08:00 of er nieuwe
container images beschikbaar zijn, maar voert geen updates uit. Het heeft geen
dashboard in deze setup; gebruik WUD voor de visuele update-lijst. Bekijk
Watchtower-meldingen via:

```bash
docker logs watchtower
```

Zet `docker_watchtower_notification_url` om meldingen via een Shoutrrr URL naar
bijvoorbeeld ntfy, Discord, Slack of e-mail te sturen.

Readarr gebruikt bewust `ghcr.io/linuxserver/readarr:develop-0.4.18.2805-ls157`
in plaats van de moving `develop` tag, omdat de upstream image deprecated is en
de generieke manifest geen werkende `linux/amd64` entry meer biedt.

Wealthfolio draait met `WF_AUTH_REQUIRED=false`, passend bij de overige
interne HTTP-services in deze stack. Voeg app- of proxy-authenticatie toe als
de Traefik-route buiten het vertrouwde netwerk beschikbaar wordt gemaakt.

Containerconfiguratie staat onder `/opt/media-stack/config`. De NAS media export
wordt op de VM gemount op `/srv/media` en in de containers beschikbaar gemaakt
als `/media`. Downloads staan standaard lokaal op `/srv/downloads` en worden in
de containers beschikbaar gemaakt als `/downloads`.

Traefik draait standaard mee in dezelfde Compose stack, leest Docker labels via
de Docker socket en exposeert alleen containers met `traefik.enable=true`.
Directe containerpoorten blijven gepubliceerd voor eerste configuratie en
fallback. De standaard hostnames zijn:

| Service | Traefik URL |
| --- | --- |
| Base dashboard | `http://thuis.infinita.be` |
| Radarr | `http://radarr.thuis.infinita.be` |
| Sonarr | `http://sonarr.thuis.infinita.be` |
| SABnzbd | `http://sabnzbd.thuis.infinita.be` |
| Prowlarr | `http://prowlarr.thuis.infinita.be` |
| Seerr | `http://seerr.thuis.infinita.be` |
| Readarr | `http://readarr.thuis.infinita.be` |
| Audiobookshelf | `http://audiobookshelf.thuis.infinita.be` |
| Wealthfolio | `http://wealthfolio.thuis.infinita.be` |
| Homepage | `http://homepage.thuis.infinita.be` |
| WUD | `http://wud.thuis.infinita.be` |
| Traefik dashboard | `http://10.0.1.21:8081` |

Zorg dat deze hostnames in DNS, DHCP of lokale hosts-files naar `10.0.1.21`
wijzen, of pas `docker_traefik_domain` aan. Zet `docker_traefik_enabled: false`
om Traefik niet te beheren.

Homepage gebruikt `/opt/media-stack/config/homepage` als `/app/config`, mount de
Docker socket read-only voor containerintegraties en accepteert standaard
`10.0.1.21:3000`, `thuis.infinita.be` en `homepage.thuis.infinita.be` via
`HOMEPAGE_ALLOWED_HOSTS`. Traefik routeert zowel `thuis.infinita.be` als
`homepage.thuis.infinita.be` naar Homepage. Homepage gebruikt bewust niet de
gedeelde `PUID`/`PGID` instellingen, zodat de Docker socket-integratie werkt met
de standaard containerrechten. Pas `docker_stack_allowed_hosts` aan als Homepage
via een andere DNS-naam, reverse proxy of ander adres benaderd wordt.
Homepage browserlinks blijven naar Traefik-hostnamen wijzen, maar widget- en
monitor-URL's gebruiken standaard Docker service-namen zoals `http://sonarr:8989`.
Die requests worden namelijk vanuit de Homepage-container zelf uitgevoerd.

De Homepage configuratie wordt door Ansible beheerd vanuit
`templates/homepage/*.yaml.j2`. Standaard worden kaarten aangemaakt voor
Jellyfin, Radarr, Sonarr, SABnzbd, Prowlarr, Seerr, Readarr, Audiobookshelf,
Wealthfolio, Homepage, Traefik, WUD, Watchtower, Proxmox VE en Proxmox Backup
Server. Docker containerstatistieken werken via `/var/run/docker.sock`;
service-widgets worden pas gerenderd wanneer de bijbehorende secrets gezet zijn:
Omdat `services.yaml` de gerenderde widget-secrets kan bevatten, krijgt dat
bestand op de Docker host mode `0600`; de overige Homepage configbestanden
blijven `0644`.

| Variabele | Widget |
| --- | --- |
| `docker_homepage_radarr_api_key` | Radarr |
| `docker_homepage_sonarr_api_key` | Sonarr |
| `docker_homepage_sabnzbd_api_key` | SABnzbd |
| `docker_homepage_prowlarr_api_key` | Prowlarr |
| `docker_homepage_seerr_api_key` | Seerr |
| `docker_homepage_readarr_api_key` | Readarr |
| `docker_homepage_audiobookshelf_api_key` | Audiobookshelf |
| `docker_homepage_jellyfin_api_key` | Jellyfin |
| `docker_homepage_proxmox_username` + `docker_homepage_proxmox_password` | Proxmox VE |
| `docker_homepage_pbs_username` + `docker_homepage_pbs_password` | PBS |

Zet deze waarden via inventory, group vars of Ansible Vault, niet in plain-text
defaults.

De role valideert standaard dat `/srv/media` leesbaar is en `/srv/downloads`
schrijfbaar is voor UID/GID `1000`. Zet `docker_media_validate_writable: true`
als de NAS export door Radarr/Sonarr direct beschreven moet kunnen worden.

## Variabelen

Standaardwaarden staan in `defaults/main.yml`. Environment-specifieke waarden
horen later in inventory, group vars of een secret backend.
