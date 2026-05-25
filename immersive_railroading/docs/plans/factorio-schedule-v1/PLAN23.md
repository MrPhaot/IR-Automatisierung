# `route_book_editor` + `station_schedule`: Strukturierter Schedule-Editor mit eigenständigen Redstone-Regeln, Menüpflicht und robustem Modal-Verhalten

## Summary
- `wait` bleibt alleinige Abfahrtslogik.
- `redstone` wird als eigene Regelmenge pro Schedule-Entry editiert und ausgewertet.
- Der Schedule-Editor wird klar in getrennte Bereiche aufgeteilt:
  - `Schedule Settings`
  - `Wait Conditions`
  - `Selected Wait Condition`
  - `Redstone Rules`
  - `Selected Redstone Rule`
  - `Selected Redstone Condition`
- Alle Werte mit endlicher Auswahl werden nur noch über Menüs gewählt.
- Der bisherige per-Wait-Condition-Redstone-Anhang (`condition.redstone`) ist nur noch Legacy-Format. Der neue Editor darf ihn nicht mehr als Primärmodell verwenden.
- Tier-2-Modal-Klickverhalten, I/O-Eingabe und Einfügen zwischen Conditions werden explizit und vollständig festgelegt.

## Problem Statement
Der aktuelle Stand ist fachlich und technisch inkonsistent:

- Runtime und Validation kennen bereits `entry.redstone.rules`.
- Der Editor modelliert Redstone aber noch über `condition.redstone` an Wait-Conditions und leitet daraus beim Submit `redstone.rules` ab.
- Dadurch entsteht eine Brückenlösung statt eines echten Redstone-Editors.
- Die `+`-Slots im Chain-Builder sind nicht als echte Einfüge-Slots zwischen bestehenden Bedingungen modelliert.
- Teile der UI verwenden bei Choice-Feldern noch Inline-Cycling statt eines Menüs.
- Der Schedule-Editor trennt Wait- und Redstone-Bearbeitung visuell und fachlich nicht sauber genug.

Ein einfaches Reprompting mit einem weich formulierten Plan ist deshalb riskant. Der Zielzustand muss so präzise beschrieben sein, dass kein Agent wieder auf der halben Zwischenlösung landet.

## Goals
- Echter Editor für `entry.redstone.rules`, nicht für `condition.redstone`.
- Wait- und Redstone-Logik fachlich getrennt, aber beide an denselben Stationshalt gekoppelt.
- Robuste Einfügesemantik zwischen bestehenden Conditions.
- Menüpflicht für alle endlichen Optionen.
- Klare visuelle Struktur des Schedule-Editors.
- Rückwärtskompatibilität für bestehende Bücher mit Legacy-`condition.redstone`.

## Non-Goals
- Kein Ausbau auf mehrere Schedule-Entries in diesem Patch. Es bleibt bei `entries[1]`.
- Keine automatische Migration vorhandener Legacy-Daten beim bloßen Öffnen.
- Kein Redstone-Departure-Mode im neuen Modell.
- Keine freie Texteingabe für endliche Enum-Werte.

## Data Model
### Schedule Entry
Neues Primärmodell im Editor und zur Laufzeit:

```lua
entry = {
  route = "1_zu_2",
  wait = {
    groups = {
      {
        { type = "cargo_percent", comparator = ">=", value = 90, scope = "station_any_detector" },
      },
    },
  },
  redstone = {
    rules = {
      {
        output = "loader",
        groups = {
          {
            { type = "time_passed", seconds = 5 },
            { type = "cargo_percent", comparator = ">=", value = 90, scope = "station_any_detector" },
          },
        },
      },
    },
  },
}
```

### Wait Semantics
- `wait.groups[*]`:
  - Conditions innerhalb einer Gruppe sind `AND`
  - Gruppen sind `OR`
- `wait` allein bestimmt die Abfahrt

### Redstone Semantics
- `redstone.rules[*]`:
  - jede Regel steuert genau einen Output (`rule.output`)
  - `rule.groups[*]` verwendet dieselbe Bool-Semantik wie `wait`
- Redstone-Regeln sind nur aktiv, solange:
  - der Zug an der Zielstation steht
  - der Entry noch auf Abfahrt wartet
- Redstone-Regeln beeinflussen die Abfahrt nicht
- Es gibt im neuen Modell kein `redstone.mode`

### Legacy Format
Altes Format:

