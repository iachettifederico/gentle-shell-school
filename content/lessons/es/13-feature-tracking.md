---
title: "Seguimiento de funcionalidades"
description: "Mantén el trabajo grande recuperable con un documento de funcionalidad, un reflejo en memoria y una proyección de tareas pendientes."
module: "Desarrollo Impulsado Orgánicamente"
---

# Seguimiento de funcionalidades

El trabajo grande necesita un mecanismo de recuperación, no una pila de notas desconectadas. En ODD,
ese mecanismo es **un documento de funcionalidad** en `odd/tasks/<feature-name>.md`.
Es la especificación duradera que los trabajadores leen por referencia, el registro local de
progreso y evidencia, y la fuente de la que se deriva la lista visible de tareas pendientes.
Cuando Engram está disponible, el responsable refleja el documento completo en la
memoria con alcance de proyecto bajo `odd/<feature-name>/tasks`.

La frase “un documento” importa. Un plan separado, un resumen parcial en memoria
y una lista de tareas pendientes editada independientemente se desvían entre sí. En cambio, ODD
les da roles claros: el archivo de tareas es la autoridad local, Engram es la copia de
recuperación y Todo es una proyección de la interfaz de usuario.

## Cuándo comienza el seguimiento

El seguimiento comienza solo para una **implementación autorizada grande**, después de la exploración
y antes de la primera escritura. Una tarea pequeña y comprendida no necesita un artefacto de funcionalidad
duradero solo porque una interfaz pueda mostrar tareas pendientes. El trabajo de investigación y solo propuesta
permanece de solo lectura.

El responsable crea el documento automáticamente para el trabajo grande; no pide permiso
separado para seguimiento de tareas ni almacenamiento. Elige un nombre de funcionalidad descriptivo,
seguro para nombres de archivo y no sobrescribe otra funcionalidad. El responsable sigue siendo
responsable de la conciliación incluso cuando asigna una tarea delimitada a un trabajador.

## Anatomía del documento

El orden fijo mantiene la intención estable por encima del historial creciente:

1. **Encabezado:** dos o tres líneas que nombran el objetivo, la rama, la estrategia
   de entrega y el ejecutor de pruebas.
2. **`## Specs`:** requisitos numerados de `S1` a `Sn`, restricciones y
   criterios de aceptación con sus verificaciones. Las cadenas exactas del usuario, comandos,
   ejemplos y mensajes de error se citan literalmente en el idioma del usuario.
   Pueden numerarse y ordenarse, pero no resumirse ni reformularse. Las suposiciones
   se marcan como suposiciones en vez de introducirse como requisitos.
3. **`## Tasks`:** IDs de tarea estables, una línea por tarea, elementos `S#` vinculados, ruta
   (en línea o delegada), estado e identidad de commit o evidencia de RED/GREEN.
4. **`## Log`:** el cuaderno de bitácora. `L1` contiene la solicitud original literalmente;
   las correcciones posteriores del usuario se agregan literalmente con su fecha. La justificación
   significativa, la evidencia de verificación, el progreso y el siguiente paso pertenecen aquí.

Por esto se les pide a los trabajadores que lean un documento de funcionalidad hasta `## Log` antes
de editar. El material estable les indica qué se debe construir sin gastar contexto en el
registro creciente, mientras el responsable conserva el registro completo para la recuperación.

## Los requisitos literales preservan la intención

El texto exacto es más que formato. Los mensajes de error, comandos, ejemplos y el
lenguaje de aceptación suelen contener un detalle que una transferencia condensada pierde.
Pasar el localizador del documento permite que el trabajador lea esa evidencia directamente en
vez de confiar en la paráfrasis de un intermediario. El responsable transmite los IDs de tarea, los
requisitos vinculados, el alcance autorizado y las verificaciones; el trabajador no tiene autoridad para
ampliar tareas no relacionadas.

