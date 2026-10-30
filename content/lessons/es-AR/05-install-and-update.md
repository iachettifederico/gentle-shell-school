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

No confundas `upgrade` con `gentle-shell update`. `gentle-shell update` sin
argumentos actualiza el Pi que corre este lanzador: verifica qué paquete global de
npm o pnpm provee ese Pi, reinstala exactamente ese paquete e informa si cambió la
versión de Pi. Cuando el dueño es desconocido o ambiguo, se niega sin cambiar nada;
actualizá esas instalaciones con el gestor de paquetes que las provee. Con un
objetivo, o con `--extensions-only`, `update` reenvía el comando de actualización
de paquetes de Pi para el home seleccionado. Una instalación empaquetada en un
prefijo fija Pi junto con Gentle Shell, así que ahí Pi se sigue actualizando con
`gentle-shell upgrade`. Para llegar a un Pi publicado más nuevo que el que
verificó la versión, una instalación empaquetada puede ejecutar:

```bash
gentle-shell update --latest
```

Primero avisa que las funciones que dependen de partes internas auditadas de Pi
(como el editor Vim) pueden apagarse hasta que una versión de Gentle Shell
verifique ese Pi; después lo verifica y cambia a él como `upgrade`, guardando la
versión anterior para `gentle-shell upgrade --rollback`. Fuera de una instalación
empaquetada, `--latest` no cambia nada extra: `update` ya instala el Pi más nuevo.

Los
lanzadores más antiguos que no admiten `upgrade` deben usar el instalador más
reciente descrito en **Instalá Gentle Shell** en vez de tratar `upgrade` como un
prompt de chat.

## Reutilizá tus inicios de sesión de Pi

Por defecto, Gentle Shell corre en su propio home aislado, `~/.gentle-shell/agent`,
así que no ve los inicios de sesión que hiciste en Pi. En vez de compartir el home
de Pi con `--link`, podés copiarlos una vez:

```bash
gentle-shell home import-pi --dry-run
gentle-shell home import-pi
```

`--dry-run` muestra el plan y no escribe nada. La importación copia solo
`auth.json`, `mcp.json` y tu proveedor, modelo y nivel de razonamiento por defecto,
y solo donde el destino todavía no los tiene. Nunca sobrescribe, nunca copia
paquetes, extensiones ni sesiones y nunca escribe en tu home de Pi, así que volver a
correrla es seguro. La contra: cada home tiene ahora su propia copia de las
credenciales, y un proveedor que rota los tokens de actualización puede cerrar la
sesión de la copia que se actualice segunda. Si pasa, volvé a correr `/login` en
ese home.

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
