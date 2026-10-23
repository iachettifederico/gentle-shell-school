---
title: "Instala Gentle Shell"
description: "Instala Gentle Shell mediante la ruta documentada para tu sistema operativo."
module: "Primeros pasos"
---

# Instala Gentle Shell

Lee esta lección aquí, en el sitio web: hasta que Gentle Shell esté instalado no hay
un agente en el que pegar un prompt. El objetivo es limitado y observable: hacer que
el comando `gentle-shell` esté disponible y luego confirmarlo con
`gentle-shell --version`.

Comienza por identificar tu sistema operativo. El instalador de descarga documentado
es la ruta más sencilla y no necesita terminal. Instala los componentes que Gentle
Shell necesita, o actualiza una instalación existente, y muestra un plan antes de
cambiar nada. Descarga únicamente desde la página Releases del repositorio de Gentle
Shell.

## Usa el instalador para tu sistema

Elige el archivo documentado para tu sistema operativo:

- **macOS:** descarga `gentle-shell-installer-macos.zip`, ábrelo y luego haz doble
  clic en **Install Gentle Shell.command** dentro de la carpeta *Gentle Shell Installer*.
- **Windows:** descarga `gentle-shell-installer-windows.zip`, haz clic derecho sobre él y
  elige **Extract All**, luego abre la carpeta extraída *Gentle Shell Installer*
  y haz doble clic en **Install Gentle Shell.cmd**. No lo ejecutes desde dentro
  del archivo zip.
- **Linux:** descarga `gentle-shell-installer-linux.tar.gz`, extráelo y luego haz
  doble clic en `install-gentle-shell.sh`. Si tu administrador de archivos abre el script
  en un editor, ejecuta este comando en la carpeta extraída:

```bash
sh install-gentle-shell.sh
```

El instalador abre una ventana pequeña y luego una página del navegador. Mantén esa
ventana pequeña abierta hasta que el navegador indique que la instalación terminó. En
una instalación nueva incluida, Gentle Shell conserva su propio Node.js, npm, pnpm y
Pi en `~/.gentle-shell`; no usa ni modifica tus propias herramientas.

Los instaladores de descarga actualmente no están firmados, por lo que macOS o Windows
pueden advertirte la primera vez. Sigue las indicaciones del sistema operativo en el
README de Gentle Shell enlazado desde la versión, en lugar de ignorar una advertencia
inesperada. Si tu sistema operativo no es macOS, Windows o Linux, sigue el enlace
Get started del README para una ruta documentada; este curso no inventa una.

## Confirma el comando

Cuando termine el instalador, abre una terminal nueva si te lo pide y luego ejecuta:

```bash
gentle-shell --version
```

Un comando exitoso muestra información de versión de Gentle Shell, Pi y home. Esa es la
verificación de esta lección: demuestra que tu terminal puede encontrar el iniciador.
Si el comando no se encuentra o no muestra información de versión, vuelve al resultado
del instalador y a su guía documentada en lugar de intentar adivinar cambios de PATH o
comandos de paquetes.

## Otras rutas documentadas

El README también documenta una ruta independiente con npm y otra para añadir el
paquete a una instalación de Pi existente. Son decisiones de propiedad útiles, pero
el instalador de descarga es la ruta que se enseña aquí porque está documentado para
los tres sistemas operativos compatibles. Lee la sección **Get started** del README si
deliberadamente necesitas una de esas alternativas.

## Pruébalo

Sigue la ruta del instalador para tu sistema operativo y ejecuta
`gentle-shell --version`. Cuando muestre información de versión, continúa con
**Abre Gentle Shell**: inicia Gentle Shell y te muestra dónde pegar tu primer prompt.
