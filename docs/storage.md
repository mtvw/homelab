# Storage plan

## NAS

NAS IP: `10.0.1.11`

Voorlopige NFS export:

| Storage ID | Export | Nodes | Content |
| --- | --- | --- | --- |
| `nas_media` | `/volume1/media` | `pepper`, `salt` | `images`, `iso`, `vztmpl`, `backup`, `snippets` |

Controleer de exportnaam op een Proxmox node:

```sh
pvesm nfsscan 10.0.1.11
```

Als Proxmox de export als `/volume1/media` ziet, houden we `nas_media`. Als de
NAS iets anders toont, passen we `nfs_storages` aan.

Voor Jellyfin mount `pepper` de media export op `/mnt/nas/media`, waarna die
host-directory read-only in `jellyfin01` op `/media` wordt gebindmount. Synology
NFS permissions moeten daarom `10.0.1.12` toelaten. We mounten niet rechtstreeks
vanuit de unprivileged LXC, omdat de kernel NFS mounts binnen zo'n container kan
weigeren met `Operation not permitted`. De Synology export werkt hier via NFSv3
met een reserved source port; NFSv4 en `noresvport` worden door de NAS geweigerd.

Als `/media` in de container als `nobody:nogroup` met mode `d---------`
verschijnt, staat de NFS identity mapping op Synology nog niet bruikbaar voor
Jellyfin. Zet in de Synology NFS permission voor `10.0.1.12` de squash/mapping
op een gebruiker die de media-share mag lezen, bijvoorbeeld **Map all users to
admin**, of pas de Unix-permissies op de share aan zodat de gemapte gebruiker
lees- en execute-rechten heeft.

## PBS

Aanbevolen: maak een aparte NAS export voor PBS, niet dezelfde media-share.
De toepasbare configuratie staat in [`docs/pbs.md`](pbs.md).

Voorstel:

| Doel | Waarde |
| --- | --- |
| NAS export | `/volume1/pbs` |
| PBS host | `pbs01` (`10.0.1.20`) |
| Mount op `pbs01` | `/mnt/pbs` |
| PBS datastore naam | `pbs-main` |
| Proxmox storage ID | `pbs_pbs01` |

Zodra die export bestaat en PBS draait, voegen we de PBS storage en backup jobs
toe aan OpenTofu.
