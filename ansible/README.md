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
| `roles/` | Herbruikbare rollen per component |

Kopieer `inventory.example.yml` lokaal naar een niet-gecommit inventorybestand
of genereer later inventory vanuit OpenTofu output.

## Uitvoering

```sh
ansible-playbook -i ansible/inventory.example.yml ansible/playbooks/known_hosts.yml
ansible-playbook -i ansible/inventory.example.yml ansible/playbooks/pbs.yml
ansible-playbook -i ansible/inventory.example.yml ansible/playbooks/docker.yml
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