```lua
condition.redstone = {
  output = "loader",
  mode = "while_pending" or "on_departure_pulse",
}
```

Regeln:
- Runtime und Validation dürfen Legacy weiter akzeptieren
- der neue Editor schreibt ausschließlich `entry.redstone.rules`
- wenn ein Entry Legacy-`condition.redstone` enthält:
  - Editor zeigt Warnung
  - Editor behandelt Legacy als read-only Hinweis
  - Editor baut Legacy nicht implizit in die neue Struktur um

## Runtime Changes
### `station_schedule.lua`
`tick_wait_session(...)` bleibt für `wait` zuständig.

Zusätzlich:
- `evaluate_condition_groups(groups, station, detector_snapshots, session, now)`:
  - generischer Bool-Evaluator für Wait- und Redstone-Gruppen
- `tick_redstone_rules(session, now)`:
  - wertet `entry.redstone.rules` separat aus
  - setzt Output aktiv/inaktiv je nach Regelergebnis

Pflichtverhalten:
- solange `wait.complete == false`:
  - Redstone-Regeln pro Tick auswerten
- sobald `wait.complete == true` oder Session endet:
  - alle durch Schedule gesetzten Outputs zurücksetzen

Legacy:
- vorhandene Legacy-Auswertung von `condition.redstone` darf vorerst bestehen bleiben
- sie ist aber nicht mehr Editorziel
- Editor und Tests müssen klar zwischen Legacy und Primärmodell unterscheiden

## Editor Architecture
### Top-Level Modal Structure
Der Edit-Dialog für Schedules rendert diese festen Abschnitte:

```text
-- Schedule Settings --
Route: [...]
Cyclic: [...]

-- Wait Conditions --
[wait chain]

-- Selected Wait Condition --
[details]

-- Redstone Rules --
[rule list]

-- Selected Redstone Rule --
[rule output + rule chain]

-- Selected Redstone Condition --
[details]
```

`Confirm` und `Cancel` bleiben fest unten.

### Modal Targets
`build_screen(...)` trennt Hintergrund und Modal:

```lua
{
  buffer = ...,
  targets = background_targets,
  modal_targets = modal_targets,
  layout = ...,
}
```

Pflicht:
- `render_modal(...)` schreibt nur in `modal_targets`
- `handle_click(...)` prüft bei offenem Modal ausschließlich `modal_targets`
- Trefferreihenfolge rückwärts zur Renderreihenfolge

## Choice Handling
Alle endlichen Optionen öffnen einen Chooser. Kein Inline-Cycling mehr.

Betroffene Felder:
- `cyclic`
- `side`
- `active_high`
- `condition type`
- `comparator`
- `scope`
- `redstone output`

Pflicht:
- Klick auf Choice-Zeile öffnet Chooser
- `Enter` auf Choice-Zeile öffnet Chooser
- `Left` / `Right` bewegen nur Auswahl im geöffneten Chooser
- kein direkter Wertwechsel durch simplen Klick auf die Feldzeile

### Scope Menu
Scope wird nie als Freitext-Enum bearbeitet.

Menüoptionen:
- `station_any_detector`
- `station_all_detectors`
- `detector:<id>` für alle Detector-IDs der Zielstation der aktuell gewählten Route
- falls aktueller gespeicherter Scope nicht in dieser Liste liegt:
  - zusätzliche Legacy-Option anzeigen

Nur diese Werte dürfen im UI gesetzt werden.

## Wait Chain Builder
### Builder Model
Der Wait-Editor bleibt für diesen Patch auf `entries[1]` beschränkt.

Interne Struktur:

```lua
{
  kind = "logic_chain",
  key = "wait_chain",
  label = "Wait Conditions",
  groups = {
    {
      conditions = {
        {
          type = "time_passed",
          seconds = "5",
          comparator = ">=",
          value = "0",
          scope = "station_any_detector",
        },
      },
    },
  },
  selected_group_index = 1,
  selected_condition_index = 1,
  chooser = nil,
  pending_insert = nil,
}
```

### Plus Slot Semantics
`+` ist ein echter Insertions-Slot.

Es gibt Slots:
- vor der ersten Condition
- zwischen zwei Conditions innerhalb einer Gruppe
- zwischen zwei Gruppen
- nach der letzten Condition

Jeder Slot trägt exakte Einfüge-Metadaten:

