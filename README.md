# Kiratio

Website für Kiratio, eine KI-Beratung für kleine und mittlere Unternehmen in Mainfranken. Die Startseite führt die vier Leistungen auf (Beratung, Coaching, KI-Automatisierung, Individualsoftware), dahinter steht das Angebot in drei Stufen (Potenzialanalyse, Umsetzung, Betrieb) samt der dazugehörigen Förderprogramme.

Namen, Telefonnummer und Mailadresse stehen und stammen von der Visitenkarte (`04 Firma/Visitenkarte/` im Vault). Die Anschrift steht seit dem 22.10.2026 im Impressum. Impressum und Datenschutzerklärung sind ausformuliert, Rechtsträger ist die Kiratio GbR. Offen sind noch die Fotos der beiden.

## Aufbau

Eine statische Website aus reinem HTML und einer Stylesheet-Datei. Kein Build-Schritt, kein JavaScript, keine Formulare, keine Abhängigkeiten. Die Dateien lassen sich so ausliefern, wie sie im Repository liegen.

```
kiratio-logo.svg        Wortmarke mit Zeichen und Claim, im Seitenkopf
kiratio-logo-hell.svg   dieselbe Wortmarke umgekehrt, im Fuß auf Anthrazit
kiratio-zeichen.svg     Zeichen allein
favicon.svg             Zeichen als Kachel, gefüllt, für kleine Größen
index.html              Startseite
potenzialanalyse.html   Ablauf und Umfang der Analyse
umsetzung.html          Umsetzung, Integration und Betrieb
beratung.html           Beratung, EU AI Act, die drei Beratungsformate
coaching.html           Schulung und Begleitung, KI-Kompetenz nach Artikel 4 AI Act
ki-automatisierung.html wiederkehrende Abläufe automatisieren
individualsoftware.html eigene Software, wenn kein Produkt passt
eu-ai-act.html           EU AI Act: Fristen, Risikoklassen, Pflichten für Betreiber
foerderung.html         Digitalbonus Bayern, KfW
ueber-uns.html          die beiden Personen hinter Kiratio
kontakt.html            Erstgespräch und Anfahrt
impressum.html
datenschutz.html
404.html                Fehlerseite, von CloudFront ausgeliefert
styles.css              Gestaltung aller Seiten
design/                 zwölf Entwürfe der Startseite zur Auswahl
infra/                  Terraform für Hosting und Auslieferung
.github/workflows/      Deploy bei Push auf main
```

Der Ordner `design` gehört nicht zur ausgelieferten Seite. Er enthält zwölf vollständige Entwürfe der Startseite in verschiedenen Handschriften, dazu eine Übersicht in `design/index.html`, die jeden Entwurf mit seinem Risiko beschreibt. Entwurf 1 bis 8 zeigen den alten Inhalt, Entwurf 9 bis 12 den heutigen mit den vier Leistungen vorne. Die ausgelieferten Seiten folgen Entwurf 11.

## Lokal ansehen

Ein einfacher Dateiserver reicht:

```bash
python -m http.server 4173
```

Danach `http://localhost:4173` im Browser öffnen. Dieselbe Konfiguration liegt als Launch-Eintrag in `.claude/launch.json`.

Die Seiten funktionieren auch beim direkten Öffnen aus dem Dateisystem, weil alle Verweise relativ sind. Einzige Ausnahme ist `404.html`: die verweist absolut, weil CloudFront sie unter jeder beliebigen Adresse ausliefert.

## Gestaltung

Farben und Abstände stehen als CSS-Variablen am Anfang von `styles.css` und werden nirgends sonst festgelegt:

```css
--anthrazit: #1B2430;   --kupfer:  #C0713C;   /* die vier Logofarben */
--grau:      #6B7683;   --papier:  #F5F3EF;

--kupfer-dunkel: #A85F30;   --text:        #39424F;   /* daraus abgeleitet */
--linie:         #E1DCD4;   --papier-grau: #AEB6BF;

--rand:      clamp(22px,4vw,44px);   --block: 48px;   --mass: 40rem;
```

Mehr als diese vier Farben hat die Marke nicht. Die vier darunter sind Aufhellungen
oder Abdunklungen davon, für Fließtext, Trennlinien und Hover. `--papier` liegt
doppelt im Einsatz: als Fläche auf Weiß und als Schriftfarbe auf Anthrazit.

