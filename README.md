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
404.html                Fehlerseite, von CloudFront ausgeliefert
styles.css              Gestaltung aller Seiten
design/                 acht Entwürfe der Startseite zur Auswahl
infra/                  Terraform für Hosting und Auslieferung
.github/workflows/      Deploy bei Push auf main
```

Der Ordner `design` gehört nicht zur ausgelieferten Seite. Er enthält acht vollständige Entwürfe derselben Startseite in verschiedenen Handschriften, dazu eine Übersicht in `design/index.html`, die jeden Entwurf mit seinem Risiko beschreibt. Die aktuelle Startseite folgt Entwurf 6.

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
