# Política de privacidad

[English](PRIVACY.md) · [Deutsch](PRIVACY-de.md) · **Español** · [Français](PRIVACY-fr.md) · [Italiano](PRIVACY-it.md) · [Português (Brasil)](PRIVACY-pt-BR.md)

_Esta traducción se ofrece solo como referencia. Si difiere de la [versión en inglés](PRIVACY.md), prevalece la versión en inglés._

_Última actualización: 9 de noviembre de 2026_

Personal hShop es una app para Mac. No recopila ningún dato personal.

## Lo que la app no hace

- No recopila ni comparte ninguna información personal. Lo poco que guarda se queda en tu Mac (consulta más abajo).
- Nunca se conecta a internet ni a ningún servicio en línea. Su sandbox ni siquiera permite conexiones salientes.
- No tiene cuentas, análisis, publicidad ni seguimiento, y no contiene código de terceros que los tenga.
- No guarda ningún registro de qué archivos se descargan ni desde qué dispositivo.

## Lo que se queda en tu Mac

La propia app guarda tres ajustes, solo en tu Mac, dentro de su propio sandbox:

- el puerto del servidor;
- si la página se abre automáticamente al iniciar el servidor;
- un marcador de la carpeta que elegiste, para que la app pueda volver a leerla la próxima vez que se abra.

macOS también puede guardar ahí datos habituales de las ventanas, como dónde estaba la ventana de ajustes. Nada de esto sale de tu Mac. Los títulos de los juegos leídos de tus archivos se guardan en memoria mientras la app está abierta y desaparecen cuando sales de ella.

## Tus archivos y tu red

- La app solo lee la carpeta que elijas. Nunca cambia, mueve ni elimina tus archivos.
- Mientras el servidor está en marcha, cualquier dispositivo que pueda llegar a tu Mac a través de la red, normalmente los dispositivos de tu red local, puede abrir la página y descargar los archivos que aparecen en ella. La página y los archivos se envían por HTTP sin cifrar, y la página muestra los nombres de tus juegos y la dirección local de tu Mac. El servidor se detiene cuando lo detienes o sales de la app, y nunca se inicia solo. Inícialo solo en redes de confianza.

## Conservación y eliminación de tus datos

Los ajustes anteriores se conservan hasta que los elimines. No se guarda nada en ningún otro sitio y quien desarrolla la app no recibe ningún dato, así que no hay nada que pedirle que elimine.

Para que la app deje de leer tu carpeta, elige otra carpeta en los ajustes o elimina los ajustes de la app como se explica a continuación.

Para eliminar los ajustes de la app, sal de ella, elige **Ir › Ir a la carpeta…** en el Finder, escribe `~/Library/Containers` y mueve a la Papelera la carpeta llamada “Personal hShop”. Su nombre real es `com.github.cesarse.Personal-hShop`. Si macOS pide permiso, concédelo.

Mover la propia app a la Papelera no elimina esta carpeta.

## Informes de fallos

Si has elegido en macOS compartir análisis con los desarrolladores de apps, Apple puede proporcionar informes de fallos anónimos de esta app a quien la desarrolla. Apple los gestiona según su propia política de privacidad.

## Menores

La app no recopila datos de nadie, tampoco de menores.

## Cambios en esta política

Si esta política cambia, la nueva versión se publicará aquí con una fecha nueva.

## Contacto

Si tienes cualquier pregunta sobre esta política, escribe a [personalhshop@icloud.com](mailto:personalhshop@icloud.com). Consulta también la página de [soporte](SUPPORT-es.md).
