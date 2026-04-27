# Docker role

Deze role configureert Debian hosts als Docker hosts.

Verantwoordelijkheden:

- Docker packages installeren vanuit de Debian repositories.
- De Docker service inschakelen en starten.
- Beheergebruikers toevoegen aan de `docker` group.
- Valideren dat de Docker daemon bereikbaar is.
- Optioneel de media NAS export mounten op de Docker host.
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

Containerconfiguratie staat onder `/opt/media-stack/config`. De NAS media export
wordt op de VM gemount op `/srv/media` en in de containers beschikbaar gemaakt
als `/media`. Downloads staan standaard lokaal op `/srv/downloads` en worden in
de containers beschikbaar gemaakt als `/downloads`.

Homepage gebruikt `/opt/media-stack/config/homepage` als `/app/config`, mount de
Docker socket read-only voor containerintegraties en accepteert standaard
`10.0.1.21:3000` via `HOMEPAGE_ALLOWED_HOSTS`. Homepage gebruikt bewust niet de
gedeelde `PUID`/`PGID` instellingen, zodat de Docker socket-integratie werkt met
de standaard containerrechten. Pas `docker_stack_allowed_hosts` aan als Homepage
via een DNS-naam, reverse proxy of ander adres benaderd wordt.

De role valideert standaard dat `/srv/media` leesbaar is en `/srv/downloads`
schrijfbaar is voor UID/GID `1000`. Zet `docker_media_validate_writable: true`
als de NAS export door Radarr/Sonarr direct beschreven moet kunnen worden.

## Variabelen

Standaardwaarden staan in `defaults/main.yml`. Environment-specifieke waarden
horen later in inventory, group vars of een secret backend.
