# Changelog

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
