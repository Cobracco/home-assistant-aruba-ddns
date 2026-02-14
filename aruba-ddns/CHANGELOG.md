# Changelog

## 0.4.8

- Aggiunti timeout HTTP alle chiamate Aruba per evitare blocchi senza log.
- Aggiunti log di avanzamento nei tentativi login (principale/delegato).

## 0.4.7

- Fix runtime config reload: ricarica `options.json` a ogni ciclo per applicare modifiche anche con Save+Restart.

## 0.4.6

- Fix bootstrap OTP: prima prova `first_access_otp` sul delegated user, poi fallback su utente principale.

## 0.4.5

- Fix auth OTP: retry automatico con `delegated_user.first_access_otp` anche per login utente principale (quando delegato non configurato o incompleto).
- Migliorato riconoscimento errore OTP required con pattern piu robusto.

## 0.4.4

- Aggiunto `delegated_user.first_access_otp` per bootstrap OTP one-shot.
- Nuovo flusso auth: tenta login delegato; se Aruba richiede OTP al primo accesso, usa OTP principale per disattivare OTP del delegato e ritenta login delegato.

## 0.4.3

- Aggiunto campo `delegated_user.password` in configurazione.
- Login API Aruba ora usa credenziali delegate (`delegated_user.username/password`) quando abilitate.
- Allineata autenticazione anche nei hook Let's Encrypt.

## 0.4.2

- Semplificata gestione `delegated_user` per stabilizzare il salvataggio configurazione UI.
- Rimosso bootstrap creazione account delegato e invio email password.
- Nuovo flusso: l'utente delegato viene creato manualmente su Aruba; add-on fa solo verifica e disattivazione OTP.

## 0.4.1

- Aggiunto invio email cambio password del delegated user appena creato (`POST /api/delegatedusers/ChangePassword/email`).
- Nuovo flag config `delegated_user.send_password_email` (default `true`).

## 0.4.0

- Aggiunta sezione `delegated_user` in configurazione add-on.
- Bootstrap opzionale: crea delegated user standard Aruba se mancante.
- Disattivazione OTP opzionale sul delegated user via API Aruba.
- Migliorati log bootstrap delegated user (verifica, create, disable OTP).

## 0.3.4

- Fix anti-duplicati: deduplica record configurati uguali nello stesso ciclo (`host+type`) per evitare create multiple.
- Matching record Aruba reso piu robusto con fallback su campi alternativi (`Name/Host/Record` e `Type/RecordType/DnsType`).

## 0.3.3

- Fix matching record esistente Aruba: ora confronta sia FQDN completo sia nome relativo in zona (es. `casa`).
- Evita `CREATED` ripetuti quando il record e gia presente.

## 0.3.2

- Fix sintassi filtro `jq` nel matching record esistente (parentesi mancante).

## 0.3.1

- Fix parsing record Aruba non stringa: normalizzazione `tostring` nei filtri `jq` per evitare l'errore `explode input must be a string`.

## 0.3.0

- Rimossa completamente la gestione OTP/TOTP (campi config, log e runtime).
- Autenticazione Aruba semplificata con sola API key + username + password.

## 0.2.17

- Migliorato debug OTP: log esplicito della sorgente OTP (`manual`/`otp_secret`) e warning dedicato se la generazione da `otp_secret` fallisce.

## 0.2.16

- Fix salvataggio modifiche record DNS dalla UI Home Assistant: schema reso tollerante a stringhe vuote durante edit (`host`, `zone`, `name`, `content`).

## 0.2.15

- Aggiunto flag `otp_log_generated` per stampare nei log l'OTP usato (debug temporaneo).

## 0.2.14

- Riutilizzo del token Aruba tra i cicli DDNS: evita login OTP ad ogni intervallo.
- Aggiunta gestione token scaduto (401): reset token e nuovo login al ciclo successivo.

## 0.2.13

- Aggiunta auto-correzione record DNS quando UI salva `zone` come etichetta host (es. `zone=casa`, `host=brachini.com`).
- Ridotti errori di configurazione persistita non coerente nei record.

## 0.2.12

- Aggiunto supporto configurabile cifre OTP (`otp_digits`) per TOTP automatico da `otp_secret`.
- Default impostato a 8 cifre, compatibile con Aruba OTP.

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
