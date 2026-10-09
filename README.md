# MikroTik Ubiquiti Auto-Configuration

Automazione completa per configurare e aggiornare antenne Ubiquiti cliente da backup salvati nel MikroTik RB951.

## 🎯 Funzionalità

- ✅ **Rilevamento automatico** del tipo di antenna collegata alla porta 5 PoE
- ✅ **Estrazione firmware** dalla memoria del MikroTik
- ✅ **Estrazione configurazione** dalla memoria del MikroTik
- ✅ **Aggiornamento firmware** automatico
- ✅ **Caricamento configurazione** post-upgrade
- ✅ **Verifica stato finale** della connessione

## 📦 Modelli Supportati

- NanoStation M5 Loco (NSM5-Loco)
- NanoStation AC Loco (Loco5AC)
- NanoBeam AC (NBE-5AC-Gen2)
- PowerBeam M5 (PBE-M5-300)

## 🔧 Requisiti

### MikroTik RB951
- RouterOS 6.43+
- Firmware salvati in: `/file` con nomenclatura: `{ANTENNA_TYPE}-{MODEL}-firmware`
- Configurazioni salvate in: `/file` con nomenclatura: `{ANTENNA_TYPE}-{MODEL}-config`
- Porta 5 configurata con PoE Output abilitato

### Antenna Ubiquiti
- SSH accessibile (credenziali default: `ubnt/ubnt`)
- Firmware AirOS 6.x o 8.x

## 📂 Struttura File nel MikroTik

```
/file/
├── nanostation-m5-loco-firmware     (file senza estensione)
├── nanostation-m5-loco-config
├── nanobeam-ac-firmware
├── nanobeam-ac-config
├── powerbeam-m5-firmware
└── powerbeam-m5-config
```

### Formato Nomenclatura

**Firmware:** `{antenna_type}-{model}-firmware`
- Esempio: `nanostation-m5-loco-firmware`

**Configurazione:** `{antenna_type}-{model}-config`
- Esempio: `nanostation-m5-loco-config`

### Mapping Modelli Ubiquiti

| Antenna | Tipo | Modello |
|---------|------|---------|
| NanoStation M5 Loco | nanostation | m5-loco |
| NanoStation AC Loco | nanostation | ac-loco |
| NanoBeam 5AC Gen2 | nanobeam | ac |
| PowerBeam M5 300 | powerbeam | m5 |

## 🚀 Installazione

1. Clona il repository nel MikroTik:
```bash
git clone https://github.com/cerbaia88-cmyk/mikrotik-ubiquiti-autoconfig.git /files/autoconfig
```

2. Carica i file di backup nel MikroTik (via Winbox o SCP)

3. Rendi eseguibile lo script:
```bash
chmod +x /files/autoconfig/deploy.sh
```

## 📋 Utilizzo

### Metodo 1: Manuale (via SSH del MikroTik)

```bash
ssh admin@192.168.88.1
/files/autoconfig/deploy.sh
```

### Metodo 2: Pianificato (ogni giorno alle 6 AM)

```bash
/system scheduler add name="ubnt-autoconfig" on-event="/files/autoconfig/deploy.sh" interval=1d start-time=06:00:00
```

### Metodo 3: Manuale da PC remoto

```bash
sshpass -p "password" ssh admin@192.168.88.1 "/files/autoconfig/deploy.sh"
```

## 📝 Configurazione nel MikroTik

### 1. Abilitare PoE sulla porta 5

```bash
/interface ethernet poe set ether5 poe-out=forced-on
```

### 2. Creare subnet dedicata per antenna

```bash
/interface bridge port remove [find interface=ether5]
/ip address add address=192.168.100.1/24 interface=ether5
/ip pool add name=ubnt-pool ranges=192.168.100.10-192.168.100.50
/ip dhcp-server add name=dhcp-ubnt interface=ether5 address-pool=ubnt-pool disabled=no
/ip dhcp-server network add address=192.168.100.0/24 gateway=192.168.100.1
```

### 3. Regole firewall (se necessario)

```bash
/ip firewall filter add chain=forward src-address=192.168.88.0/24 dst-address=192.168.100.0/24 action=accept
/ip firewall filter add chain=forward src-address=192.168.100.0/24 dst-address=192.168.88.0/24 action=accept
```

## 🔍 Log e Debugging

Lo script genera log in:
```
/file/autoconfig/logs/
├── antenna-deployment-TIMESTAMP.log
└── antenna-errors-TIMESTAMP.log
```

Visualizza log in tempo reale:
```bash
tail -f /file/autoconfig/logs/antenna-deployment-*.log
```

## ⚠️ Troubleshooting

### L'antenna non viene rilevata
- Verificare che porta 5 abbia PoE abilitato
- Controllare che l'antenna sia collegata correttamente
- Verificare che DHCP sia raggiungibile: `ping 192.168.100.10`

### Firmware non trovato nel MikroTik
- Verificare nomenclatura esatta: `{antenna_type}-{model}-firmware`
- Controllare che il file sia in `/file`
- Verificare permessi di lettura

### SSH non raggiunge l'antenna
- Verificare credenziali: `ubnt/ubnt`
- Testare manualmente: `ssh ubnt@192.168.100.10`
- Verificare firewall allow SSH (porta 22)

### Configurazione non applica
- Verificare formato file config (testo puro)
- Controllare sintassi AirOS nel file config
- Fare log dei comandi SSH per debugging

## 📚 File Importanti

- `deploy.sh` - Script principale di automazione
- `detect-antenna.sh` - Script di rilevamento modello antenna
- `upgrade-firmware.sh` - Script di upgrade firmware
- `apply-config.sh` - Script di applicazione configurazione
- `verify-status.sh` - Script di verifica stato finale

## 🔐 Sicurezza

⚠️ **Attenzione:** Le credenziali SSH sono hardcoded. Per ambienti production:

1. Usa chiavi SSH al posto di password
2. Limita accesso al file `/files/autoconfig/`
3. Abilita logging audit
4. Considra VPN per accesso remoto

## 📞 Support

Per bug e feature request: [Issues](https://github.com/cerbaia88-cmyk/mikrotik-ubiquiti-autoconfig/issues)

## 📄 Licenza

MIT License - Vedi [LICENSE](LICENSE)

---

**Versione:** 1.0.0  
**Ultimo aggiornamento:** 2024  
**Compatibilità:** RouterOS 6.43+, AirOS 6.x/8.x
