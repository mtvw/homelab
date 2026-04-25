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

## PBS

Aanbevolen: maak een aparte NAS export voor PBS, niet dezelfde media-share.

Voorstel:

| Doel | Waarde |
| --- | --- |
| NAS export | `/volume1/pbs` |
| Mount op `tumuric` | `/mnt/pbs` |
| PBS datastore naam | `pbs-main` |
| Proxmox storage ID | `pbs_tumuric` |

Zodra die export bestaat en PBS draait, voegen we de PBS storage en backup jobs
toe aan OpenTofu.