```lua
{
  kind = "plus",
  position = {
    left_group_index = ... or nil,
    left_condition_index = ... or nil,
    right_group_index = ... or nil,
    right_condition_index = ... or nil,
    location = "start" | "within_group" | "between_groups" | "end",
  },
}
```

### Insert Flow
Beim Klick auf einen Slot:
1. Join-Chooser öffnen:
   - `AND`
   - `OR`
2. Condition-Type-Chooser öffnen:
   - `time_passed`
   - `inactivity`
   - `passengers`
   - `cargo_percent`
   - `fluid_percent`
3. Wenn comparatorbasierter Typ:
   - Comparator-Chooser öffnen
4. Condition an exakt diesem Slot einfügen

### Insert Semantics
#### Slot `within_group`
- `AND`:
  - neue Condition in dieselbe Gruppe an dieser Position
- `OR`:
  - Gruppe an dieser Position splitten:
    - linker Teil bleibt alte Gruppe
    - neue Condition wird erste Condition neuer Gruppe
    - rechter Teil wird weitere neue Gruppe

#### Slot `between_groups`
- `OR`:
  - neue Gruppe dazwischen einfügen
- `AND`:
  - neue Condition wird ans Ende der linken Gruppe angehängt

#### Slot `start`
- `AND` und `OR` verhalten sich identisch, weil noch keine linke Struktur existiert:
  - erste Gruppe mit erster Condition anlegen

#### Slot `end`
- `AND`:
  - an letzte Gruppe anhängen
- `OR`:
  - neue Gruppe am Ende

### Condition Editing
Bestehende Wait-Conditions müssen ihren Typ wechseln können.

Pflicht:
- `Type` ist anklickbar
- Klick öffnet Type-Chooser mit aktueller Vorselektion
- bei Typwechsel werden nicht mehr relevante Felder auf Defaults gesetzt:
  - `seconds = "0"`
  - `comparator = ">="`
  - `value = "0"`
  - `scope = "station_any_detector"`

Sichtbarkeit:
- `time_passed`, `inactivity`:
  - nur `seconds`
- `passengers`, `cargo_percent`, `fluid_percent`:
  - `comparator`, `value`, `scope`

## Redstone Rules Editor
### Rule List
Redstone ist kein Anhang an `Selected Wait Condition`.

Es gibt eine eigene Rule-Liste:

```lua
{
  kind = "redstone_rules",
  rules = {
    {
      output = "loader",
      chain = { ...logic chain... },
    },
  },
  selected_rule_index = 1,
}
```

Jede Regel hat:
- `output`
- eigene Bool-Kette

### Redstone Rule UI
Darstellung:

```text
-- Redstone Rules --
[+ Rule]
Rule [1] Output: [loader]
[rule chain summary]
Rule [2] Output: [lamp_ready]
[rule chain summary]
```

`Selected Redstone Rule` zeigt:
- `Output`
- vollständige Chain

`Selected Redstone Condition` zeigt Details der innerhalb dieser Regel selektierten Condition.

### Redstone Rule Editing
Pflicht:
- `Output` nur per Menü aus Zielstations-I/Os der Route wählbar
- jede Regel hat denselben Chain-Builder wie Wait
- bestehende Redstone-Conditions können ihren Typ wechseln
- kein `redstone_mode` im neuen Primärmodell

### Available Redstone Outputs
Helfer:
- Route-Zielstation bestimmen
- `sorted_keys(station.redstone_outputs or {})`

Wenn keine Zielstations-I/Os verfügbar sind:
- keine leere Freitexteingabe
- stattdessen Hinweis:

```text
No destination-station Redstone I/Os available.
```

## Stations Editor: Redstone I/O
Pflichtkorrekturen:
- leere Add-Zeile zeigt Label:
  - `Redstone I/Os [+]`
- `Backspace/Delete` in leeren Gruppen-Subfeldern löscht nicht den ganzen Block
- Löschen nur über `[x]`

Feldarten:
- Text:
  - `ID`
  - `Address`
  - `Strength`
  - `Pulse`
- Menü:
  - `Side`
  - `Active High`

Leere `Address` wird weiter als `nil` gespeichert.

## Group Labels
Die bisherige Anzeige mit `string.char(64 + group_index)` wird vollständig ersetzt.

Helper:

```lua
local function group_label(index)
  local out = ""
  index = tonumber(index) or 1
  while index > 0 do
    local rem = (index - 1) % 26
    out = string.char(65 + rem) .. out
    index = math.floor((index - 1) / 26)
  end
  return out
end
```

