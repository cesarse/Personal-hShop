# Personal hShop – Support

[English](SUPPORT.md) · **Deutsch** · [Español](SUPPORT-es.md) · [Français](SUPPORT-fr.md) · [Italiano](SUPPORT-it.md) · [Português (Brasil)](SUPPORT-pt-BR.md)

_Diese Übersetzung dient nur der Information. Bei Abweichungen von der [englischen Fassung](SUPPORT.md) gilt die englische Fassung._

## Kontakt

E-Mail: [personalhshop@icloud.com](mailto:personalhshop@icloud.com)

## Erste Schritte

1. Wählen Sie **Personal hShop › Einstellungen …**, klicken Sie auf **Ordner auswählen…** und wählen Sie den Ordner mit Ihren .cia-Dateien aus.
2. Wählen Sie **Ablage › Server starten**.
3. Öffnen Sie http://localhost:1234 (oder den Port, den Sie in den Einstellungen festgelegt haben) in einem Browser auf Ihrem Mac, oder aktivieren Sie in den Einstellungen **Seite nach dem Serverstart automatisch öffnen**. Sobald der Ordner .cia-Dateien enthält, zeigt die Seite die Adresse, die die Konsole und andere Geräte verwenden können.
4. Öffnen Sie auf der Konsole FBI, wählen Sie **Remote Install › Scan QR Code** und scannen Sie den Code der Datei, die Sie installieren möchten.

## Voraussetzungen

- Ein Mac mit macOS 27 oder neuer.
- Ein Nintendo 3DS mit einem Homebrew-Titelmanager, der über einen QR-Code installieren kann, etwa FBI, im selben lokalen Netzwerk wie der Mac.
- .cia-Dateien, die Sie installieren dürfen. Personal hShop enthält keine Spiele, lädt keine herunter und verlinkt auf keine.

## Fehlerbehebung

**Die Konsole kann keine Verbindung herstellen.**

- Achten Sie darauf, dass die Konsole und der Mac im selben Netzwerk sind. Die Konsole kann nur 2,4-GHz-WLANs mit IPv4 und WPA2 oder älterer Sicherheit beitreten, keinem reinen WPA3-Netzwerk.
- Gastnetzwerke und Router mit aktivierter „AP-Isolation“ oder „Client-Isolation“ verhindern, dass Geräte einander erreichen. Verwenden Sie das Hauptnetzwerk oder deaktivieren Sie diese Option.
- Scannen Sie die Codes auf der Seite oder verwenden Sie die Adresse, die die Seite zeigt: „localhost“ funktioniert nur auf dem Mac selbst.
- Ist der Mac mit mehr als einem Netzwerk verbunden (zum Beispiel Ethernet und WLAN), gehört die Adresse auf der Seite eventuell zum falschen. Öffnen Sie die Seite dann unter http://<Adresse des Mac im Netzwerk der Konsole>:1234; die Codes verwenden anschließend diese Adresse.
- Ist die Firewall des Mac aktiviert, öffnen Sie **Systemeinstellungen › Netzwerk › Firewall › Optionen …** und prüfen Sie, dass **Alle eingehenden Verbindungen blockieren** deaktiviert ist und Personal hShop auf **Eingehende Verbindungen erlauben** steht.
- Ein VPN auf dem Mac kann verhindern, dass die Konsole ihn erreicht.

**„Port … wird bereits verwendet.“**
Eine andere App verwendet diesen Port. Wählen Sie in den Einstellungen einen anderen und starten Sie den Server dann erneut.

**Eine Datei fehlt auf der Seite.**
Es werden nur Dateien mit der Endung .cia aufgeführt, die direkt im ausgewählten Ordner liegen, keine aus seinen Unterordnern.

**Die Seite zeigt „Keine .cia-Dateien gefunden“, obwohl der Ordner welche enthält.**
Personal hShop konnte den Ordner nicht öffnen, oder die Dateien liegen in einem Unterordner. Wählen Sie **Ablage › Server stoppen**, öffnen Sie die Einstellungen, klicken Sie auf **Ordner auswählen…**, wählen Sie den Ordner erneut aus und starten Sie dann den Server. Liegt der Ordner auf einem externen Laufwerk oder Netzlaufwerk, schließen Sie das Laufwerk zuerst an.

**Ein Titel sieht anders aus als der Dateiname.**
Titel stammen aus dem englischen Titel, der in der Datei gespeichert ist. Hat die Datei keinen, wie viele verschlüsselte Dateien, stammt der Titel aus dem Dateinamen, ohne die 16-stellige Title-ID am Anfang und ohne die Angaben in Klammern nach dem Namen, etwa Produktcode, Version und Region. Titel, die nur aus Großbuchstaben bestehen, werden mit großem Anfangsbuchstaben bei jedem Wort angezeigt; römische Zahlen bleiben, wie sie sind.

**Eine Installation brach mittendrin ab.**
Der Mac bleibt wach, während eine Datei gesendet wird, aber wenn Sie den Deckel eines MacBook schließen, geht er trotzdem in den Ruhezustand. FBI gibt auf, wenn 15 Sekunden lang keine Daten ankommen; starten Sie die Installation erneut.

**Große Spiele dauern lange.**
Das WLAN der Konsole ist langsam: Rechnen Sie mit etwa 0,5 MB/s auf einem originalen 3DS und etwa 1,3 MB/s auf einem New 3DS. Ein 1 GB großes Spiel dauert auf einem New 3DS also etwa 15 Minuten und auf einem originalen 3DS mehr als eine halbe Stunde.

## Deinstallieren

Beenden Sie Personal hShop und bewegen Sie die App in den Papierkorb. Um auch ihre Einstellungen zu entfernen, wählen Sie im Finder **Gehe zu › Gehe zu Ordner …**, geben Sie `~/Library/Containers` ein und bewegen Sie den Ordner „Personal hShop“ (sein echter Name ist `com.github.cesarse.Personal-hShop`) in den Papierkorb.

## Datenschutz

Personal hShop erfasst keine Daten. Siehe die [Datenschutzerklärung](PRIVACY-de.md).
