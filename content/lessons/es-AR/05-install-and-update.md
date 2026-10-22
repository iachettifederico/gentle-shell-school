---
title: "Comprobá, actualizá y eliminá Gentle Shell"
description: "Comprobá tu configuración, elegí un canal de actualización y eliminá Gentle Shell deliberadamente."
module: "Primeros pasos"
---

# Comprobá, actualizá y eliminá Gentle Shell

La instalación corresponde a **Instalá Gentle Shell**. Una vez que Gentle Shell
está en ejecución, cambian las preguntas útiles: qué versión y home están
activos, cómo comprobás el espacio de trabajo en ejecución, a qué actualización
te referís y cómo podés eliminarlo sin borrar lo equivocado.

## Comprobá el lanzador y el espacio de trabajo

Empezá con el informe de versión del lanzador:

```bash
gentle-shell --version
```

Informa la versión de Gentle Shell, Pi y el home. Después, desde una sesión
abierta de Gentle Shell, usá las comprobaciones documentadas del espacio de
trabajo:

```text
/gentle:status
/gentle:doctor
```

Estas comprobaciones inspeccionan el entorno en ejecución. Eso importa porque
que un comando exista en una terminal no demuestra por sí solo que un home de
agente particular tenga la configuración esperada del espacio de trabajo y los
complementos.

## Actualizá lo que querés actualizar

`gentle-shell upgrade` actualiza Gentle Shell en su canal actual:

```bash
gentle-shell upgrade
```

En lanzadores que admiten canales, podés elegir el canal documentado release o
main:

```bash
gentle-shell upgrade --channel main
gentle-shell upgrade --channel release
```

El canal main construye Gentle Shell y Gentle AI a partir de los commits actuales
de main y necesita pnpm y Go. Volver a release restaura el binario fijado de
Gentle AI. Una instalación empaquetada sigue el canal release y conserva una
versión anterior que podés seleccionar con:

```bash
gentle-shell upgrade --rollback
```

No confundas `upgrade` con `gentle-shell update [target]`. El segundo reenvía el
comando de actualización de paquetes de Pi para el home seleccionado. En una
instalación empaquetada, Pi está fijado junto con Gentle Shell, por lo que una
actualización de Pi mismo ejecuta `gentle-shell upgrade` en su lugar. Los
lanzadores más antiguos que no admiten `upgrade` deben usar el instalador más
reciente descrito en **Instalá Gentle Shell** en vez de tratar `upgrade` como un
prompt de chat.

## Eliminá solo lo que pretendés

Inspeccioná siempre primero el plan de eliminación:

```bash
gentle-shell self-uninstall --dry-run
```

Si el plan es correcto, el comando interactivo es:

```bash
gentle-shell self-uninstall
```

Self-uninstall elimina los propios datos de Gentle Shell, el home aislado y el
paquete `gentle-pi` después de la confirmación. Conserva la configuración
compartida de Gentle AI en `~/.pi/gentle-ai`, salvo que aceptes o pases
`--include-shared`, y no toca tu home de Pi ni los homes personalizados de
`--home`. `gentle-shell uninstall <source>` es distinto: es el alias de Pi para
eliminar una fuente de paquete, no el comando para eliminar Gentle Shell mismo.

## Probalo

Ejecutá `gentle-shell --version`, y luego `/gentle:status` y `/gentle:doctor` en
una sesión de Gentle Shell. Decí qué comando actualiza Gentle Shell, cuál
actualiza los paquetes de Pi y qué comando previsualiza un plan de eliminación.