Verwendung überall:
- Wait-Zusammenfassung
- Wait-Builder
- Redstone-Rule-Zusammenfassung
- Redstone-Rule-Builder

Nur UI-Label. Keine Schemaänderung.

## Submit Rules
### Schedule Editor Submit
Der neue Editor schreibt:

```lua
schedule.entries[1] = {
  route = values.route,
  wait = {
    groups = runtime_groups_from_wait_chain(wait_field),
  },
  redstone = {
    rules = runtime_rules_from_redstone_editor(redstone_field),
  },
}
schedule.cyclic = values.cyclic == true
```

Wichtig:
- `runtime_rules_from_redstone_editor(...)` darf nicht aus Wait-Conditions abgeleitet werden
- `runtime_redstone_rules_from_chain(...)` als Brückenhelper ist kein Zielzustand mehr
- sobald der neue Editor vollständig steht, darf dieser Brückenhelper entfernt oder nur noch für Legacy-Tests behalten werden

### Legacy Handling on Submit
- Wenn Editor Legacy-`condition.redstone` entdeckt:
  - Warnhinweis anzeigen
  - beim Submit nur das neue `entry.redstone.rules` aus Editor schreiben
  - Legacy-Felder nicht neu erzeugen

## Test Plan
### UI-/Editor-Regressionen
In `route_book_editor_emulator.lua` und `term_ui_preview.lua` ergänzen:

- `tier2 modal cancel button works`
- `tier2 modal confirm button works`
- `modal click prioritizes modal targets over background targets`
- `choice fields open chooser instead of cycling inline`
- `redstone io text fields accept input`
- `redstone io side chooser works`
- `redstone io active_high chooser works`
- `schedule cyclic opens chooser`
- `scope opens chooser with station + detector options`
- `wait plus before first condition inserts first condition`
- `wait plus between conditions inserts at exact slot`
- `wait and insertion keeps same group`
- `wait or insertion splits group correctly`
- `existing wait condition type can be changed`
- `redstone rule list is rendered separately from wait`
- `redstone rule output opens chooser`
- `redstone rule chain inserts via exact slot`
- `existing redstone condition type can be changed`
- `schedule modal renders section headers`
- `selected wait condition and selected redstone condition are visually separate`
- `group_label formats 1 as A`
- `group_label formats 26 as Z`
- `group_label formats 27 as AA`
- `group_label formats 52 as AZ`
- `group_label formats 53 as BA`
- `wait summary uses AA after Z`
- `redstone rule summary uses AA after Z`

### Runtime-/Validation-Regressionen
In `station_schedule`-/`station_dispatch`-Previews ergänzen:

- `wait controls departure independently of redstone rules`
- `redstone rule active while waiting and rule true`
- `redstone rule inactive while waiting and rule false`
- `redstone outputs shut down when wait completes`
- `multiple redstone rules can drive different outputs in parallel`
- `legacy condition.redstone still validates and runs`
- `new editor format entry.redstone.rules validates and runs`
- `editor warns on legacy per-condition redstone presence`

### Acceptance Scenarios
- Zug erreicht Station, Wait noch nicht fertig, Redstone-Regel ist wahr:
  - Output aktiv
  - Zug wartet weiter
- Wait wird fertig:
  - Output wird abgeschaltet
  - Zug fährt ab
- `Cancel` im Schedule-Editor funktioniert auf Tier 2
- `ID` und `Address` im Stations-I/O-Editor sind editierbar
- Redstone-Editor ist als eigener Bereich sichtbar, nicht unter `Selected Wait Condition`

## Implementation Order
1. Modal-Target-Handling und Choice-Menüpflicht hart machen
2. Stations-I/O-Editor stabilisieren
3. Wait-Chain auf echte Insertions-Slots umbauen
4. Redstone-Rule-Datenmodell im Editor einführen
5. Redstone-Rule-UI separat rendern
6. Submit-Pfad auf echtes `entry.redstone.rules` umstellen
7. Runtime-/Validation-Regressionen absichern
8. Legacy-Warnpfad ergänzen

## Assumptions
- `wait` bleibt alleinige Abfahrtslogik
- `redstone.rules` sind reine Wartephasen-Signale
- dieser Patch bearbeitet weiterhin nur `entries[1]`
- Gruppennamen sind reine UI-Labels
- persistierte Daten speichern keine Gruppennamen
