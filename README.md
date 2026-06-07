# The Last Ninja – Roblox Edition

Ein kooperatives Roblox-Actionspiel für **2–4 Spieler** im Geiste des C64-Klassikers *The Last Ninja (1987)*.  
Vier Ninja-Krieger mit unterschiedlichen Stärken kämpfen gemeinsam, lösen Rätsel die echte Teamarbeit erfordern, und stellen sich dem bösen Shogun Kunitoki.

## Kernprinzipien

- **Kooperation ist zwingend** – Rätsel und Bosskämpfe sind ohne Teamarbeit nicht lösbar
- **Atmosphäre über Action** – Stimmung, Musik, Umgebung sind genauso wichtig wie Gameplay
- **Klassen ergänzen sich** – Jeder Ninja bringt etwas ein, das die anderen brauchen
- **Niemand bleibt zurück** – Revive-System stellt sicher, dass alle zusammen vorankommen

---

## Die vier Ninja-Klassen

| Klasse | Stärke | Spezialfähigkeit | Rolle |
|--------|--------|------------------|-------|
| ⚔️ **Kenshi** | Hohe HP, Nahkampf | Kiai-Schrei – lähmt Gegner kurz | Tank / Frontlinie |
| 🏹 **Kassha** | Hohe Reichweite | Feuerpfeil – entzündet Fackelrätsel aus Distanz | Distanzkampf / Rätsel |
| 🌪️ **Kaze** | Höchste Beweglichkeit | Windschritt – Kurztelport, überwindet Fallen | Scout / Ausweichen |
| 🧪 **Kunoichi** | Unterstützung | Heilrauch – heilt alle Teamkollegen in der Nähe | Support / Heilung |

---

## Welt & Gebiete

| # | Gebiet | Co-op-Rätsel |
|---|--------|--------------|
| 1 | Ninjato-Garten | 2 Spieler halten Druckplatten gleichzeitig |
| 2 | Wächterwald | Kassha entzündet Fackeln, Kenshi bewacht |
| 3 | Tempel der Schatten | Kaze überspringt Falle, zieht Hebel für andere |
| 4 | Palasthof | Zwei Teams: Kampf + Rätsel gleichzeitig |
| 5 | Thron des Shogun | Bosskampf – alle 4 Klassen-Fähigkeiten nötig |

---

## Steuerung

| Aktion | Taste |
|--------|-------|
| Leichter Angriff | Linke Maustaste |
| Schwerer Angriff | E |
| Wurfwaffe | Rechte Maustaste |
| Ausweichen | Doppel-Tap WASD |
| Block | Q (gehalten) |
| Spezialfähigkeit | F (30s Cooldown) |

---

## Projektstruktur

```
src/
  ReplicatedStorage/
    Modules/          ← Geteilte Logik (Client + Server)
    RemoteEvents/     ← Event-Definitionen
  ServerScriptService/
    *.server.lua      ← Server-seitige Spiel-Logik
  StarterPlayerScripts/
    *.client.lua      ← Client-seitige Steuerung & UI
docs/
  GAMEDESIGN.md       ← Vollständiges Game Design Dokument
```

---

## Entwicklungsfahrplan

- **Phase 1** – Co-op Fundament: Klassenauswahl, Kampf, Down-State, Revive, erstes Rätsel
- **Phase 2** – Klassen & Content: Alle 4 Klassen, Combo-Finisher, Gebiet 1 komplett
- **Phase 3** – Alle Gebiete: Gebiete 2–5, Shogun-Bosskampf, Sound, DataStore
- **Phase 4** – Polish & Release: Balancing, Lobby, Mobile, Beta-Test, Veröffentlichung

Detaillierter Fahrplan: siehe [docs/GAMEDESIGN.md](docs/GAMEDESIGN.md)

---

## Setup

1. [Roblox Studio](https://www.roblox.com/create) kostenlos herunterladen
2. Neues Projekt → **Baseplate** Template
3. Dateien aus `src/` in die entsprechenden Roblox-Ordner importieren
4. Im **Test**-Tab → "Players" auf 2 setzen für lokalen Multiplayer-Test

> **Tipp:** Testet von Anfang an mit 2 simulierten Spielern. Multiplayer-Bugs sind später schwer zu finden.

---

*Projekt gestartet: 07.06.2026*
