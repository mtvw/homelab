# Docker role

Deze role configureert Debian hosts als Docker hosts.

Verantwoordelijkheden:

- Docker packages installeren vanuit de Debian repositories.
- De Docker service inschakelen en starten.
- Beheergebruikers toevoegen aan de `docker` group.
- Valideren dat de Docker daemon bereikbaar is.
- Optioneel de media NAS export mounten op de Docker host.
- Traefik als lokale reverse proxy voor de Docker services beheren.
- De Radarr, Sonarr, SABnzbd en Homepage containers beheren als systemd-backed
  Compose stack.

## Media stack

Standaard maakt de role `/opt/media-stack/compose.yml` aan en beheert systemd
unit `media-stack.service`.

| Service | Poort |
| --- | --- |
| Radarr | `7878` |
| Sonarr | `8989` |
| SABnzbd | `8080` |
| Homepage | `3000` |
| Traefik HTTP entrypoint | `80` |
| Traefik dashboard | `8081` |

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
| Radarr | `http://radarr.docker01.home.arpa` |
| Sonarr | `http://sonarr.docker01.home.arpa` |
| SABnzbd | `http://sabnzbd.docker01.home.arpa` |
| Homepage | `http://homepage.docker01.home.arpa` |
| Traefik dashboard | `http://10.0.1.21:8081` |

Zorg dat deze hostnames in DNS, DHCP of lokale hosts-files naar `10.0.1.21`
wijzen, of pas `docker_traefik_domain` aan. Zet `docker_traefik_enabled: false`
om Traefik niet te beheren.

Homepage gebruikt `/opt/media-stack/config/homepage` als `/app/config`, mount de
Docker socket read-only voor containerintegraties en accepteert standaard
`10.0.1.21:3000` en `homepage.docker01.home.arpa` via
`HOMEPAGE_ALLOWED_HOSTS`. Homepage gebruikt bewust niet de gedeelde `PUID`/`PGID`
instellingen, zodat de Docker socket-integratie werkt met de standaard
containerrechten. Pas `docker_stack_allowed_hosts` aan als Homepage via een
andere DNS-naam, reverse proxy of ander adres benaderd wordt.

De role valideert standaard dat `/srv/media` leesbaar is en `/srv/downloads`
schrijfbaar is voor UID/GID `1000`. Zet `docker_media_validate_writable: true`
als de NAS export door Radarr/Sonarr direct beschreven moet kunnen worden.

## Variabelen

Standaardwaarden staan in `defaults/main.yml`. Environment-specifieke waarden
horen later in inventory, group vars of een secret backend.
