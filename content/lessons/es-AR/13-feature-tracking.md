---
title: "Seguimiento de funcionalidades"
description: "Mantené el trabajo grande recuperable con un documento de funcionalidad, un reflejo en memoria y una proyección de tareas pendientes."
module: "Desarrollo guiado orgánicamente"
---

# Seguimiento de funcionalidades

El trabajo grande necesita un mecanismo de recuperación, no una pila de notas
sin conexión. En ODD, ese mecanismo es **un documento de funcionalidad** en
`odd/tasks/<feature-name>.md`. Es la especificación duradera que los workers leen
por referencia, el registro local del progreso y la evidencia, y la fuente de la
que se deriva la lista visible de tareas pendientes. Cuando Engram está disponible,
el padre refleja el documento completo en memoria con alcance de proyecto bajo
`odd/<feature-name>/tasks`.

La expresión “un documento” importa. Un plan separado, un resumen parcial en
memoria y una lista de tareas pendientes editada independientemente se desalinean.
En cambio, ODD les da roles claros: el archivo de tareas es la autoridad local,
Engram es la copia de recuperación y Todo es una proyección de la UI.

## Cuándo empieza el seguimiento

El seguimiento empieza solo para una **implementación autorizada grande**, después
de la exploración y antes de la primera escritura. Una tarea pequeña y entendida no
necesita un artefacto de funcionalidad duradero solo porque una UI pueda mostrar
tareas pendientes. El trabajo de investigación y de propuestas únicamente sigue
siendo de solo lectura.

El padre crea el documento automáticamente para el trabajo grande; no pide un
permiso separado para el seguimiento de tareas o el almacenamiento. Elige un nombre
de funcionalidad descriptivo y seguro para nombres de archivo, y no sobrescribe otra
funcionalidad. El padre sigue siendo responsable de la conciliación incluso cuando
asigna una tarea acotada a un worker.

## Anatomía del documento

El orden fijo mantiene la intención estable por encima del historial que crece:

1. **Encabezado:** dos o tres líneas que nombran el objetivo, la rama, la estrategia
   de entrega y el ejecutor de pruebas.
2. **`## Specs`:** requisitos numerados de `S1` a `Sn`, restricciones y criterios de
   aceptación con sus comprobaciones. Las cadenas exactas de la persona usuaria, los
   comandos, ejemplos y mensajes de error se citan literalmente en el idioma de la
   persona usuaria. Pueden numerarse y ordenarse, pero no resumirse ni reformularse.
   Las suposiciones se marcan como suposiciones en lugar de introducirse como
   requisitos.
3. **`## Tasks`:** IDs de tarea estables, una línea por tarea, elementos `S#`
   vinculados, ruta (en línea o delegada), estado, e identidad del commit o evidencia
   de RED/GREEN.
4. **`## Log`:** el cuaderno de bitácora. `L1` contiene la solicitud original
   literalmente; las correcciones posteriores de la persona usuaria se agregan
   literalmente con su fecha. La justificación significativa, la evidencia de
   verificación, el progreso y el siguiente paso pertenecen acá.

Por eso se les pide a los workers que lean un documento de funcionalidad hasta
`## Log` antes de editar. El material estable les dice qué deben construir sin gastar
contexto en el diario creciente, mientras el padre conserva el registro completo
para la recuperación.

## Los requisitos literales preservan la intención

El texto exacto es más que formato. Los mensajes de error, comandos, ejemplos y el
lenguaje de aceptación suelen contener un detalle que un traspaso condensado pierde.
Pasar el localizador del documento permite que el worker lea esa evidencia
directamente en vez de confiar en la paráfrasis de un intermediario. El padre reenvía
los IDs de tarea, los requisitos vinculados, el alcance autorizado y las
comprobaciones; el worker no tiene autoridad para ampliar tareas no relacionadas.

Cuando un cambio aceptado de una persona usuaria, revisión o verificación altera el
trabajo, actualizá la intención y las tareas juntas. Preservá el trabajo completado
válido y no relacionado; agregá una tarea nueva o reabrí una tarea invalidada con un
motivo y comprobaciones revisadas. Los hallazgos por sí solos no autorizan ampliar el
alcance. Las correcciones rutinarias permanecen cerca de sus tareas. Una casilla
requiere evidencia observada, no un intento.

