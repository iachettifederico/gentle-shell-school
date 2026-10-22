---
title: "Desarrollo Impulsado Orgánicamente"
description: "Usa ODD para convertir una solicitud autorizada en trabajo recuperable y proporcionado."
module: "Desarrollo Impulsado Orgánicamente"
---

# Desarrollo Impulsado Orgánicamente

Un agente de programación puede parecer productivo mientras, discretamente, hace que el
trabajo sea más difícil de recuperar, revisar o corregir. Puede empezar a editar antes de
comprender el repositorio, convertir una corrección de dos líneas en un ritual de planificación,
o dejar un cambio grande sin un registro duradero de lo que se solicitó y de lo que se comprobó.
**Organic Driven Development (ODD)** es el flujo de trabajo cotidiano que evita ambos extremos.

ODD no es un comando separado ni un sistema rígido de gestión de proyectos. Es una
disciplina de encaminamiento: explora antes de cambiar, resuelve solo la incertidumbre real y
haz que la cantidad de proceso sea proporcional a la comprensión, el riesgo y la posibilidad
de que el trabajo deba retomarse más adelante. Esta lección cubre el recorrido general. Las
próximas lecciones explican la autorización, el dimensionamiento, el seguimiento, la verificación
y los commits revisables.

## El recorrido de siete pasos

ODD se aplica a cada solicitud, mencione o no un plan.

1. **Autoriza.** El agente es de solo lectura hasta que se autorice la implementación. Si
   la intención es ambigua, hace una aclaración.
2. **Explora.** Lee el código y los requisitos relevantes antes de cambiarlos, con una
   profundidad proporcional a la solicitud.
3. **Resuelve la incertidumbre.** Investiga o haz una pregunta enfocada sobre el producto solo
   cuando haya una decisión real sin resolver.
4. **Clasifica.** Decide si el trabajo es pequeño o grande mediante la prueba de reanudación,
   no por el número de archivos o líneas.
5. **Haz seguimiento antes de la primera escritura.** Para trabajo grande, crea un documento de
   funcionalidad y replícalo en Engram con alcance de proyecto cuando la memoria esté disponible.
6. **Implementa tarea por tarea.** Usa el flujo de trabajo seguro más pequeño, las pruebas
   aplicables y unidades de trabajo revisables.
7. **Cierra.** Indica el resultado verificado, las comprobaciones fallidas o pendientes y qué
   debería ocurrir después.

El orden es importante. La exploración no es procrastinación: hace que la primera escritura
sea informada. La clasificación no es una conjetura sobre el esfuerzo: elige si el trabajo
necesita continuidad. El cierre no es una casilla: comunica la prueba real y la incertidumbre
restante.

## Por qué importa un proceso proporcionado

ODD tiene deliberadamente un camino ligero. Una solicitud pequeña y comprendida, con riesgo
contenido, que alguien podría terminar a partir de la solicitud original y `git diff` por sí
solos no necesita un documento de funcionalidad, una réplica en memoria ni un artefacto de
seguimiento separado. Se mantiene en línea. La investigación y el trabajo de propuesta también
permanecen en modo de solo lectura.

Por el contrario, el trabajo autorizado sustancial necesita un punto de recuperación duradero.
De otro modo, una interrupción puede perder las restricciones originales, qué comprobaciones ya
se ejecutaron, por qué cambió una tarea y cuál es la siguiente acción segura. El documento de
funcionalidad captura esa continuidad sin crear un segundo archivo de plan ni un diario
exhaustivo. Su réplica en Engram, cuando está disponible, permite que la sesión principal
recupere el mismo registro entre sesiones.

Por eso ODD se entiende mejor como una disciplina de ejecución que como la redacción de un
prompt. Un prompt puede pedirle a un agente que sea cuidadoso, pero el flujo de trabajo crea
límites observables: ninguna escritura antes de la autorización, exploración antes de la
implementación, una prueba concreta para el tamaño de la tarea, un registro local para el
trabajo sustancial y verificación honesta al final. La disciplina cambia qué evidencia existe
cuando la siguiente persona—o el mismo agente después de una interrupción—necesita retomar el
trabajo.

