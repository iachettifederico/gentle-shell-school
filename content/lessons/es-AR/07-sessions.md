---
title: "Sesiones y contexto"
description: "Usá los árboles de sesiones JSONL, las ramas y la compactación de Pi sin perder el hilo del trabajo."
module: "Primeros pasos"
---

# Sesiones y contexto

Una sesión útil de un agente debe sobrevivir a más de una sola respuesta. Pi guarda una
conversación como una **sesión** y la usa para reconstruir el contexto de solicitudes
posteriores. La parte sutil pero importante es que una sesión es un árbol, no un registro
plano de chat. Ese diseño te permite retomar una decisión anterior o explorar otro
enfoque sin destruir el trabajo que dejaste atrás.

## Qué persiste Pi

Las sesiones persistentes son archivos JSONL: un objeto JSON por línea. De forma
predeterminada, Pi las guarda en `~/.pi/agent/sessions/`, agrupadas por directorio de
trabajo. Gentle Shell corre por defecto en su propio home aislado, así que sus
sesiones viven en `~/.gentle-shell/agent/sessions/`; si lo arrancás con `--link`,
comparte el home y las sesiones de Pi. El archivo empieza con metadatos, y sus entradas posteriores usan IDs y enlaces
`parentId` para formar un árbol. Las entradas de sesión pueden registrar mensajes,
cambios de modelo, cambios de nivel de razonamiento, resúmenes de compactación,
resúmenes de ramas, uso, etiquetas y estado de extensiones.

El árbol es más que un detalle de almacenamiento. Cada camino a través de él es una rama.
La rama que termina en la entrada actual es la **rama activa**, y proporciona el historial
de conversación para la próxima solicitud al modelo. Pi no incorpora cada alternativa
abandonada en la próxima solicitud simplemente porque permanece en el mismo archivo.

De forma predeterminada, Pi guarda las sesiones automáticamente. `--no-session` hace que
una ejecución sea efímera, por lo que no se puede reanudar después de salir de Pi. Podés
ubicar las sesiones en otro lugar con `--session-dir`, `PI_CODING_AGENT_SESSION_DIR` o la
configuración `sessionDir`; la opción de CLI tiene la precedencia más alta.

## Continuar, reanudar y nombrar el trabajo

Desde el mismo directorio de trabajo, reanudá la sesión más reciente con:

```bash
pi --continue
```

Usá `pi --resume` para abrir el selector de sesiones. Dentro de Pi interactivo, `/resume`
abre ese selector, mientras que `/new` inicia una sesión nueva. Dale a una sesión un nombre
útil con `/name` o `--name`; un nombre hace que sea más fácil reconocer la sesión que su
primer prompt. `/session` muestra el archivo actual, el ID, la cantidad de mensajes, el
uso de tokens y el costo.

Estas acciones tienen funciones diferentes. Continuar dice “llevame de vuelta al hilo
reciente de esta carpeta”. Reanudar dice “dejame elegir un hilo guardado”. Nombrar dice
“hacé que este hilo sea reconocible más adelante”. Iniciar una nueva dice “no continúes
esta conversación”.

## Cuatro maneras de explorar sin perder el historial

Pi ofrece flujos de trabajo de ramificación relacionados pero diferentes:

| Acción | Resultado | Mejor uso |
|---|---|---|
| `/tree` | Moverse dentro del archivo de la sesión actual | Mantener juntas las alternativas relacionadas |
| `/fork` | Crear una sesión nueva desde un mensaje anterior del usuario | Darle a una alternativa su propia sesión |
| `/clone` | Copiar la rama activa actual en una sesión nueva | Hacer una copia separada del estado actual |

En `/tree`, elegir un mensaje del usuario vuelve a colocar su texto en el editor. Editalo y
envialo para crear otra rama. Elegir una respuesta del asistente u otra entrada continúa
después de esa entrada con un editor vacío. Esto hace que la navegación por el árbol sea
particularmente útil cuando la solicitud original era casi correcta pero necesita una nueva
variante.

Hacer fork separa la alternativa en una sesión nueva desde un mensaje anterior del usuario.
Clonar separa la rama activa actual tal como está ahora. Ninguna de las dos es una reversión
mágica de archivos en el directorio de trabajo: la ramificación de sesiones administra el
historial de conversación. Inspeccioná y administrá los cambios del repositorio por
separado.

Cuando dejás una rama mediante la navegación del árbol, Pi puede resumir el camino
abandonado y adjuntar ese resumen a la rama a la que entrás. Esto preserva el trabajo
relevante sin enviar cada mensaje anterior.

## El contexto es finito, así que Pi lo compacta

La solicitud al modelo contiene la rama activa junto con el prompt de sistema, los archivos
de contexto, las herramientas y las descripciones de skills. Las conversaciones largas se
acercan al límite de contexto de un modelo. Pi normalmente compacta el historial más
antiguo cuando el contexto activo se acerca a ese límite, y podés compactar manualmente:

