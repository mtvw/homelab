# Ansible

Ansible beheert OS- en serviceconfiguratie nadat OpenTofu de machines heeft
aangemaakt en cloud-init ze bereikbaar heeft gemaakt.

## Structuur

| Pad | Doel |
| --- | --- |
| `inventory.example.yml` | Voorbeeldinventory zonder secrets |
| `playbooks/pbs.yml` | PBS configuratie voor `pbs01` |
| `roles/` | Herbruikbare rollen per component |

Kopieer `inventory.example.yml` lokaal naar een niet-gecommit inventorybestand
of genereer later inventory vanuit OpenTofu output.

## Uitvoering

```sh
ansible-playbook -i ansible/inventory.example.yml ansible/playbooks/pbs.yml
```

De repo bevat een `ansible.cfg` die tijdelijke bestanden onder `.ansible/tmp`
plaatst, zodat Ansible niet afhankelijk is van globale user-state.

Het playbook is voorlopig een skelet. De bedoeling is dat PBS-configuratie hier
idempotent wordt gemaakt in plaats van als handmatig runbook te blijven bestaan.
