---
title: "Desarrollo Orgánico Impulsado"
description: "Usá ODD para convertir una solicitud autorizada en trabajo recuperable y proporcional."
module: "Desarrollo Orgánico Impulsado"
---

# Desarrollo Orgánico Impulsado

Un agente de programación puede parecer productivo mientras, silenciosamente,
hace que el trabajo sea más difícil de recuperar, revisar o corregir. Puede
empezar a editar antes de entender el repositorio, convertir un arreglo de dos
líneas en un ritual de planificación o dejar un cambio grande sin un registro
duradero de qué se pidió y qué se probó. **El Desarrollo Orgánico Impulsado
(ODD)** es el flujo de trabajo cotidiano que evita ambos extremos.

ODD no es un comando aparte ni un sistema rígido de gestión de proyectos. Es una
disciplina de encaminamiento: explorá antes de cambiar, resolvé solo la
incertidumbre real y hacé que la cantidad de proceso sea proporcional al
entendimiento, al riesgo y a la posibilidad de que el trabajo deba retomarse más
tarde. Esta lección cubre el recorrido general. Las próximas lecciones
profundizan en la autorización, el tamaño, el seguimiento, la verificación y los
commits revisables.

## El recorrido de siete pasos

ODD se aplica a cada solicitud, mencione o no un plan.

1. **Autorizá.** El agente es de solo lectura hasta que la implementación esté
   autorizada. Si la intención es ambigua, hace una aclaración.
2. **Explorá.** Leé el código y los requisitos relevantes antes de cambiarlos,
   con una profundidad proporcional a la solicitud.
3. **Resolvé la incertidumbre.** Investigá o hacé una pregunta enfocada sobre el
   producto solo cuando haya una decisión real sin resolver.
4. **Clasificá.** Decidí si el trabajo es pequeño o grande usando la prueba de
   reanudación, no el conteo de archivos ni de líneas.
5. **Hacé seguimiento antes de la primera escritura.** Para trabajo grande, creá
   un documento de funcionalidad y reflejalo en Engram con alcance de proyecto
   cuando haya memoria disponible.
6. **Implementá tarea por tarea.** Usá el flujo de trabajo seguro más pequeño,
   pruebas aplicables y unidades de trabajo revisables.
7. **Cerrá.** Indicá el resultado verificado, las comprobaciones fallidas o
   pendientes y qué debería ocurrir después.

El orden importa. La exploración no es procrastinación: hace que la primera
escritura sea informada. La clasificación no es una conjetura sobre el esfuerzo:
elige si el trabajo necesita continuidad. El cierre no es una casilla: comunica
la prueba real y la incertidumbre restante.

## Por qué importa un proceso proporcional

ODD deliberadamente tiene un camino liviano. Una solicitud pequeña, entendida y
con riesgo contenido que alguien pudiera terminar a partir de la solicitud
original y `git diff` solamente no necesita un documento de funcionalidad, un
reflejo en memoria ni un artefacto de seguimiento separado. Se mantiene en línea.
El trabajo de investigación y el de solo propuesta también permanecen de solo
lectura.

Por el contrario, el trabajo autorizado sustancial necesita un punto de
recuperación duradero. De otro modo, una interrupción puede hacer perder las
restricciones originales, qué comprobaciones ya se ejecutaron, por qué cambió una
tarea y cuál es la próxima acción segura. El documento de funcionalidad captura
esa continuidad sin crear un segundo archivo de plan ni un diario exhaustivo. Su
reflejo en Engram, cuando está disponible, permite que el padre recupere el mismo
registro entre sesiones.

Por eso, ODD se entiende mejor como una disciplina de ejecución que como la
redacción de un prompt. Un prompt puede pedirle a un agente que sea cuidadoso,
pero el flujo de trabajo crea límites observables: ninguna escritura antes de la
autorización, exploración antes de la implementación, una prueba concreta para
el tamaño de la tarea, un registro local para trabajo sustancial y verificación
honesta al final. La disciplina cambia qué evidencia existe cuando la próxima
persona —o el mismo agente después de una interrupción— necesita continuar.

