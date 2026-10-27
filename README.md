# wireguard-koreader

**WireGuard VPN plugin for KOReader on Amazon Kindle devices**

> Control and automate your WireGuard VPN tunnel directly from the KOReader interface.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Build](https://img.shields.io/github/actions/workflow/status/AntonLeskiv/wireguard-koreader/release.yml?label=build)](https://github.com/AntonLeskiv/wireguard-koreader/actions)
[![Release](https://img.shields.io/github/v/release/AntonLeskiv/wireguard-koreader)](https://github.com/AntonLeskiv/wireguard-koreader/releases/latest)

---

**[English](#english)** · **[Español](#español)**

---

## English

### What is this?

`wireguard-koreader` is a native [KOReader](https://github.com/koreader/koreader) plugin (`wireguard.koplugin`) that runs a **userspace WireGuard VPN client** directly on jailbroken Kindle e-readers.

You don't need KUAL or any external launcher — you can connect, disconnect, check status, and automate VPN connections directly from KOReader's menu.

### Features

- 📖 **Native KOReader UI**: Connect/disconnect and view status dialogs directly in KOReader.
- ⚡ **Auto-connect on Start**: Optionally activate the VPN automatically when KOReader launches.
- ⏹ **Auto-disconnect on Exit**: Automatically clean up the tunnel when exiting KOReader to preserve battery.
- 🔒 **Userspace WireGuard**: Uses `wireguard-go` + `/dev/net/tun`. No kernel modules required.
- 💾 **FAT32 Workaround**: Staged to RAM (`/var/tmp/`) for reliable execution.
- 🌐 **Split & Full Tunnel**: Supports `AllowedIPs = 10.8.0.0/24, 192.168.0.0/24` or `0.0.0.0/0`.
- 🔥 **Kindle Firewall Bypass**: Automatically manages Kindle OS `iptables` and routing tables.

### Installation

1. Download `wireguard.koplugin.zip` from [Releases](https://github.com/AntonLeskiv/wireguard-koreader/releases/latest).
2. Connect your Kindle via USB.
3. Extract `wireguard.koplugin` into:
   ```
   /mnt/us/koreader/plugins/wireguard.koplugin/
   ```
4. Copy `wg0.conf.example` to `wg0.conf` in that folder and fill in your keys and endpoint.
5. Safely eject and open KOReader.
6. Find **WireGuard VPN** in the top menu bar!

---

## Español

### ¿Qué es esto?

`wireguard-koreader` es un plugin nativo para [KOReader](https://github.com/koreader/koreader) (`wireguard.koplugin`) que ejecuta un **cliente VPN WireGuard en espacio de usuario** directamente en dispositivos Amazon Kindle con jailbreak.

No necesitas KUAL: controlas todo desde el menú de KOReader.

### Características

- 📖 **Interfaz nativa KOReader**: Conecta, desconecta y mira el estado con mensajes flotantes nativos.
- ⚡ **Auto-conectar al iniciar**: Conecta la VPN automáticamente al abrir KOReader.
- ⏹ **Auto-desconectar al salir**: Cierra el túnel al salir de KOReader para ahorrar batería.
- 🔒 **Sin módulos de kernel**: Funciona con `wireguard-go` y `/dev/net/tun`.
- 💾 **Bypass de FAT32**: Copia los binarios a `tmpfs` en memoria RAM.
- 🌐 **Split-Tunnel y Full-Tunnel**: Soporta subredes locales y 0.0.0.0/0.

### Instalación

1. Descarga `wireguard.koplugin.zip` desde [Releases](https://github.com/AntonLeskiv/wireguard-koreader/releases/latest).
2. Conecta tu Kindle por USB al PC.
3. Extrae la carpeta `wireguard.koplugin` en:
   ```
   /mnt/us/koreader/plugins/wireguard.koplugin/
   ```
4. Copia `wg0.conf.example` a `wg0.conf` en esa carpeta y edita tus claves.
5. Expulsa el Kindle y abre KOReader.
6. ¡Encontrarás **WireGuard VPN** en el menú superior!

### Licencia

[MIT](LICENSE)