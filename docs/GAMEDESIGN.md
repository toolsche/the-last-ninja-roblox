# The Last Ninja – Roblox Edition
## Game Design & Entwicklungsfahrplan

---

## Vision

Ein kooperatives Roblox-Actionspiel für **2–4 Spieler** im Geiste des C64-Klassikers **The Last Ninja (1987)**: Vier Ninja-Krieger mit unterschiedlichen Stärken kämpfen gemeinsam, lösen Rätsel, die echte Teamarbeit erfordern, und stellen sich dem bösen Shogun Kunitoki.

### Kernprinzipien
- **Kooperation ist zwingend**: Rätsel und Bosskämpfe sind ohne Teamarbeit nicht lösbar
- **Atmosphäre über Action**: Stimmung, Musik, Umgebung sind genauso wichtig wie Gameplay
- **Klassen ergänzen sich**: Jeder Ninja bringt etwas ein, das die anderen brauchen
- **Niemand bleibt zurück**: Reviersystem stellt sicher, dass alle zusammen vorankommen

---

## Die vier Ninja-Klassen

Jeder Spieler wählt zu Beginn eine Klasse. Die Klassen sind komplementär — manche Rätsel erfordern das Zusammenspiel bestimmter Fähigkeiten.

| Klasse | Stärke | Spezialfähigkeit | Rolle im Team |
|--------|--------|------------------|---------------|
| ⚔️ **Kenshi** (Schwertkämpfer) | Hohe HP, Nahkampf | **Kiai-Schrei** – lähmt alle Gegner in der Nähe kurz | Tank / Frontlinie |
| 🏹 **Kassha** (Bogenschützin) | Hohe Reichweite | **Feuerpfeil** – entzündet Fackelrätsel aus der Distanz | Distanzkampf / Rätsel |
| 🌪️ **Kaze** (Windninja) | Höchste Beweglichkeit | **Windschritt** – teleportiert kurz, kann Fallen überwinden | Scout / Ausweichen |
| 🧪 **Kunoichi** (Giftmeisterin) | Unterstützung | **Heilrauch** – heilt alle Teamkollegen in der Nähe | Support / Heilung |

> Das Spiel ist auch mit 2 oder 3 Spielern spielbar — dann wählen Spieler aus allen 4 Klassen; KI füllt nicht auf. Mit nur 1 Spieler ist es zu schwer (by design).

---

## Was ist in Roblox realistisch?

### Gut umsetzbar (Phase 1–2)
- Multiplayer-Bewegung und -Kamera (Roblox macht das nativ)
- Nahkampf- und Fernkampfsystem mit Klassenwaffen
- Gegenstandssystem: Waffen, Schlüssel, Heilgegenstände aufheben und teilen
- Co-op-Rätsel (Druckplatten, Fackelrätsel, Sequenzrätsel)
- Revive-System: Ausgeknockte Spieler wiederbeleben
- Schwierigkeitsskalierung nach Spielerzahl

### Anspruchsvoll (Phase 3)
- Klassenspezifische Spezialattacken mit Cooldown
- Bosskämpfe die auf Spieleranzahl reagieren
- Fortgeschrittene Gegner-KI (Zielt auf isolierte Spieler)
- Inventarsystem und Gegenstände teilen

### Erstmal weglassen
- Echte Stealth-Mechanik
- PvP-Elemente
- Komplexe Physik-Rätsel

---

## Die Welt

Fünf Gebiete, jedes mit mindestens einem Rätsel das **echte Teamarbeit** erfordert:

| # | Gebiet | Atmosphäre | Co-op-Rätsel |
|---|--------|------------|--------------|
| 1 | **Ninjato-Garten** | Kirschblüten, Teich | 2 Spieler halten Druckplatten gleichzeitig |
| 2 | **Wächterwald** | Bambus, Nebel | Kassha entzündet Fackeln, Kenshi bewacht |
| 3 | **Tempel der Schatten** | Dunkel, Fallen | Kaze überspringt Falle, zieht Hebel für andere |
| 4 | **Palasthof** | Prächtig, Wellen | Zwei Teams teilen sich: Kampf + Rätsel gleichzeitig |
| 5 | **Thron des Shogun** | Episch | Bosskampf — alle 4 Klassen-Fähigkeiten gleichzeitig nötig |

---

## Kernmechaniken

### Kampfsystem

