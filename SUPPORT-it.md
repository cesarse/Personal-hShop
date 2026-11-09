# Supporto di Personal hShop

[English](SUPPORT.md) · [Deutsch](SUPPORT-de.md) · [Español](SUPPORT-es.md) · [Français](SUPPORT-fr.md) · **Italiano** · [Português (Brasil)](SUPPORT-pt-BR.md)

_Questa traduzione è fornita solo per comodità. In caso di discrepanze con la [versione inglese](SUPPORT.md), prevale la versione inglese._

## Contatti

E-mail: [personalhshop@icloud.com](mailto:personalhshop@icloud.com)

## Per iniziare

1. Scegli **Personal hShop › Impostazioni…**, fai clic su **Scegli cartella…** e seleziona la cartella che contiene i tuoi file .cia.
2. Scegli **File › Avvia server**.
3. Apri http://localhost:1234 (o la porta scelta nelle impostazioni) in un browser sul Mac, oppure attiva **Apri automaticamente la pagina all’avvio del server** nelle impostazioni. Quando la cartella contiene file .cia, la pagina mostra l’indirizzo che la console e gli altri dispositivi possono usare.
4. Sulla console, apri FBI, scegli **Remote Install › Scan QR Code** e scansiona il codice del file che vuoi installare.

## Requisiti

- Un Mac con macOS 27 o versioni successive.
- Un Nintendo 3DS con un gestore di titoli homebrew in grado di installare da un codice QR, come FBI, sulla stessa rete locale del Mac.
- File .cia che hai il diritto di installare. Personal hShop non include giochi, non li scarica e non rimanda ad alcuno.

## Risoluzione dei problemi

**La console non riesce a connettersi.**

- Assicurati che la console e il Mac siano sulla stessa rete. La console può collegarsi solo a reti Wi-Fi a 2,4 GHz che usano IPv4 e una sicurezza WPA2 o precedente; non può collegarsi a una rete solo WPA3.
- Le reti ospiti e i router con l’“isolamento AP” o l’“isolamento dei client” attivo impediscono ai dispositivi di comunicare tra loro. Usa la rete principale, oppure disattiva quell’opzione.
- Scansiona i codici sulla pagina o usa l’indirizzo che la pagina mostra: “localhost” funziona solo sul Mac stesso.
- Se il Mac è connesso a più di una rete (per esempio Ethernet e Wi-Fi), l’indirizzo sulla pagina potrebbe appartenere alla rete sbagliata. In quel caso apri la pagina su http://<l’indirizzo del Mac sulla rete della console>:1234; i codici useranno poi quell’indirizzo.
- Se il firewall del Mac è attivo, apri **Impostazioni di Sistema › Rete › Firewall › Opzioni…** e controlla che **Impedisci tutte le connessioni in entrata** sia disattivato e che Personal hShop sia impostato su **Consenti connessioni in entrata**.
- Una VPN attiva sul Mac può impedire alla console di raggiungerlo.

**“La porta … è già in uso.”**
Un’altra app sta usando quella porta. Scegline un’altra nelle impostazioni, poi avvia di nuovo il server.

**Un file manca dalla pagina.**
Sono elencati solo i file che terminano con .cia e che si trovano direttamente nella cartella scelta, non quelli nelle sue sottocartelle.

**La pagina dice “Nessun file .cia trovato”, ma la cartella ne contiene.**
L’app non è riuscita ad aprire la cartella, oppure i file sono in una sottocartella. Scegli **File › Arresta server**, apri le impostazioni, fai clic su **Scegli cartella…**, seleziona di nuovo la cartella, poi avvia il server. Se la cartella si trova su un disco esterno o di rete, collega prima il disco.

**Un titolo è diverso dal nome del file.**
I titoli provengono dal titolo in inglese memorizzato nel file. Quando il file non ne ha uno, come molti file crittografati, il titolo viene dal nome del file, senza l’ID titolo di 16 cifre all’inizio e senza i dettagli tra parentesi dopo il nome, come il codice prodotto, la versione e la regione. I titoli scritti interamente in maiuscolo vengono mostrati con l’iniziale di ogni parola maiuscola, lasciando invariati i numeri romani.

**Un’installazione si è interrotta a metà.**
Il Mac resta attivo mentre invia un file, ma chiudere il coperchio di un MacBook lo mette comunque in stop. FBI rinuncia quando non arrivano dati per 15 secondi; avvia di nuovo l’installazione.

**I giochi grandi richiedono molto tempo.**
Il Wi-Fi della console è lento: aspettati circa 0,5 MB/s su un 3DS originale e circa 1,3 MB/s su un New 3DS, quindi un gioco da 1 GB richiede circa 15 minuti su un New 3DS e più di mezz’ora su un 3DS originale.

## Disinstallazione

Esci da Personal hShop e sposta l’app nel Cestino. Per rimuovere anche le sue impostazioni, scegli **Vai › Vai alla cartella…** nel Finder, inserisci `~/Library/Containers` e sposta nel Cestino la cartella chiamata “Personal hShop” (il suo vero nome è `com.github.cesarse.Personal-hShop`).

## Privacy

Personal hShop non raccoglie alcun dato. Consulta l’[informativa sulla privacy](PRIVACY-it.md).