Das Logo liegt viermal im Repository (siehe Dateiliste oben). Die Wortmarke steht im
Seitenkopf, im Fuß dieselbe Datei umgekehrt auf Anthrazit. Gegenüber dem Original aus
`04 Firma/Logo/` im Vault ist nur der Rand beschnitten (`viewBox="20 28 352 104"`
statt `0 0 640 160`), damit die Marke im Kopf nicht halb aus Leerraum besteht.

`.wrap` setzt nur den seitlichen Rand. Vertikale Abstände kommen aus Regeln mit höherer Spezifität wie `section.wrap` oder `.auftakt-in`, damit sie den seitlichen Rand nicht überschreiben. Wer Abstände ändert, sollte diese Trennung beibehalten.

`--mass` ist die gemeinsame Zeilenbreite von Fließtext und der Überschrift darüber. Ohne sie lief die Überschrift über die volle Containerbreite, während der Text schon bei knapp 600 Pixeln umbrach; die Kante dazwischen las sich als nach links verschoben. Raster, Bänder und Karten bleiben davon unberührt und nutzen die volle Breite. `--rand` wächst mit dem Fenster, damit der Inhalt bei Fensterbreiten knapp über der Containerbreite nicht am Rand klebt. Der Container (`.wrap`) ist 1200 Pixel breit; auf breiten Schirmen bleibt die Textspalte im zweispaltigen Satz damit bei rund 640 Pixeln, also etwa 75 Zeichen je Zeile. Wo ein Textabschnitt die Breite füllen soll, trägt die Section zusätzlich `gespalten`: Rubrik und Überschrift links, Fließtext rechts, auf schmalen Fenstern untereinander.

Seit dem Umbau auf Entwurf 11 beginnt jede Seite mit einer anthrazitfarbenen Fläche (`.auftakt`), in der Logo, Navigation und Überschrift hell stehen; im Kopf liegt dort `kiratio-logo-hell.svg`. Der Kopf klebt nicht mehr beim Scrollen, weil er in dieser Fläche sitzt. Auf der Startseite schieben sich die vier Leistungskarten mit einem negativen Außenabstand hinein, deshalb ist die Fläche dort tiefer. Die Unterseiten tragen zusätzlich `.auftakt.seite` und haben entsprechend weniger Abstand nach unten. Die Regeln stehen am Ende von `styles.css`.

Als Schrift ist Inter vorgesehen, allerdings nur als erste Wahl im Schriftstapel. Nachgeladen wird nichts, wer Inter nicht installiert hat, sieht Segoe UI oder Helvetica. Soll die Schrift überall gleich aussehen, müssen die woff2-Dateien im Repository liegen und lokal eingebunden werden.

## Vor dem Livegang

Diese Punkte sind offen und im Quelltext als Kommentar markiert:

- Fotos der beiden einsetzen. Solange keine da sind, zeigen die Kacheln auf Startseite und
  „Über uns" die Initialen, im Quelltext steht an jeder Stelle ein Kommentar.
- Die Anschrift steht im Impressum und auf der Datenschutzseite: Bühlstr. 16, 97506
  Grafenrheinfeld. Kontaktseite und Fuß führen bewusst keine, so wie die Visitenkarte.
- Impressum und Datenschutzerklärung sind ausformuliert, aber nicht anwaltlich geprüft. Was sie
  an Annahmen treffen und was noch zu klären ist, steht als Kommentar am Anfang der jeweiligen
  Datei. Im Impressum fehlen bewusst zwei Abschnitte: Registereintrag und Umsatzsteuer-
  Identifikationsnummer gibt es erst, wenn es sie gibt.
- `eu-ai-act.html` nennt Fristen, Artikel und zwei Verordnungsnummern und trägt unten ein
  Stand-Datum. Wer dort etwas ändert, zieht das Datum mit. Eine veraltete Fristenseite ist
  schlechter als keine. Belegt sind die Angaben über EUR-Lex, verlinkt am Seitenende.
- Die Zahlen im Belegband der Startseite belegen oder streichen, besonders den Anfahrtsradius von 45 km.
- Im Logo ist die Schrift noch echter Text, keine Pfade. Wer kein Inter installiert hat,
  sieht die Wortmarke in Segoe UI oder Arial; die Breite bleibt gleich, weil `textLength`
  gesetzt ist. Vor dem Livegang in Pfade umwandeln, dann stimmt das Bild überall.