## Primero local, después memoria

El padre escribe primero el progreso local, luego refleja el **documento actual
completo** y el localizador relativo al repositorio en Engram, y lee ambos de vuelta
porque las escrituras no son atómicas. Si Engram no está disponible, el seguimiento
local continúa. Registrá que el reflejo está pendiente; no afirmes que la
persistencia ocurrió, y no bloquees trabajo seguro no relacionado. Cuando esté
disponible, resincronizá.

El reflejo no es una licencia para sobrescribir el archivo local a ciegas. Al
reanudar, el padre lee la memoria completa de la funcionalidad y el archivo de tareas
real, y luego concilia requisitos, código, evidencia de verificación y conflictos.
Una copia faltante no es permiso para sobrescribir la sobreviviente. Preservá las
versiones irreconciliables y preguntá por el conflicto real en vez de elegir
silenciosamente la marca de tiempo más reciente.

## Todo es visible, no autoritativo

Para el trabajo grande, la herramienta Todo existente es la proyección de la sesión
y la UI. Después de escribir y conciliar el archivo duradero y el reflejo, el padre
crea o reconstruye la lista de Todo a partir de las mismas tareas de la funcionalidad
antes de la primera escritura de código fuente. Después de transiciones de tareas o
cambios materiales al plan, actualiza las copias duraderas y la proyección en el
mismo turno.

Una repetición de Todo, o borrar elementos completados, nunca debe eliminar ni
reemplazar el archivo de funcionalidad o el reflejo en memoria. Si la proyección no
está disponible, registrá esa limitación honestamente. Si la dirección cambia, marcá
las tareas como `dropped` con un motivo en el Log; no las etiquetes como terminadas.
Si se requiere una persona externa o autorización, marcá la tarea como `blocked` con
la condición observable que la desbloquea. Un prerrequisito dentro de la lista es
orden, no bloqueo.

## Un recorrido de reanudación

Supongamos que una sesión termina después de dos de cinco tareas. Para reanudar, no
infieras el trabajo activo a partir de la memoria global más reciente. Recuperá la
memoria específica del proyecto y la funcionalidad, leé el archivo real de
`odd/tasks` e inspeccioná el código y la evidencia registrada del repositorio.
Compará los requisitos con el diff y la evidencia de pruebas. Preservá un reflejo
pendiente o ediciones en conflicto. Luego elegí la siguiente tarea sin terminar y
actualizá su alcance y comprobaciones antes de la implementación.

Esta rutina es lo que hace recuperable el trabajo grande: trata el documento como un
registro vivo de intención y evidencia, no como un plan obsoleto que el código ya
superó.

## Errores comunes

- **Crear seguimiento para trabajo pequeño.** Genera burocracia sin una necesidad de
  recuperación.
- **Poner una paráfrasis en Specs.** Citá el requisito exacto de la persona usuaria.
- **Tratar Todo como autoridad.** Es una proyección y puede estar desactualizada.
- **Reemplazar un documento entero para actualizar una tarea.** Hacé ediciones
  puntuales para que el progreso no relacionado se mantenga intacto.
- **Afirmar que una escritura en memoria fallida funcionó.** Marcala como pendiente.

## Probalo

Abrí un documento de funcionalidad en `odd/tasks/`. Si todavía no tenés uno, usá el
[documento de funcionalidad de la fase 11](https://github.com/iachettifederico/gentle-shell-school/blob/main/odd/tasks/phase-11-single-path.md)
de este mismo curso. Ubicá `S1`, una tarea vinculada a
un `S#` y una entrada de Log con evidencia. Imaginá que el archivo local y la copia en
memoria entran en conflicto después de una interrupción. Enumerá qué compararías —los
requisitos, el código y las comprobaciones observadas— antes de decidir el siguiente
paso. Ese es el hábito de recuperación que permite que una funcionalidad sobreviva al
límite de una sesión.