## La prueba de reanudación es el punto clave

La pregunta de clasificación es práctica: si la sesión se detuviera ahora, ¿podría alguien
terminar la solicitud a partir de la solicitud original y `git diff` por sí solos? Si la
respuesta es sí, y el riesgo está contenido y el resultado se comprende, el trabajo es pequeño.
Si no, es grande. Una tarea puede ser grande porque probablemente se necesiten varias sesiones,
los requisitos podrían perderse durante la compactación o las entregas necesitan coordinación
duradera.

Los conteos **no** clasifican una tarea. Muchos archivos, comandos, pruebas, correcciones o una
lista de tareas solicitada no hacen que el trabajo sea grande automáticamente. Tampoco una
estimación de cantidad de líneas. Esto evita que el proceso crezca solo porque un cambio toca
varios archivos. La lección **Tamaño de la tarea y riesgo** explica esta prueba con más detalle.

## Una sesión principal, un registro

Para trabajo grande, la sesión principal sigue siendo responsable incluso cuando ayudan
trabajadores acotados. Les transmite el localizador del documento de funcionalidad, los ID de
tareas, los requisitos vinculados, el alcance autorizado y las comprobaciones. Los trabajadores
leen el documento antes de editar en lugar de recibir una paráfrasis que pierde información.
Esto protege cadenas exactas, mensajes de error, ejemplos y criterios de aceptación.

La sesión principal también reconcilia el progreso. Los hallazgos no expanden el alcance en
silencio y una casilla completada necesita prueba observada. Si la memoria no está disponible,
el progreso local sigue siendo lo primero; una réplica no disponible se registra como pendiente
en lugar de inventarse como éxito. La lección **Seguimiento de funcionalidades** explica el
registro en detalle, mientras que **Delegación** explica más adelante cuándo es útil un
trabajador acotado.

## Un ejemplo breve

Imagina: “Cambia la etiqueta de este botón”. Si se conocen la ubicación y la etiqueta deseada,
el riesgo está contenido y el cambio podría retomarse a partir de la solicitud y el diff, este
es trabajo autorizado pequeño: inspecciona, edita, ejecuta una comprobación aplicable e informa
el resultado.

Ahora imagina: “Agrega un módulo de currículo con varias lecciones, validación y una entrega
revisable”. La tarea tiene varios requisitos y una necesidad probable de recuperación. Después
de explorar, debe seguirse antes de escribir. El documento preserva la especificación, la
evidencia a nivel de tarea y el siguiente paso mientras cada tarea se implementa y comprueba.

## Errores comunes

- **Dar seguimiento a cada solicitud.** Esto hace que el trabajo simple sea más lento sin
  mejorar la recuperación. Usa la prueba de reanudación.
- **Tratar la exploración como permiso para editar.** Leer y proponer siguen siendo de solo
  lectura hasta que se autorice la implementación.
- **Usar el número de líneas como clasificador.** No es la regla de tamaño.
- **Marcar trabajo como terminado porque se intentó.** Registra solo prueba observada.
- **Llamar a la rama de funcionalidad el candidato de revisión.** ODD usa un commit de unidad de
  trabajo o un segmento de PR, no una rama acumulada ni una casilla de TODO.

## Pruébalo

Encuentra una solicitud que podrías hacer en un repositorio. Primero anota qué necesitarías
inspeccionar antes de editar. Luego haz la pregunta de reanudación: si te detuvieras después del
primer cambio, ¿la solicitud original más `git diff` le dirían a otra persona todo lo necesario
para terminar? Usa tu respuesta para elegir el camino pequeño o el camino con seguimiento. En
las siguientes lecciones, aprenderás las reglas precisas para esa elección y la evidencia que
necesita cada camino.
