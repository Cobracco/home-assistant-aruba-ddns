# Changelog

## 0.2.11

- Forzata visualizzazione host completo in lista: `host` ora obbligatorio nei record DNS.
- `zone` ora opzionale: se vuoto, viene derivata automaticamente da `host`.

## 0.2.10

- Aggiornati esempi record DNS: rimosso `example.it`, ora default con terzo livello (`www.domain.tld`).

## 0.2.9

- Corrette chiamate Aruba DNS API: ora inviano sia `Authorization-Key` sia `Authorization: Bearer <token>`.
- Fix 401 in lettura/aggiornamento record dopo login riuscito.

## 0.2.8

- Aggiunto campo `host` (FQDN completo) nei record DNS per mostrare in lista il dominio completo nella UI Home Assistant.
- Compatibilita mantenuta: se `host` e vuoto, continua a usare `zone` + `name`.

## 0.2.7

- Aggiunto supporto TOTP automatico via `otp_secret` (Base32) per autenticazione Aruba con 2FA.
- Installato `oathtool` nel container per generazione OTP runtime.
- Aggiornati help UI e documentazione per i nuovi campi OTP.

## 0.2.6

- Aggiunti help interattivi UI per tutti i campi configurazione (`translations/en.yaml` e `translations/it.yaml`).

## 0.2.5

- Corretto flusso auth Aruba: password inviata in chiaro di default (come da docs Aruba Business).
- Aggiunta opzione `password_base64` (default `false`) per compatibilita legacy.
- Migliorato logging auth: ora mostra dettaglio errore HTTP/body su `/auth/token`.

## 0.2.4

- Rimossa dipendenza dal download esterno di `dehydrated` in build.
- Aggiunto `dehydrated` direttamente in `rootfs/usr/bin` per rendere il build più affidabile.

## 0.2.3

- Fix build immagine add-on: sorgente `dehydrated` corretta verso fork compatibile (`Xebozone/dehydrated`).

## 0.2.2

- Aggiunti `icon.png` e `logo.png` per integrazione visuale nello store add-on Home Assistant.

## 0.2.1

- Allineamento metadata repository e URL pubblici.
- Migliorata documentazione per installazione da GitHub su Home Assistant.

## 0.2.0

- Supporto DNS dinamico Aruba multi-dominio/multi-record.
- Supporto Let's Encrypt DNS-01 con update TXT su Aruba.
- Deploy certificati in `/ssl`.
