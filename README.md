# Cobracco Home Assistant Add-ons

Repository add-on per Home Assistant mantenuto da **Cobracco**.

## Installazione su Home Assistant

Aggiungi il repository negli add-on di Home Assistant:

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/Cobracco/home-assistant-aruba-ddns)

Oppure manualmente:

1. Vai in **Settings** > **Add-ons** > **Add-on Store**.
2. Apri il menu in alto a destra > **Repositories**.
3. Inserisci: `https://github.com/Cobracco/home-assistant-aruba-ddns`
4. Installa l'add-on **Aruba DDNS**.

## Add-on inclusi

- `aruba-ddns`: Aggiornamento DNS dinamico su Aruba + gestione certificati Let's Encrypt (DNS-01).

## Struttura repository

- `repository.yaml`: metadata repository add-on (richiesto da Home Assistant)
- `aruba-ddns/`: add-on Home Assistant

## Compatibilita

- Home Assistant OS / Supervised (Add-on Store)
- Architetture: `aarch64`, `amd64`, `armv7`, `armhf`, `i386`

## Supporto

- Issues: [GitHub Issues](https://github.com/Cobracco/home-assistant-aruba-ddns/issues)
