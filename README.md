# Kiratio

Website für Kiratio, eine KI-Beratung für kleine und mittlere Unternehmen in Mainfranken. Die Seite stellt das Angebot in drei Stufen dar (Potenzialanalyse, Umsetzung, Betrieb) und erklärt die dazugehörigen Förderprogramme.

Der Stand ist eine Entwurfsfassung. Namen, Fotos, Telefonnummer und Anschrift sind Platzhalter, sichtbar über ein Banner am Seitenkopf.

## Aufbau

Eine statische Website aus reinem HTML und einer Stylesheet-Datei. Kein Build-Schritt, kein JavaScript, keine Formulare, keine Abhängigkeiten. Die Dateien lassen sich so ausliefern, wie sie im Repository liegen.

```
index.html              Startseite
potenzialanalyse.html   Ablauf und Umfang der Analyse
umsetzung.html          Umsetzung, Integration und Betrieb
foerderung.html         BAFA, Digitalbonus Bayern, KfW
ueber-uns.html          die beiden Personen hinter Kiratio
kontakt.html            Erstgespräch und Anfahrt
impressum.html
datenschutz.html
styles.css              Gestaltung aller acht Seiten
design/                 acht Entwürfe der Startseite zur Auswahl
```

Der Ordner `design` gehört nicht zur ausgelieferten Seite. Er enthält acht vollständige Entwürfe derselben Startseite in verschiedenen Handschriften, dazu eine Übersicht in `design/index.html`, die jeden Entwurf mit seinem Risiko beschreibt. Die aktuelle Startseite folgt Entwurf 6.

## Lokal ansehen

Ein einfacher Dateiserver reicht:

```bash
python -m http.server 4173
```

Danach `http://localhost:4173` im Browser öffnen. Dieselbe Konfiguration liegt als Launch-Eintrag in `.claude/launch.json`.

Die Seiten funktionieren auch beim direkten Öffnen aus dem Dateisystem, weil alle Verweise relativ sind.

## Gestaltung

Farben und Abstände stehen als CSS-Variablen am Anfang von `styles.css` und werden nirgends sonst festgelegt:

```css
--anthrazit: #1B2430;   --kupfer:  #C0713C;
--grau:      #6B7683;   --text:    #39424F;
--papier:    #F7F5F2;   --linie:   #E1DCD4;
--rand:      28px;      --block:   48px;
```

`.wrap` setzt nur den seitlichen Rand. Vertikale Abstände kommen aus Regeln mit höherer Spezifität wie `section.wrap` oder `.wrap.hero`, damit sie den seitlichen Rand nicht überschreiben. Wer Abstände ändert, sollte diese Trennung beibehalten.

Als Schrift ist Inter vorgesehen, allerdings nur als erste Wahl im Schriftstapel. Nachgeladen wird nichts, wer Inter nicht installiert hat, sieht Segoe UI oder Helvetica. Soll die Schrift überall gleich aussehen, müssen die woff2-Dateien im Repository liegen und lokal eingebunden werden.

## Vor dem Livegang

Diese Punkte sind offen und im Quelltext als Kommentar markiert:

- Die Platzhalter ersetzen: Namen, Fotos, Telefonnummer, Anschrift, Impressum und Datenschutzerklärung. Jede Seite trägt dazu oben ein `div.platzhalter`, das dann wegfällt. Impressum und Datenschutz sind nur ein Gerüst und gehören vor dem Livegang in fachkundige Hände.
- Die Zahlen im Belegband der Startseite belegen oder streichen, besonders den Anfahrtsradius von 45 km.
- Die Entwürfe 6 und 8 in `design/` laden ihre Schriften von Google. Wird einer davon zur Grundlage, müssen die Schriften selbst gehostet werden, sonst braucht die Seite einen Cookie-Hinweis. Die ausgelieferten Seiten selbst laden nichts von fremden Servern.

## Änderungen einbringen

Der Branch `main` ist geschützt. Direkte Pushes werden abgelehnt, jede Änderung läuft über einen Pull Request:

```bash
git checkout -b thema/kurzbeschreibung
git push -u origin thema/kurzbeschreibung
gh pr create
```

Ein Approval ist nicht eingestellt, der Merge selbst gilt als Freigabe. Nach dem Merge löscht GitHub den Branch automatisch.