```text
/compact
/compact Preserve the API decision and the open risks.
```

La compactación agrega una entrada de resumen y conserva los mensajes recientes. **No**
elimina las entradas originales del árbol de sesión. Para las solicitudes posteriores, Pi usa
el resumen en lugar del tramo más antiguo más las entradas desde un límite conservado
almacenado en adelante. Las entradas sin procesar siguen siendo útiles para el historial de
la transcripción y otras operaciones de sesión.

Por eso una instrucción concisa para `/compact` puede importar: le indica al resumidor qué
tema o decisión debe sobrevivir en el contexto comprimido. También es por eso que la
compactación no es una excusa para evitar registros duraderos del proyecto en trabajos
grandes; un resumen es una herramienta de gestión de contexto, no una especificación de
funcionalidad.

La compactación automática puede fallar cuando el proveedor no está disponible o no puede
aceptar la solicitud de resumen. Corregí el problema del proveedor y ejecutá `/compact` de
nuevo. Deshabilitar la compactación automática no deshabilita el comando manual.

## Qué cambia realmente una compactación

Pi encuentra un punto de corte, resume los mensajes anteriores y agrega una entrada
`compaction` con un `firstKeptEntryId`. La reconstrucción del contexto usa la compactación
más reciente en el camino activo: el resumen representa el material más antiguo y los
mensajes que comienzan en ese ID conservado siguen disponibles. La solicitud de resumen
omite bloques de razonamiento y trunca los resultados serializados de herramientas, lo que
mantiene el resumen dentro de un tamaño manejable.

Por lo tanto, el archivo de sesión distingue dos preguntas:

- ¿Qué se registró originalmente?
- ¿Qué es actualmente visible para el modelo como contexto?

Un `context_edit` también puede omitir o reemplazar una entrada anterior para el contexto
de modelos futuro sin cambiar el historial sin procesar, la UI, las exportaciones ni la
contabilidad de la sesión. Es un detalle avanzado del formato de sesión, pero refuerza el
mismo principio: Pi puede revisar el contexto futuro mientras preserva el registro
subyacente.

## Scratch de sesión

Desde v4.3.0, cada sesión principal de Gentle Shell tiene su propio directorio
scratch (llamado `gpXXXXXX`) y corre con `TMPDIR` apuntando a él, así que cada
`mktemp` que corre el agente cae ahí. Cada subagente recibe su propio directorio
`gaXXXXXX` adentro. Si el scratch no se puede crear, la sesión se queda con el
`TMPDIR` heredado. Un registro en el directorio de configuración anota el scratch y
cada clon o worktree que crea en la sesión un `git clone` o `git worktree add`
exitoso en primer plano.

La limpieza es automática solo para el scratch: al cerrar se borra el scratch de la
sesión, salvo el `TMPDIR` de un subagente activo o en cuarentena (todavía corriendo,
o con su salida sin confirmar), que queda junto con el scratch que lo rodea. Un
inicio de sesión posterior barre el scratch que dejaron sesiones terminadas hace más
de una hora. Los clones y worktrees registrados quedan hasta que
los limpiés:

```text
/gentle:scratch list
/gentle:scratch clean
```

`list` muestra el scratch con su tamaño y los clones y worktrees registrados.
`clean` vacía el scratch de la sesión actual sin preguntar, conservando solo el
scratch de subagentes, los clones y worktrees registrados y las entradas modificadas
en el último minuto, y borra el scratch que dejaron las sesiones terminadas. Después
pregunta una vez antes de borrar clones y worktrees registrados que no tengan
trabajo sin commitear ni sin pushear. Sin interfaz, solo borra scratch. Nunca borra
el scratch de otra sesión activa, pero sí el tuyo: guardá cualquier archivo que
todavía necesités de `TMPDIR` antes de correrlo.

## Errores comunes

- **Pensar que una sesión es lineal.** Es un árbol, y la rama activa importa.
- **Usar `/clone` cuando necesitás una alternativa anterior.** Usá `/tree` o
  `/fork` desde el mensaje anterior del usuario.
- **Tratar la compactación como eliminación.** Las entradas originales permanecen guardadas.
- **Suponer que ramificar la conversación deshace ediciones del repositorio.** Solo cambia
  el historial de sesión y el contexto futuro.
- **Exportar una sesión sin cuidado.** Puede contener prompts, argumentos de herramientas,
  salida de comandos, contenido de archivos y credenciales expuestas en la conversación.

## Probalo

Ejecutá `/session` y dale a la sesión un nombre reconocible con `/name`. Después abrí
`/tree` e identificá un mensaje anterior del usuario que podrías revisar sin eliminar el
camino actual. Por último, describí qué le indicarías a `/compact` que conserve antes de
que una investigación larga se vuelva demasiado grande para el contexto del modelo actual.
