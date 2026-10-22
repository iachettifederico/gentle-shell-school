---
title: "Verifica, actualiza y elimina Gentle Shell"
description: "Verifica tu configuración, elige un canal de actualización y elimina Gentle Shell de manera deliberada."
module: "Fundamentos"
---

# Verifica, actualiza y elimina Gentle Shell

La instalación corresponde a **Instala Gentle Shell**. Una vez que Gentle Shell está en
funcionamiento, las preguntas útiles cambian: qué versión y home están activos, cómo verificar el
espacio de trabajo en ejecución, a qué actualización te refieres y cómo puedes eliminarlo sin
borrar lo incorrecto.

## Verifica el iniciador y el espacio de trabajo

Comienza con el informe de versión del iniciador:

```bash
gentle-shell --version
```

Informa información de versión de Gentle Shell, Pi y el home. Luego, desde una sesión abierta de
Gentle Shell, usa las verificaciones documentadas del espacio de trabajo:

```text
/gentle:status
/gentle:doctor
```

Estas verificaciones inspeccionan el entorno en ejecución. Eso importa porque un comando que
existe en una terminal no prueba por sí solo que un home de agente determinado tenga el espacio de
trabajo y la configuración de complementos esperados.

## Actualiza lo que quieres actualizar

`gentle-shell upgrade` actualiza Gentle Shell según su canal actual:

```bash
gentle-shell upgrade
```

En los iniciadores que admiten canales, puedes elegir el canal documentado release o main:

```bash
gentle-shell upgrade --channel main
gentle-shell upgrade --channel release
```

El canal main compila Gentle Shell y Gentle AI a partir de los commits actuales de main y necesita
pnpm y Go. Volver a release restaura el binario fijado de Gentle AI. Una instalación incluida sigue
el canal release y conserva una versión anterior que se puede seleccionar con:

```bash
gentle-shell upgrade --rollback
```

No confundas `upgrade` con `gentle-shell update [target]`. Este último reenvía el comando de
actualización de paquetes de Pi para el home seleccionado. En una instalación incluida, Pi está
fijado con Gentle Shell, por lo que una actualización de Pi en sí ejecuta `gentle-shell upgrade`.
Los iniciadores antiguos que no admiten `upgrade` deben usar el instalador más reciente descrito en
**Instala Gentle Shell**, en lugar de tratar `upgrade` como un prompt de chat.

## Elimina solo lo que pretendes

Siempre inspecciona primero el plan de eliminación:

```bash
gentle-shell self-uninstall --dry-run
```

Si el plan es correcto, el comando interactivo es:

```bash
gentle-shell self-uninstall
```

Self-uninstall elimina los datos propios de Gentle Shell, el home aislado y el paquete
`gentle-pi` después de la confirmación. Conserva la configuración compartida de Gentle AI en
`~/.pi/gentle-ai`, salvo que aceptes o pases `--include-shared`, y no modifica tu home de Pi ni
los homes personalizados de `--home`. `gentle-shell uninstall <source>` es diferente: es el alias
de Pi para eliminar una fuente de paquete, no el comando para eliminar Gentle Shell en sí.

## Pruébalo

Ejecuta `gentle-shell --version`, luego `/gentle:status` y `/gentle:doctor` en una sesión de
Gentle Shell. Indica qué comando actualiza Gentle Shell, cuál actualiza paquetes de Pi y cuál
muestra una vista previa de un plan de eliminación.
