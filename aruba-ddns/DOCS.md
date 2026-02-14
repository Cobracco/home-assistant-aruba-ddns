# Home Assistant App: Aruba DDNS

App Home Assistant per aggiornare record DNS Aruba verso IP pubblico del server,
con supporto multi-dominio/multi-record e certificati Let's Encrypt (DNS-01).

## Installazione

1. In Home Assistant vai su **Settings > Apps > Install app**.
2. Aggiungi il repository add-on che contiene `aruba-ddns`.
3. Installa **Aruba DDNS**.

## Configurazione

Esempio completo:

```yaml
api_base: https://api.arubabusiness.it
api_key: "YOUR_ARUBA_API_KEY"
username: "your-user"
password: "your-password"
delegated_user:
  enabled: true
  username: "clientcode.ha"
  password: "delegated-password"
  first_access_otp: "12345678"
seconds: 300
ipv4: ""
ipv6: ""
records:
  - host: www.domain.tld
    zone: ""
    name: ""
    type: A
    create_if_missing: true
    content: ""
  - host: app.domain.tld
    zone: ""
    name: ""
    type: A
    create_if_missing: true
    content: ""
lets_encrypt:
  accept_terms: true
  algo: secp384r1
  certfile: fullchain.pem
  keyfile: privkey.pem
  domains:
    - example.it
    - '*.example.it'
  zones:
    - example.it
  propagation_seconds: 120
```

## Gestione certificati

- Se `lets_encrypt.accept_terms=true`, l'add-on:
  - registra dehydrated su Let's Encrypt
  - crea/rinnova certificati ogni 12 ore (cron interno)
  - usa challenge DNS-01 creando record TXT `_acme-challenge` su Aruba
  - copia certificato e chiave in `/ssl/<certfile>` e `/ssl/<keyfile>`

Per usare i certificati in Home Assistant Core (`configuration.yaml`):

```yaml
http:
  ssl_certificate: /ssl/fullchain.pem
  ssl_key: /ssl/privkey.pem
```

## Note operative

- `records` supporta più domini e più host nello stesso loop.
- `delegated_user` non crea account: crea tu l'utente dal pannello Aruba.
- Se `delegated_user.enabled=true`, l'add-on:
  - usa `delegated_user.username` + `delegated_user.password` per il login API Aruba
  - verifica che `delegated_user.username` esista
  - prova a disattivare OTP su quel delegated user (`PUT /api/delegatedusers/OTP/Disactivate`)
- Se `delegated_user.enabled=true` ma password mancante, usa fallback alle credenziali principali (`username`/`password`).
- Se al primo login del delegato Aruba risponde `One-time password required`, imposta temporaneamente
  `delegated_user.first_access_otp` (OTP account principale): l'add-on fa bootstrap,
  disattiva OTP del delegato e poi passa automaticamente al login con delegato.
- Dopo bootstrap riuscito, svuota `delegated_user.first_access_otp`.
- Per vedere in lista il dominio completo nella UI, compila `host` (FQDN completo).
- `host` e obbligatorio e viene usato per la voce in lista.
- Se `host` e compilato, il valore di `name` viene ignorato.
- `zone` puo restare vuoto: l'add-on prova a derivarla da `host`.
- Se `content` è vuoto:
  - per record `A`, usa IPv4 pubblico (auto-detect con ipify)
  - per record `AAAA`, usa IPv6 configurato (o URL specificato in `ipv6`)
- Se il record esiste e il contenuto è già corretto, non applica update (`NOCHANGE`).
- Se non esiste e `create_if_missing=true`, crea il record.
- Per certificati wildcard, inserire la zona DNS in `lets_encrypt.zones`.

## Riferimenti API Aruba usati

- `POST /auth/token` (header `Authorization-Key`)
- `GET /api/domains/dns/{zone}/details`
- `PUT /api/domains/dns/record` (Domains_UpdateRecord)
- `POST /api/domains/dns/record` (Domains_AddRecord)
- `DELETE /api/domains/dns/record/{idRecord}` (cleanup challenge TXT)
- `GET /api/delegatedusers/{username}/detail` (verifica delegated user)
- `PUT /api/delegatedusers/OTP/Disactivate` (disattivazione OTP delegated user)

Fonti:
- https://api.arubabusiness.it/docs/
- https://api.arubabusiness.it/docs/ver/v1