```
Leichter Angriff  → linker Mausklick         (schnell, wenig Schaden)
Schwerer Angriff  → E                          (langsam, viel Schaden)
Wurfwaffe         → rechter Mausklick          (Shuriken / Pfeil werfen)
Ausweichen        → Doppel-Tap WASD            (kurze Unverwundbarkeit)
Block             → Q gedrückt halten          (reduziert Schaden)
Spezialfähigkeit  → F (Cooldown: 30 Sek.)     (klassenabhängig)
```

**Klassenwaffen:**
- Kenshi → Katana + Shurikens
- Kassha → Bogen (unbegrenzt) + Feuerpfeile (begrenzt)
- Kaze → Nunchaku (sehr schnell) + Rauchbomben
- Kunoichi → Kusarigama + Giftbomben

### Co-op-Rätsel & Mechaniken

**Rätseltypen:**

1. **Simultane Druckplatten** — 2+ Spieler stehen gleichzeitig auf markierten Platten
2. **Fernzünd-Rätsel** — Kassha schießt Feuerpfeil auf Fackel, Tür öffnet sich für andere
3. **Boost-Sprung** — Kenshi hält Hände, Kaze springt von ihm ab auf unerreichbare Plattform
4. **Ablenkungsmanöver** — Ein Spieler zieht Gegner weg, andere schleichen durch
5. **Kettenrätsel** — Spieler A zieht Hebel → öffnet Weg für B → B zieht Hebel → öffnet Weg für alle

**Co-op-Kampfmechaniken:**
- **Combo-Finisher**: Wenn zwei Spieler denselben Gegner treffen, löst ein mächtiger gemeinsamer Finisher aus
- **Revive**: Ausgeknockte Spieler liegen 30 Sek. auf dem Boden; ein Teamkollege muss 3 Sek. neben ihnen stehen
- **Teilen**: Heilkräuter können per Knopfdruck an den nächsten Teamkollegen weitergegeben werden

### Schwierigkeitsskalierung

| Spieler | Gegner-HP | Gegneranzahl | Bossphasen |
|---------|-----------|--------------|------------|
| 2 | 70% | 60% | 2 Phasen |
| 3 | 85% | 80% | 2 Phasen |
| 4 | 100% | 100% | 3 Phasen |

### Gegner-KI

Die KI ist co-op-bewusst — Gegner versuchen aktiv das Team zu splitten:
- **Wächter** — patrouillieren, greifen den nächsten Spieler an
- **Bogenschütze** — zielt auf isolierte / verwundete Spieler
- **Elite-Ninja** — versucht ausgeknockte Spieler vom Revive abzuschneiden
- **Schamane** (Bosskopie) — beschwört Minions wenn Spieler zu nah beieinander sind (erzwingt Trennung)

---

## Technische Architektur (Co-op Multiplayer)

### Grundprinzip: Server ist Autorität
In Roblox läuft der **Server** als einzige Wahrheitsquelle. Clients senden Eingaben, der Server verarbeitet alles (Schaden, Rätselzustände, Gegner). So gibt es kein Cheating und alle Spieler sehen dieselbe Welt.

### Ordnerstruktur

```
ReplicatedStorage/
  Modules/
    WeaponSystem.lua        ← Waffen-Logik (geteilt Client+Server)
    EnemyAI.lua             ← Gegner-Verhalten
    ItemSystem.lua          ← Gegenstände aufheben/teilen
    ClassDefinitions.lua    ← Klassen-Stats und Fähigkeiten
    PuzzleSystem.lua        ← Rätsel-Zustände (Druckplatten etc.)
  RemoteEvents/
    PlayerAttack            ← Client → Server: Angriff
    UseSpecial              ← Client → Server: Spezialfähigkeit
    RevivePlayer            ← Client → Server: Wiederbelebung
    PuzzleStateChanged      ← Server → alle Clients: Rätselupdate
    PlayerDowned            ← Server → alle Clients: Spieler down

ServerScriptService/
  GameManager.server.lua    ← Rundenstart, Zonenübergänge
  EnemySpawner.server.lua   ← Gegner spawnen & KI-Tick
  CombatServer.server.lua   ← Schaden berechnen (autoritativ)
  PuzzleServer.server.lua   ← Rätselzustände verwalten

StarterPlayerScripts/
  PlayerController.client.lua  ← Bewegung, Kamera (lokal)
  CombatClient.client.lua      ← Eingabe → RemoteEvent senden
  HUD.client.lua               ← HP, Cooldown, Teamstatus-UI
  ClassSelector.client.lua     ← Klassenauswahl beim Start

Workspace/
  Zones/
    Zone1_Garden/
    Zone2_Forest/
    Zone3_Temple/
    Zone4_Palace/
    Zone5_Throne/
```

