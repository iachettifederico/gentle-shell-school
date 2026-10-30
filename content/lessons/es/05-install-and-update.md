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

No confundas `upgrade` con `gentle-shell update`. `gentle-shell update` sin argumentos actualiza
el Pi que ejecuta este iniciador: verifica qué paquete global de npm o pnpm provee ese Pi,
reinstala exactamente ese paquete e informa si cambió la versión de Pi. Cuando el propietario es
desconocido o ambiguo, se niega sin cambiar nada; actualiza esas instalaciones con el gestor de
paquetes que las provee. Con un objetivo, o con `--extensions-only`, `update` reenvía el comando
de actualización de paquetes de Pi para el home seleccionado. Una instalación incluida en un
prefijo fija Pi con Gentle Shell, así que allí Pi se sigue actualizando con `gentle-shell upgrade`.
Para llegar a un Pi publicado más nuevo que el que verificó la versión, una instalación incluida
puede ejecutar:

```bash
gentle-shell update --latest
```

Primero advierte que las funciones que dependen de partes internas auditadas de Pi (como el editor
Vim) pueden desactivarse hasta que una versión de Gentle Shell verifique ese Pi; luego lo verifica
y cambia a él como `upgrade`, conservando la versión anterior para `gentle-shell upgrade
--rollback`. Fuera de una instalación incluida, `--latest` no cambia nada extra: `update` ya
instala el Pi más nuevo.

Los iniciadores antiguos que no admiten `upgrade` deben usar el instalador más reciente descrito en
**Instala Gentle Shell**, en lugar de tratar `upgrade` como un prompt de chat.

## Reutiliza tus inicios de sesión de Pi

De forma predeterminada, Gentle Shell se ejecuta en su propio home aislado, `~/.gentle-shell/agent`,
así que no ve los inicios de sesión que hiciste en Pi. En lugar de compartir el home de Pi con
`--link`, puedes copiarlos una vez:

```bash
gentle-shell home import-pi --dry-run
gentle-shell home import-pi
```

`--dry-run` muestra el plan y no escribe nada. La importación copia solo `auth.json`, `mcp.json` y
tu proveedor, modelo y nivel de razonamiento predeterminados, y solo donde el destino todavía no
los tiene. Nunca sobrescribe, nunca copia paquetes, extensiones ni sesiones y nunca escribe en tu
home de Pi, así que volver a ejecutarla es seguro. La contrapartida: cada home tiene ahora su
propia copia de las credenciales, y un proveedor que rota los tokens de actualización puede cerrar
la sesión de la copia que se actualice en segundo lugar. Si eso pasa, vuelve a ejecutar `/login`
en ese home.

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
