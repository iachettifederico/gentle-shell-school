---
title: "Sesiones y contexto"
description: "Usa los árboles de sesiones JSONL, las ramas y la compactación de Pi sin perder el hilo del trabajo."
module: "Fundamentos"
---

# Sesiones y contexto

Una sesión útil de un agente debe sobrevivir a más de una sola respuesta. Pi guarda una
conversación como una **sesión** y la usa para reconstruir el contexto de solicitudes
posteriores. La parte sutil pero importante es que una sesión es un árbol, no un registro
plano de chat. Ese diseño te permite retomar una decisión anterior o explorar otro
enfoque sin destruir el trabajo que dejaste atrás.

## Qué persiste Pi

Las sesiones persistentes son archivos JSONL: un objeto JSON por línea. De forma
predeterminada, Pi las almacena en `~/.pi/agent/sessions/`, agrupadas por directorio de
trabajo. El archivo comienza con metadatos y sus entradas posteriores usan IDs y enlaces
`parentId` para formar un árbol. Las entradas de sesión pueden registrar mensajes, cambios
de modelo, cambios de nivel de razonamiento, resúmenes de compactación, resúmenes de
ramas, uso, etiquetas y estado de extensiones.

El árbol es más que un detalle de almacenamiento. Cada ruta a través de él es una rama. La
rama que termina en la entrada actual es la **rama activa**, y proporciona el historial de
conversación para la siguiente solicitud al modelo. Pi no incorpora cada alternativa
abandonada en la siguiente solicitud solo porque permanezca en el mismo archivo.

De forma predeterminada, Pi guarda las sesiones automáticamente. `--no-session` hace que
una ejecución sea efímera, por lo que no puede reanudarse después de que Pi finalice. Puedes
ubicar las sesiones en otro lugar con `--session-dir`, `PI_CODING_AGENT_SESSION_DIR` o el
ajuste `sessionDir`; la opción de CLI tiene la mayor precedencia.

## Continúa, reanuda y nombra el trabajo

Desde el mismo directorio de trabajo, reanuda la sesión más reciente con:

```bash
pi --continue
```

Usa `pi --resume` para abrir el selector de sesiones. Dentro de Pi interactivo, `/resume`
abre ese selector, mientras que `/new` inicia una sesión nueva. Dale a una sesión un nombre
útil con `/name` o `--name`; un nombre hace que la sesión sea más fácil de reconocer que su
primer prompt. `/session` muestra el archivo actual, ID, cantidad de mensajes, uso de tokens
y costo.

Estas acciones tienen trabajos distintos. Continuar dice “llévame de vuelta al hilo reciente
de esta carpeta”. Reanudar dice “déjame elegir un hilo guardado”. Nombrar dice “haz que este
hilo sea reconocible después”. Iniciar una nueva dice “no continúes esta conversación”.

## Cuatro formas de explorar sin perder el historial

Pi ofrece flujos de ramificación relacionados pero distintos:

| Acción | Resultado | Mejor uso |
|---|---|---|
| `/tree` | Moverse dentro del archivo de sesión actual | Mantener juntas las alternativas relacionadas |
| `/fork` | Crear una nueva sesión desde un mensaje anterior del usuario | Dar a una alternativa su propia sesión |
| `/clone` | Copiar la rama activa actual a una nueva sesión | Hacer una copia separada del estado actual |

En `/tree`, elegir un mensaje de usuario vuelve a poner su texto en el editor. Edítalo y
envíalo para crear otra rama. Elegir una respuesta del asistente u otra entrada continúa
después de esa entrada con un editor vacío. Esto hace que la navegación por el árbol sea
particularmente útil cuando la solicitud original estaba casi bien, pero necesita una nueva
variante.

