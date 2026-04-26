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
ansible-playbook -i ansible/inventory.example.yml ansible/playbooks/pbs.yml
ansible-playbook -i ansible/inventory.example.yml ansible/playbooks/docker.yml
```

De repo bevat een `ansible.cfg` die tijdelijke bestanden onder `.ansible/tmp`
plaatst, zodat Ansible niet afhankelijk is van globale user-state.
