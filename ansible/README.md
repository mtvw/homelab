# Ansible

Ansible beheert OS- en serviceconfiguratie nadat OpenTofu de machines heeft
aangemaakt en cloud-init ze bereikbaar heeft gemaakt.

Ansible maakt geen VM's of LXC's aan. Als een playbook een host op een IP
verwacht, moet die host eerst als OpenTofu-resource bestaan. Zie
`docs/workloads.md`.

## Structuur

| Pad | Doel |
| --- | --- |
| `inventory.example.yml` | Voorbeeldinventory zonder secrets |
| `playbooks/pbs.yml` | PBS configuratie voor `pbs01` |
| `playbooks/docker.yml` | Docker configuratie voor Docker hosts |
| `playbooks/jellyfin.yml` | Jellyfin installatie en configuratie voor `jellyfin01` |
| `roles/` | Herbruikbare rollen per component |

Kopieer `inventory.example.yml` lokaal naar een niet-gecommit inventorybestand
of genereer later inventory vanuit OpenTofu output.

## Uitvoering

```sh
ansible-playbook -i ansible/inventory.example.yml ansible/playbooks/known_hosts.yml
ansible-playbook -i ansible/inventory.example.yml ansible/playbooks/pbs.yml
ansible-playbook -i ansible/inventory.example.yml ansible/playbooks/docker.yml
ansible-playbook -i ansible/inventory.example.yml ansible/playbooks/jellyfin.yml
```

De repo bevat een `ansible.cfg` die tijdelijke bestanden onder `.ansible/tmp`
plaatst, zodat Ansible niet afhankelijk is van globale user-state.

## SSH host keys

SSH host key verificatie blijft aan. Dat is bewust: Ansible mag niet stilzwijgend
een andere machine vertrouwen wanneer een IP opnieuw gebruikt wordt.

Na het aanmaken of vervangen van VM's kun je de inventory-hosts opnemen in je
lokale `known_hosts`:

```sh
make ansible-known-hosts
```

Deze target gebruikt `ssh-keyscan` voor de hosts in de Ansible inventory en zet
de keys gehasht in `~/.ssh/known_hosts`. Dit is idempotent, maar het is nog
steeds trust-on-first-use: controleer bij een nieuwe of vervangen VM eerst via
Proxmox console of een andere out-of-band bron dat het IP echt bij de bedoelde
host hoort.

Als een VM bewust opnieuw is aangemaakt en SSH klaagt over een gewijzigde host
key, verwijder dan eerst de oude entry en scan opnieuw:

```sh
ssh-keygen -R 10.0.1.21
make ansible-known-hosts
```

## Docker media stack

`make ansible-docker` installeert Docker op `docker01`, mount
`10.0.1.11:/volume1/media` op `/srv/media`, maakt `/srv/downloads` voor SABnzbd
en beheert Traefik, Radarr, Sonarr, SABnzbd en Homepage via
`media-stack.service`.

De services zijn bereikbaar op:

| Service | URL |
| --- | --- |
| Traefik dashboard | `http://10.0.1.21:8081` |
| Radarr | `http://10.0.1.21:7878` |
| Sonarr | `http://10.0.1.21:8989` |
| SABnzbd | `http://10.0.1.21:8080` |
| Homepage | `http://10.0.1.21:3000` |

Traefik luistert daarnaast op `http://10.0.1.21:80`. Zodra DNS of lokale
hosts-records naar `10.0.1.21` wijzen, zijn de standaard routes:

| Service | Traefik URL |
| --- | --- |
| Radarr | `http://radarr.docker01.home.arpa` |
| Sonarr | `http://sonarr.docker01.home.arpa` |
| SABnzbd | `http://sabnzbd.docker01.home.arpa` |
| Homepage | `http://homepage.docker01.home.arpa` |

Homepage configuratie wordt vanuit de Docker role beheerd en naar
`/opt/media-stack/config/homepage` uitgerold. De dashboardkaarten voor Radarr,
Sonarr, SABnzbd, Homepage en Traefik gebruiken Docker-statistieken via de
read-only Docker socket. Jellyfin, Proxmox VE en PBS staan ook op het dashboard;
API widgets verschijnen zodra de bijbehorende `docker_homepage_*` secret
variabelen in inventory, group vars of Ansible Vault gezet zijn.

## Jellyfin

`make ansible-jellyfin` mount de NAS media export
`10.0.1.11:/volume1/media` read-only op de Proxmox host `pepper`, bind mount
die naar `/media` in LXC `jellyfin01`, installeert Jellyfin vanuit de officiële
Jellyfin APT repository en start de service.

Voor Synology moet de NFS permission op de share minstens de Proxmox host
`pepper` (`10.0.1.12`) toelaten. `jellyfin01` is een unprivileged LXC en krijgt
de media via een host bind mount, omdat NFS mounts binnen unprivileged LXC's
door de kernel geweigerd kunnen worden.

De eerste webconfiguratie gebeurt daarna via `http://10.0.1.22:8096`.