### Wichtige Roblox-Konzepte für Co-op

| Konzept | Wofür | Priorität |
|---------|-------|-----------|
| `RemoteEvent` | Spieler-Eingaben sicher an Server senden | Sofort |
| `BindableEvent` | Server-interne Kommunikation | Sofort |
| `Players:GetPlayers()` | Alle verbundenen Spieler abfragen | Sofort |
| `Humanoid.Died` | Spieler-Down-Erkennung | Phase 1 |
| `PathfindingService` | Gegner-Navigation | Phase 2 |
| `DataStoreService` | Fortschritt speichern | Phase 3 |

---

## Entwicklungsfahrplan

### Phase 1 – Co-op Fundament (3–4 Wochen)
**Ziel: 2 Spieler können gemeinsam durch ein Testlevel**

- [ ] Klassenauswahl-UI beim Spielstart
- [ ] Spieler-Controller mit Klassenunterschieden (Geschwindigkeit, HP)
- [ ] Einfaches Nahkampf-System via RemoteEvents (Server-autoritativ)
- [ ] HP-System + Down-State (nicht sofort tot, sondern "ausgeknockt")
- [ ] Revive-Mechanik: Teamkollege belebt wieder
- [ ] Einen Wächter-Gegner mit Patrouille
- [ ] Erste Druckplatten-Rätsel (2 Spieler gleichzeitig)
- [ ] Schlüssel aufheben und teilen

**Meilenstein:** 2 Ninjas laufen durch Testlevel, kämpfen, einer wird down, der andere belebt ihn, gemeinsam lösen sie ein Druckplatten-Rätsel.

---

### Phase 2 – Klassen & Content (4–5 Wochen)
**Ziel: Alle 4 Klassen spielbar, Gebiet 1 komplett**

- [ ] Alle 4 Klassen mit Spezialfähigkeiten implementieren
- [ ] Combo-Finisher (2 Spieler treffen denselben Gegner)
- [ ] Ninjato-Garten vollständig bauen
- [ ] 3 verschiedene Gegnertypen inkl. Co-op-KI
- [ ] HUD: eigene HP + Teamstatus aller Mitspieler
- [ ] Schwierigkeitsskalierung nach Spielerzahl
- [ ] Heilkräuter teilen

**Meilenstein:** Gebiet 1 komplett mit 2–4 Spielern durchspielbar; alle Klassen fühlen sich unterschiedlich an.

---

### Phase 3 – Alle Gebiete (5–7 Wochen)
**Ziel: Komplettes Spiel von Anfang bis Boss**

- [ ] Gebiet 2–5 bauen mit je einem Co-op-Rätsel
- [ ] Shogun-Bosskampf (3 Phasen, alle 4 Klassen-Fähigkeiten nötig)
- [ ] Sound & Musik (japanische Ambient-Tracks)
- [ ] Partikeleffekte (Blätter, Kampffunken, Heilrauch)
- [ ] DataStore: Spielfortschritt pro Gruppe speichern

---

### Phase 4 – Polish & Release
- [ ] Balancing bei 2, 3 und 4 Spielern separat testen
- [ ] Lobby-System (Spieler warten auf alle vor Beginn)
- [ ] Mobile-Kompatibilität prüfen
- [ ] Game-Icon, Thumbnail, Beschreibung
- [ ] Beta-Test mit 4 Spielern
- [ ] Veröffentlichung auf Roblox

---

## Erste Schritte in Roblox Studio

1. **Roblox Studio** kostenlos unter roblox.com/create herunterladen
2. Neues Projekt → **Baseplate** Template wählen
3. Im **Test**-Tab: "Players" auf 2 setzen → simuliert 2 Spieler lokal
4. Mit der Klassenauswahl-UI beginnen — das ist das erste, was Spieler sehen

> **Tipp für Multiplayer:** Testet von Anfang an mit 2 simulierten Spielern in Roblox Studio (Test → Players → 2). Fehler die nur im Multiplayer auftreten, sind später schwer zu finden.

---

*Erstellt: 07.06.2026 | Projekt: The Last Ninja – Roblox Edition*
