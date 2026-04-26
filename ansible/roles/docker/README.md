# Docker role

Deze role configureert Debian hosts als Docker hosts.

Verantwoordelijkheden:

- Docker packages installeren vanuit de Debian repositories.
- De Docker service inschakelen en starten.
- Beheergebruikers toevoegen aan de `docker` group.
- Valideren dat de Docker daemon bereikbaar is.

## Variabelen

Standaardwaarden staan in `defaults/main.yml`. Environment-specifieke waarden
horen later in inventory, group vars of een secret backend.
