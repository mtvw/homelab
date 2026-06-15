# HTTPS voor thuis.infinita.be

De Docker stack gebruikt Traefik als reverse proxy. Traefik gebruikt standaard
een bestaand wildcardcertificaat, redirect HTTP naar HTTPS en leest certificate
config vanuit `/opt/media-stack/config/traefik`.

Let op wildcard-dekking:

- `*.infinita.be` dekt `thuis.infinita.be`, maar niet
  `radarr.thuis.infinita.be`.
- Voor de huidige hostnames heb je `*.thuis.infinita.be` nodig, of een
  certificaat met SAN's voor de concrete hostnames.
- Een alternatief is de hostnames verplaatsen naar `radarr.infinita.be`,
  `sonarr.infinita.be`, enzovoort; die vallen wel onder `*.infinita.be`.

## Stap voor stap

1. Controleer welk wildcardcertificaat je hebt. Voor de huidige routes moet het
   certificaat `*.thuis.infinita.be` dekken.
2. Zet het Plesk PEM-bestand op `docker01`, of laat Ansible het kopieren vanaf
   je workstation. De standaard doelpad voor een gecombineerd PEM-bestand is:

   ```text
   /opt/media-stack/config/traefik/certs/wildcard.pem
   ```

   Traefik gebruikt datzelfde bestand dan als `certFile` en `keyFile`.
3. Zet het Plesk-bestand lokaal bij voorkeur onder `.secrets/traefik/`:

   ```text
   .secrets/traefik/Lets_Encrypt_thuis.infinita.be.pem
   ```

   De repo negeert `.secrets/` al via `.gitignore`.
4. Om Ansible het Plesk-bestand integraal te laten kopieren, zet je lokaal in
   inventory of group vars:

   ```yaml
   docker_traefik_combined_pem_src: .secrets/traefik/Lets_Encrypt_thuis.infinita.be.pem
   ```

   Het bestand mag `CERTIFICATE REQUEST`, `PRIVATE KEY` en `CERTIFICATE` blokken
   bevatten. Traefik gebruikt de certificate en private key PEM-blokken.
5. Als je toch aparte bestanden wilt gebruiken, kan dat ook. De standaard
   doelpaden zijn:

   ```text
   /opt/media-stack/config/traefik/certs/wildcard.crt
   /opt/media-stack/config/traefik/certs/wildcard.key
   ```

   Om Ansible die bestanden te laten kopieren, zet je lokaal in inventory of
   group vars:

   ```yaml
   docker_traefik_cert_src: /pad/naar/fullchain.pem
   docker_traefik_key_src: /pad/naar/privkey.pem
   ```

   Zet deze bestanden niet in git. De private key blijft secret materiaal.
6. Forward op je router TCP poort `443` naar `docker01` (`10.0.1.21`) als je de
   services extern wilt benaderen. Poort `80` mag ook naar `docker01` blijven
   voor de HTTP naar HTTPS redirect, maar is niet nodig voor certificaatuitgifte
   wanneer je een bestaand certificaat gebruikt.
7. Rol de configuratie uit:

   ```sh
   make ansible-known-hosts
   make ansible-docker
   ```

8. Controleer op `docker01` de Traefik logs als HTTPS niet werkt:

   ```sh
   docker logs traefik
   ```

Daarna horen de routes een certificaat uit je bestaande wildcardset te krijgen:

```text
https://thuis.infinita.be
https://jellyfin.thuis.infinita.be
https://radarr.thuis.infinita.be
https://sonarr.thuis.infinita.be
https://sabnzbd.thuis.infinita.be
https://prowlarr.thuis.infinita.be
https://seerr.thuis.infinita.be
https://readarr.thuis.infinita.be
https://audiobookshelf.thuis.infinita.be
https://wealthfolio.thuis.infinita.be
https://homepage.thuis.infinita.be
https://wud.thuis.infinita.be
```

## Let's Encrypt op de homelab

Als je later toch wilt dat Traefik zelf certificaten aanvraagt, zet dan ACME
aan:

```yaml
docker_traefik_acme_enabled: true
docker_traefik_provided_cert_enabled: false
docker_traefik_acme_email: matthias@infinita.be
```

Test dan eerst tegen de Let's Encrypt staging CA om rate limits te vermijden:

```yaml
docker_traefik_acme_ca_server: https://acme-staging-v02.api.letsencrypt.org/directory
```

## Wanneer HTTP-01 niet past

HTTP-01 werkt alleen als Let's Encrypt je homelab publiek kan bereiken op poort
`80`. Als je de services uitsluitend intern wilt houden, of je ISP inkomende
poorten blokkeert, gebruik dan DNS-01 met een DNS-provider API token. Dat is ook
de route voor wildcardcertificaten zoals `*.thuis.infinita.be`.
