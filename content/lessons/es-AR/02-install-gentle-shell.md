---
title: "Instalá Gentle Shell"
description: "Instalá Gentle Shell con el recorrido documentado para tu sistema operativo."
module: "Primeros pasos"
---

# Instalá Gentle Shell

Este curso puede comenzar con cualquier agente de programación. Ese agente puede
ayudarte a instalar Gentle Shell, pero no reemplaza a Gentle Shell. El objetivo
de esta lección es acotado y observable: hacer que el comando `gentle-shell`
esté disponible y luego confirmarlo con `gentle-shell --version`.

Empezá por identificar tu sistema operativo. El instalador de descarga
documentado es el camino más simple y no necesita terminal. Instala las piezas
que necesita Gentle Shell, o actualiza una instalación existente, y muestra un
plan antes de cambiar nada. Descargalo solamente desde la página Releases del
repositorio de Gentle Shell.

## Usá el instalador para tu sistema

Elegí el archivo documentado para tu sistema operativo:

- **macOS:** descargá `gentle-shell-installer-macos.zip`, abrilo y luego hacé
  doble clic en **Install Gentle Shell.command** en la carpeta *Gentle Shell
  Installer*.
- **Windows:** descargá `gentle-shell-installer-windows.zip`, hacé clic derecho
  y elegí **Extract All**, luego abrí la carpeta extraída *Gentle Shell
  Installer* y hacé doble clic en **Install Gentle Shell.cmd**. No lo ejecutes
  desde dentro del archivo zip.
- **Linux:** descargá `gentle-shell-installer-linux.tar.gz`, extraelo y luego
  hacé doble clic en `install-gentle-shell.sh`. Si tu administrador de archivos
  abre el script en un editor, ejecutá este comando en la carpeta extraída:

```bash
sh install-gentle-shell.sh
```

El instalador abre una ventana pequeña y luego una página del navegador. Mantené
esa ventana pequeña abierta hasta que el navegador indique que la instalación
terminó. En una instalación nueva empaquetada, Gentle Shell conserva su propio
Node.js, npm, pnpm y Pi en `~/.gentle-shell`; no usa ni modifica tus propias
herramientas.

Los instaladores descargables actualmente no están firmados, por lo que macOS o
Windows podrían advertirte la primera vez. Seguí las indicaciones del sistema
operativo en el README de Gentle Shell enlazado desde el release, en lugar de
eludir una advertencia inesperada. Si tu sistema operativo no es macOS, Windows
ni Linux, seguí el enlace **Get started** del README para un recorrido
documentado; este curso no inventa uno.

## Confirmá el comando

Cuando termine el instalador, abrí una terminal nueva si te lo pide y luego
ejecutá:

```bash
gentle-shell --version
```

Un comando exitoso muestra información de versión de Gentle Shell, Pi y home.
Esa es la comprobación de esta lección: prueba que tu terminal puede encontrar
el lanzador. Si el comando no se encuentra o no muestra información de versión,
volvé al resultado del instalador y a su guía documentada en lugar de adivinar
cambios de PATH o comandos de paquetes.

## Otros recorridos documentados

El README también documenta un recorrido npm independiente y otro para agregar
el paquete a una instalación existente de Pi. Son decisiones útiles de
propiedad, pero el instalador descargable es el recorrido enseñado acá porque
está documentado para los tres sistemas operativos compatibles. Leé la sección
**Get started** del README si necesitás deliberadamente alguna de esas
alternativas.

## Probalo

Decile a tu tutor qué sistema operativo usás, completá el recorrido documentado
del instalador y ejecutá `gentle-shell --version`. Mantené la terminal abierta:
en la próxima lección vas a iniciar Gentle Shell y transferirle el progreso de
tu curso.
