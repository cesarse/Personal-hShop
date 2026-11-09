# Soporte de Personal hShop

[English](SUPPORT.md) · [Deutsch](SUPPORT-de.md) · **Español** · [Français](SUPPORT-fr.md) · [Italiano](SUPPORT-it.md) · [Português (Brasil)](SUPPORT-pt-BR.md)

_Esta traducción se ofrece solo como referencia. Si difiere de la [versión en inglés](SUPPORT.md), prevalece la versión en inglés._

## Contacto

Correo electrónico: [personalhshop@icloud.com](mailto:personalhshop@icloud.com)

## Primeros pasos

1. Elige **Personal hShop › Ajustes…**, haz clic en **Elegir carpeta…** y selecciona la carpeta que contiene tus archivos .cia.
2. Elige **Archivo › Iniciar servidor**.
3. Abre http://localhost:1234 (o el puerto que hayas configurado en los ajustes) en un navegador de tu Mac, o activa **Abrir la página automáticamente al iniciar el servidor** en los ajustes. Cuando la carpeta tenga archivos .cia, la página mostrará la dirección que pueden usar la consola y otros dispositivos.
4. En la consola, abre FBI, elige **Remote Install › Scan QR Code** y escanea el código del archivo que quieras instalar.

## Requisitos

- Un Mac con macOS 27 o posterior.
- Una Nintendo 3DS con un gestor de títulos homebrew que pueda instalar desde un código QR, como FBI, en la misma red local que el Mac.
- Archivos .cia que tengas derecho a instalar. Personal hShop no incluye juegos, no los descarga y no enlaza a ninguno.

## Solución de problemas

**La consola no puede conectarse.**

- Asegúrate de que la consola y el Mac estén en la misma red. La consola solo puede conectarse a redes Wi-Fi de 2,4 GHz que usen IPv4 y seguridad WPA2 o anterior; no puede conectarse a una red solo WPA3.
- Las redes de invitados y los routers con el “aislamiento de AP” o el “aislamiento de clientes” activado impiden que los dispositivos se comuniquen entre sí. Usa la red principal o desactiva esa opción.
- Escanea los códigos de la página o usa la dirección que muestra: “localhost” solo funciona en el propio Mac.
- Si el Mac está conectado a más de una red (por ejemplo, Ethernet y Wi-Fi), puede que la dirección de la página sea la de la red equivocada. En ese caso, abre la página en http://<la dirección del Mac en la red de la consola>:1234; los códigos usarán entonces esa dirección.
- Si el firewall del Mac está activado, abre **Ajustes del Sistema › Red › Firewall › Opciones…** y comprueba que **Bloquear todas las conexiones entrantes** esté desactivado y que Personal hShop esté configurado en **Permitir las conexiones entrantes**.
- Una VPN activa en el Mac puede impedir que la consola llegue a él.

**“El puerto … ya está en uso.”**
Otra app está usando ese puerto. Elige otro en los ajustes y vuelve a iniciar el servidor.

**Falta un archivo en la página.**
Solo aparecen los archivos terminados en .cia que están directamente dentro de la carpeta elegida, no los de sus subcarpetas.

**La página dice “No se han encontrado archivos .cia”, pero la carpeta los tiene.**
Personal hShop no ha podido abrir la carpeta, o los archivos están en una subcarpeta. Elige **Archivo › Detener servidor**, abre los ajustes, haz clic en **Elegir carpeta…**, vuelve a seleccionar la carpeta y después inicia el servidor. Si la carpeta está en un disco externo o de red, conecta primero el disco.

**Un título no coincide con el nombre del archivo.**
Los títulos se toman del título en inglés guardado dentro del archivo. Cuando el archivo no lo tiene, como ocurre con muchos archivos cifrados, el título se toma del nombre del archivo, sin el ID de título de 16 dígitos del principio y sin los datos entre paréntesis que siguen al nombre, como el código de producto, la versión y la región. Los títulos escritos completamente en mayúsculas se muestran con la inicial de cada palabra en mayúscula, sin cambiar los números romanos.

**Una instalación se ha detenido a medias.**
El Mac se mantiene activo mientras se envía un archivo, pero si cierras la tapa de un MacBook, entra en reposo de todos modos. FBI se rinde si no llegan datos durante 15 segundos; vuelve a iniciar la instalación.

**Los juegos grandes tardan mucho.**
El Wi-Fi de la consola es lento: cuenta con unos 0,5 MB/s en una 3DS original y unos 1,3 MB/s en una New 3DS, así que un juego de 1 GB tarda unos 15 minutos en una New 3DS y más de media hora en una 3DS original.

## Desinstalación

Sal de Personal hShop y mueve la app a la Papelera. Para eliminar también sus ajustes, elige **Ir › Ir a la carpeta…** en el Finder, escribe `~/Library/Containers` y mueve a la Papelera la carpeta llamada “Personal hShop” (su nombre real es `com.github.cesarse.Personal-hShop`).

## Privacidad

Personal hShop no recopila ningún dato. Consulta la [política de privacidad](PRIVACY-es.md).
