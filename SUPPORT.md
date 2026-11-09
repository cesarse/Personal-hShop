# Personal hShop Support

**English** · [Deutsch](SUPPORT-de.md) · [Español](SUPPORT-es.md) · [Français](SUPPORT-fr.md) · [Italiano](SUPPORT-it.md) · [Português (Brasil)](SUPPORT-pt-BR.md)

_Translations of this page are provided for convenience. If a translation differs from this English version, the English version applies._

## Contact

Email: [personalhshop@icloud.com](mailto:personalhshop@icloud.com)

## Getting started

1. Open **Personal hShop › Settings…**, click **Choose folder…** and select the folder that holds your .cia files.
2. Choose **File › Start server**.
3. Open http://localhost:1234 (or the port you set in Settings) in a browser on your Mac, or turn on **Automatically open page after server starts** in Settings. Once the folder has .cia files, the page shows the address the console and other devices can use.
4. On the console, open FBI, choose **Remote Install › Scan QR Code**, and scan the code of the file you want to install.

## Requirements

- A Mac running macOS 27 or later.
- A Nintendo 3DS with a homebrew title manager that can install from a QR code, such as FBI, on the same local network as the Mac.
- .cia files you have the right to install. Personal hShop does not include, download or link to any games.

## Troubleshooting

**The console can't connect.**

- Make sure the console and the Mac are on the same network. The console can only join 2.4 GHz Wi-Fi networks that use IPv4 and WPA2 or older security; it cannot join a WPA3-only network.
- Guest networks, and routers with "AP isolation" or "client isolation" turned on, stop devices from reaching each other. Use the main network, or turn that option off.
- Scan the codes on the page, or use the address the page shows: "localhost" only works on the Mac itself.
- If the Mac is connected to more than one network (for example, Ethernet and Wi-Fi), the address on the page may belong to the wrong one. Open the page at http://<the Mac's address on the console's network>:1234 instead; the codes then use that address.
- If the Mac's firewall is on, open **System Settings › Network › Firewall › Options…** and check that **Block all incoming connections** is off and that Personal hShop is set to **Allow incoming connections**.
- A VPN running on the Mac can keep the console from reaching it.

**"Port … is already in use."**
Another app is using that port. Choose another one in Settings, then start the server again.

**A file is missing from the page.**
Only files ending in .cia that are directly inside the chosen folder are listed. Files in its subfolders are not.

**The page says "No .cia files found", but the folder has some.**
Personal hShop could not open the folder, or the files are in a subfolder. Choose **File › Stop server**, open Settings, click **Choose folder…** and select the folder again, then start the server. If the folder is on an external or network drive, connect the drive first.

**A title looks different from the file name.**
Titles come from the English title stored inside the file. When the file has none, as with many encrypted files, the title comes from the file name, without the 16-digit title ID at the start and without the bracketed details after the name, such as the product code, version and region. Titles written entirely in capital letters are shown in title case, with Roman numerals left as they are.

**An install stopped halfway.**
The Mac stays awake while a file is being sent, but closing a MacBook's lid still puts it to sleep. FBI gives up when no data arrives for 15 seconds; start the install again.

**Large games take a long time.**
The console's Wi-Fi is slow: expect about 0.5 MB/s on an original 3DS and about 1.3 MB/s on a New 3DS, so a 1 GB game takes about 15 minutes on a New 3DS and more than half an hour on an original 3DS.

## Uninstalling

Quit Personal hShop and move it to the Trash. To remove its settings too, choose **Go › Go to Folder…** in the Finder, enter `~/Library/Containers` and move the folder named "Personal hShop" (its real name is `com.github.cesarse.Personal-hShop`) to the Trash.

## Privacy

Personal hShop collects no data. See the [privacy policy](PRIVACY.md).