## La prueba de reanudación es el punto de apoyo

La pregunta de clasificación es práctica: si la sesión se detuviera ahora, ¿podría
alguien terminar la solicitud a partir de la solicitud original y `git diff`
solamente? Si la respuesta es sí, y el riesgo está contenido y el resultado se
entiende, el trabajo es pequeño. Si no, es grande. Una tarea puede ser grande
porque probablemente requiera varias sesiones, los requisitos podrían perderse
durante la compactación o las entregas necesitan coordinación duradera.

Los conteos **no** clasifican una tarea. Muchos archivos, comandos, pruebas,
arreglos o una lista de tareas solicitada no hacen que el trabajo sea grande
automáticamente. Tampoco lo hace una estimación de cantidad de líneas. Eso evita
que el proceso crezca solo porque un cambio toca varios archivos. La lección
**Tamaño de tarea y riesgo** desarrolla más esta prueba.

## Un padre, un registro

Para trabajo grande, la sesión padre sigue siendo responsable incluso cuando la
ayudan workers acotados. Les pasa el localizador del documento de funcionalidad,
los IDs de tarea, los requisitos vinculados, el alcance autorizado y las
comprobaciones. Los workers leen el documento antes de editar en lugar de recibir
una paráfrasis con pérdida. Esto protege cadenas exactas, mensajes de error,
ejemplos y criterios de aceptación.

El padre también reconcilia el progreso. Los hallazgos no amplían el alcance en
silencio, y una casilla completada necesita prueba observada. Si la memoria no
está disponible, el progreso local sigue siendo lo primero; un reflejo no
disponible se registra como pendiente en lugar de inventarse como éxito. La
lección **Seguimiento de funcionalidades** explica el registro en detalle,
mientras que **Delegación** más adelante explica cuándo resulta útil un worker
acotado.

## Un ejemplo compacto

Imaginá: “Cambiá la etiqueta de este botón”. Si se conocen la ubicación y la
etiqueta deseada, el riesgo está contenido y el cambio podría retomarse a partir
de la solicitud y el diff, este es trabajo autorizado pequeño: inspeccioná,
editá, ejecutá una comprobación aplicable e informá el resultado.

Ahora imaginá: “Agregá un módulo curricular con varias lecciones, validación y
una entrega revisable”. La tarea tiene varios requisitos y una necesidad probable
de recuperación. Después de explorarla, debe registrarse antes de escribir. El
documento preserva la especificación, la evidencia a nivel de tarea y el próximo
paso mientras cada tarea se implementa y comprueba.

## Errores comunes

- **Hacer seguimiento de cada solicitud.** Esto vuelve el trabajo simple más
  lento sin mejorar la recuperación. Usá la prueba de reanudación.
- **Tratar la exploración como permiso para editar.** Leer y proponer siguen
  siendo de solo lectura hasta que la implementación esté autorizada.
- **Usar el conteo de líneas como clasificador.** No es la regla de tamaño.
- **Marcar trabajo como hecho porque se intentó.** Registrá solo prueba
  observada.
- **Llamar a la rama de funcionalidad el candidato de revisión.** ODD usa un
  commit de unidad de trabajo o una porción de PR, no una rama acumulada ni una
  casilla de TODO.

## Probalo

Buscá una solicitud que podrías hacer en un repositorio. Primero anotá qué
necesitarías inspeccionar antes de editar. Después hacete la pregunta de
reanudación: si te detuvieras después del primer cambio, ¿la solicitud original
más `git diff` le dirían a otra persona todo lo necesario para terminar? Usá tu
respuesta para elegir el camino pequeño o el camino con seguimiento. En las
lecciones siguientes aprenderás las reglas precisas para esa elección y la
evidencia que necesita cada camino.