- Die Entwürfe 6 und 8 in `design/` laden ihre Schriften von Google. Wird einer davon zur Grundlage, müssen die Schriften selbst gehostet werden, sonst braucht die Seite einen Cookie-Hinweis. Die ausgelieferten Seiten selbst laden nichts von fremden Servern.

## Hosting und Deployment

Die Seite liegt in einem privaten S3-Bucket in `eu-central-1` und wird über CloudFront ausgeliefert. Route 53 ist für die DNS-Zone zuständig, das Zertifikat kommt von ACM. Alles davon steht in `infra/` und wird mit Terraform verwaltet.

Ein Push auf `main`, also jeder gemergte Pull Request, startet `.github/workflows/deploy.yml`. Der Workflow spiegelt die Dateien nach S3, invalidiert den CloudFront-Cache und wartet, bis die Invalidierung durch ist. Der Job ist erst grün, wenn die Änderung wirklich ausgeliefert wird, das dauert gut eine Minute. `design/`, `infra/` und die README werden dabei ausgeschlossen und landen nicht auf dem Server.

Angemeldet wird sich per OpenID Connect gegen eine IAM-Rolle, die nur dieses Repository und nur den Branch `main` akzeptiert. Es liegen keine dauerhaften AWS-Schlüssel im Repository.

### Einmalige Einrichtung

```bash
cd infra
terraform init
terraform apply
```

Der erste `apply` bleibt bei der Zertifikatsvalidierung stehen, weil die Domain noch auf Strato zeigt. Das ist erwartet. Nimm die vier Nameserver aus dem Output `nameserver`, trag sie im Strato-Kundenlogin unter der Domainverwaltung als eigene Nameserver ein und lass `terraform apply` danach erneut laufen.

**Vor der Umstellung die E-Mail-Einträge sichern.** Sobald Route 53 zuständig ist, beantwortet Strato keine DNS-Anfragen für die Domain mehr, auch nicht die für `post@kiratio.de`. Die bestehenden MX-, SPF- und DKIM-Einträge müssen vorher abgeschrieben und in `route53.tf` nachgebaut werden. Ein auskommentiertes Gerüst dafür steht dort schon.

Anschließend im Repository unter Settings hinterlegen:

| Name | Art | Wert aus dem Terraform-Output |
| --- | --- | --- |
| `AWS_DEPLOY_ROLE_ARN` | Secret | `deploy_role_arn` |
| `AWS_SITE_BUCKET` | Variable | `bucket` |
| `AWS_DISTRIBUTION_ID` | Variable | `distribution_id` |

Zuletzt die Distribution in der CloudFront-Konsole dem Free-Tarif zuordnen. Das geht nicht über Terraform, der AWS-Provider kennt die Tarife noch nicht. Ohne diesen Schritt läuft alles nach dem regulären Preismodell weiter.

### Was bewusst so gebaut ist

Der Bucket ist nicht öffentlich, gelesen wird er ausschließlich von dieser einen Distribution über Origin Access Control. Die Antwortheader setzen HSTS, eine strenge Content-Security-Policy, `X-Content-Type-Options` und `frame-ancestors 'none'`. Da die Seite kein JavaScript, keine Inline-Styles und keine Fremdinhalte hat, reicht `default-src 'none'` mit `'self'` für Styles, Bilder und Schriften. Wer das ändert, muss die Policy in `cloudfront.tf` mitziehen.

`www.kiratio.de` wird per CloudFront Function dauerhaft auf die Wurzeldomain umgeleitet, damit die Seite unter einer Adresse indexiert wird. Der Flat-Rate-Tarif verlangt ein zugeordnetes WAF-Web-ACL, deshalb liegt in `waf.tf` eine einzelne Rate-Limit-Regel. Rule Groups sind im Tarif nicht erlaubt.

Die Dateinamen tragen keine Hashes. Deshalb wird `max-age=0, s-maxage=31536000, must-revalidate` gesetzt: Browser fragen jedes Mal nach, das CDN hält die Datei trotzdem, und die Invalidierung beim Deploy sorgt für den Rest.

## Änderungen einbringen

Der Branch `main` ist geschützt. Direkte Pushes werden abgelehnt, jede Änderung läuft über einen Pull Request:

```bash
git checkout -b thema/kurzbeschreibung
git push -u origin thema/kurzbeschreibung
gh pr create
```

Ein Approval ist nicht eingestellt, der Merge selbst gilt als Freigabe. Nach dem Merge löscht GitHub den Branch automatisch.