Hacer fork separa la alternativa en una nueva sesión desde un mensaje anterior del usuario.
Clonar separa la rama activa actual tal como está ahora. Ninguna es una reversión mágica de
los archivos en el directorio de trabajo: la ramificación de sesiones gestiona el historial
de conversación. Inspecciona y gestiona los cambios del repositorio por separado.

Cuando abandonas una rama mediante la navegación por el árbol, Pi puede resumir la ruta
abandonada y adjuntar ese resumen a la rama a la que entras. Esto conserva el trabajo
relevante sin enviar cada mensaje anterior.

## El contexto es finito, así que Pi lo compacta

La solicitud al modelo contiene la rama activa junto con el prompt del sistema, archivos de
contexto, herramientas y descripciones de habilidades. Las conversaciones largas se acercan
al límite de contexto de un modelo. Normalmente, Pi compacta el historial anterior cuando el
contexto activo se acerca a ese límite, y puedes compactar manualmente:

```text
/compact
/compact Preserve the API decision and the open risks.
```

La compactación agrega una entrada de resumen y conserva los mensajes recientes. **No**
elimina las entradas originales del árbol de sesiones. Para solicitudes posteriores, Pi usa el
resumen en lugar del tramo anterior, además de las entradas desde un límite conservado
almacenado en adelante. Las entradas sin procesar aún sirven para el historial de la
transcripción y otras operaciones de sesión.

Por eso puede importar una instrucción concisa para `/compact`: le indica al resumidor qué
tema o decisión debe sobrevivir en el contexto comprimido. También es por eso que la
compactación no es una excusa para evitar registros duraderos del proyecto en trabajos
grandes; un resumen es una herramienta de gestión del contexto, no una especificación de una
funcionalidad.

La compactación automática puede fallar cuando el proveedor no está disponible o no puede
aceptar la solicitud de resumen. Corrige el problema del proveedor y vuelve a ejecutar
`/compact`. Desactivar la compactación automática no desactiva el comando manual.

## Qué cambia realmente una compactación

Pi encuentra un punto de corte, resume los mensajes anteriores y agrega una entrada de
`compaction` con un `firstKeptEntryId`. La reconstrucción de contexto usa la compactación más
reciente en la ruta activa: el resumen representa el material anterior y los mensajes que
comienzan en ese ID conservado permanecen disponibles. La solicitud de resumen omite bloques
de razonamiento y trunca resultados de herramientas serializados, lo que mantiene el resumen
dentro de un tamaño manejable.

Por lo tanto, el archivo de sesión distingue dos preguntas:

- ¿Qué se registró originalmente?
- ¿Qué está visible actualmente para el modelo como contexto?

Un `context_edit` también puede omitir o reemplazar una entrada anterior para el futuro
contexto del modelo sin cambiar el historial sin procesar, la UI, las exportaciones ni la
contabilidad de la sesión. Ese es un detalle avanzado del formato de sesión, pero refuerza el
mismo principio: Pi puede revisar el contexto futuro mientras conserva el registro
subyacente.

## Errores comunes

- **Pensar que una sesión es lineal.** Es un árbol, y la rama activa importa.
- **Usar `/clone` cuando necesitas una alternativa anterior.** Usa `/tree` o
  `/fork` desde el mensaje anterior del usuario.
- **Tratar la compactación como eliminación.** Las entradas originales permanecen almacenadas.
- **Suponer que la ramificación de la conversación deshace ediciones del repositorio.** Solo
  cambia el historial de sesión y el contexto futuro.
- **Exportar una sesión sin cuidado.** Puede contener prompts, argumentos de herramientas,
  salida de comandos, contenido de archivos y credenciales expuestas en la conversación.

## Pruébalo

Ejecuta `/session` y dale a la sesión un nombre reconocible con `/name`. Luego abre `/tree` e
identifica un mensaje anterior del usuario que podrías revisar sin eliminar la ruta actual.
Por último, describe qué le dirías a `/compact` que conserve antes de que una investigación
larga sea demasiado grande para el límite de contexto del modelo actual.
