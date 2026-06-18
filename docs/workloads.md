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
6. Registreer of vernieuw de SSH host key met `make ansible-known-hosts`.
7. Run het bijbehorende Ansible playbook.
8. Run service-validatie.

SSH host key verificatie blijft aan. `make ansible-known-hosts` vult
`~/.ssh/known_hosts` vanuit de inventory, maar de eerste trust-beslissing blijft
bewust: controleer bij nieuwe of vervangen VM's dat het IP echt bij de bedoelde
host hoort.

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

`docker01` is een Debian workload VM voor Docker containers. De Docker role
installeert ook Traefik, Watchtower in monitor-only modus, WUD als
update-dashboard en de media-stack containers Radarr, Sonarr, Bazarr, SABnzbd,
qBittorrent, Prowlarr, Seerr, Readarr, Audiobookshelf, Wealthfolio, Mealie en
Homepage.

1. OpenTofu maakt VM `docker01` op `10.0.1.21`.
2. cloud-init zet `docker01` klaar voor Ansible.
3. `make ansible-docker` installeert Docker, mount de NAS media export op
   `/srv/media`, start `media-stack.service` en valideert de daemon plus poorten
   `7878`, `8989`, `6767`, `8080`, `8082`, `9696`, `5055`, `8787`, `13378`,
   `8088`, `9000`, `3000`, `3001`, `80`, `443` en `8081`. qBittorrent
   publiceert daarnaast peer-poort `6881/tcp+udp`. Watchtower controleert
   dagelijks of er nieuwe container images beschikbaar zijn, maar voert geen
   updates uit. WUD toont beschikbare updates in een web UI.
4. De eerste webconfiguratie gebeurt via:
   - Radarr: `http://10.0.1.21:7878`
   - Sonarr: `http://10.0.1.21:8989`
   - Bazarr: `http://10.0.1.21:6767`
   - SABnzbd: `http://10.0.1.21:8080`
   - qBittorrent: `http://10.0.1.21:8082`
   - Prowlarr: `http://10.0.1.21:9696`
   - Seerr: `http://10.0.1.21:5055`
   - Readarr: `http://10.0.1.21:8787`
   - Audiobookshelf: `http://10.0.1.21:13378`
   - Wealthfolio: `http://10.0.1.21:8088`
   - Mealie: `http://10.0.1.21:9000`
   - Homepage: `http://10.0.1.21:3000`
   - WUD: `http://10.0.1.21:3001`
5. Na DNS/hosts-records naar `10.0.1.21` zijn de Traefik-routes:
   - Base dashboard: `https://thuis.infinita.be`
   - Jellyfin: `https://jellyfin.thuis.infinita.be`
   - Radarr: `https://radarr.thuis.infinita.be`
   - Sonarr: `https://sonarr.thuis.infinita.be`
   - Bazarr: `https://bazarr.thuis.infinita.be`
   - SABnzbd: `https://sabnzbd.thuis.infinita.be`
   - qBittorrent: `https://qbittorrent.thuis.infinita.be`
   - Prowlarr: `https://prowlarr.thuis.infinita.be`
   - Seerr: `https://seerr.thuis.infinita.be`
   - Readarr: `https://readarr.thuis.infinita.be`
   - Audiobookshelf: `https://audiobookshelf.thuis.infinita.be`
   - Wealthfolio: `https://wealthfolio.thuis.infinita.be`
   - Mealie: `https://mealie.thuis.infinita.be`
   - Homepage: `https://homepage.thuis.infinita.be`
   - WUD: `https://wud.thuis.infinita.be`
   - Traefik dashboard: `http://10.0.1.21:8081`

## Jellyfin

`jellyfin01` is een Debian LXC voor Jellyfin.

1. OpenTofu downloadt de Debian LXC-template naar Proxmox storage.
2. OpenTofu maakt LXC `jellyfin01` op `10.0.1.22`.
3. De container krijgt een root SSH key via LXC-initialisatie.
4. `make ansible-jellyfin` installeert Jellyfin, mount de NAS media export op
   `/media` en valideert poort `8096`.
5. De eerste Jellyfin setup gebeurt in de web UI op `http://10.0.1.22:8096`.
   Na DNS en de Docker Traefik rollout is Jellyfin ook bereikbaar via
   `https://jellyfin.thuis.infinita.be`.