Cuando un cambio aceptado del usuario, la revisión o la verificación modifica el trabajo, actualiza
la intención y las tareas juntas. Conserva el trabajo válido completado y no relacionado; agrega una
nueva tarea o reabre una tarea invalidada con una razón y verificaciones revisadas.
Los hallazgos por sí solos no autorizan ampliar el alcance. Las correcciones rutinarias se mantienen cerca
de sus tareas. Una casilla de verificación requiere evidencia observada, no un intento.

## Primero local, después memoria

El responsable escribe primero el progreso local, luego refleja el **documento actual completo**
y el localizador relativo al repositorio en Engram, y lee ambos de vuelta
porque las escrituras no son atómicas. Si Engram no está disponible, el seguimiento local continúa.
Registra que el reflejo está pendiente; no afirmes que la persistencia ocurrió,
y no bloquees trabajo seguro no relacionado. Cuando esté disponible, resincroniza.

El reflejo no es una licencia para sobrescribir el archivo local a ciegas. Al reanudar, el
responsable lee la memoria completa de la funcionalidad y el archivo de tareas real, y luego concilia
requisitos, código, evidencia de verificación y conflictos. Una copia faltante no es
permiso para sobrescribir la que sobrevivió. Conserva las versiones irreconciliables y
pregunta por el conflicto real en vez de elegir silenciosamente la marca de tiempo más reciente.

## Todo es visible, no autoritativo

Para trabajo grande, la herramienta Todo existente es la proyección de la sesión y de la interfaz de usuario. Después
de escribir y conciliar el archivo duradero y el reflejo, el responsable crea o
reconstruye la lista Todo a partir de las mismas tareas de funcionalidad antes de la primera escritura de código.
Después de las transiciones de tareas o cambios materiales en el plan, actualiza las copias duraderas y
la proyección en el mismo turno.

Una repetición de Todo, o borrar elementos completados, nunca debe eliminar ni reemplazar el
archivo de funcionalidad ni el reflejo en memoria. Si la proyección no está disponible, registra esa
limitación con honestidad. Si la dirección cambia, marca las tareas como `dropped` con una razón en el
Log; no las etiquetes como terminadas. Si se requiere una persona externa o autorización,
marca la tarea como `blocked` con la condición observable que la desbloquea. Un requisito previo
dentro de la lista es ordenamiento, no bloqueo.

## Recorrido de una reanudación

Supón que una sesión termina después de dos de cinco tareas. Para reanudar, no infieras el trabajo activo
a partir de la memoria global más reciente. Recupera la memoria específica del proyecto y la funcionalidad,
lee el archivo real de `odd/tasks` e inspecciona el código del repositorio y la
evidencia registrada. Compara los requisitos con el diff y la evidencia de pruebas.
Conserva un reflejo pendiente o ediciones en conflicto. Después elige la siguiente tarea sin terminar y actualiza
su alcance y verificaciones antes de la implementación.

Esta rutina es lo que hace recuperable el trabajo grande: trata el documento como un
registro vivo de intención y evidencia, no como un plan obsoleto que el código ya superó.

## Errores comunes

- **Crear seguimiento para trabajo pequeño.** Crea burocracia sin una necesidad de
  recuperación.
- **Poner una paráfrasis en Specs.** Cita el requisito exacto del usuario.
- **Tratar Todo como autoridad.** Es una proyección y puede estar desactualizada.
- **Reemplazar un documento completo para una actualización de tarea.** Haz ediciones dirigidas para que
  el progreso no relacionado permanezca intacto.
- **Afirmar que una escritura de memoria fallida funcionó.** Márcala como pendiente.

## Pruébalo

Abre un documento de funcionalidad en `odd/tasks/`. Si todavía no tienes uno, usa el
[documento de funcionalidad de la fase 11](https://github.com/iachettifederico/gentle-shell-school/blob/main/odd/tasks/phase-11-single-path.md)
de este mismo curso. Localiza `S1`, una tarea vinculada a un
`S#` y una entrada de Log con evidencia. Imagina que el archivo local y la copia en memoria entran en
conflicto después de una interrupción. Enumera qué compararías—requisitos, código
y verificaciones observadas—antes de decidir el siguiente paso. Ese es el hábito de recuperación
que permite que una funcionalidad sobreviva al límite de una sesión.
