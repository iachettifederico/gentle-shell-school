---
title: "Tamaño de la tarea y riesgo"
description: "Clasifica el trabajo por comprensión, capacidad de reanudación y consecuencias, no por conteos."
module: "Desarrollo Impulsado Orgánicamente"
---

# Tamaño de la tarea y riesgo

“Pequeño” suele usarse para decir “no muchas líneas”. En ODD, no significa eso. Un cambio de dos
líneas puede ser peligroso; un cambio en varios archivos puede ser rutinario y fácil de recuperar.
El tamaño de la tarea decide si el trabajo necesita seguimiento duradero. El riesgo decide si un
error podría ser difícil de detectar, difícil de deshacer o alcanzar más allá del cambio. Mantén
las dos decisiones separadas.

## La definición de pequeño

Una tarea es pequeña solo cuando se cumplen **las tres** condiciones:

1. **Comprendida:** se conocen el resultado, qué cambia y dónde cambia; no queda ninguna
   decisión de producto o diseño abierta; esto se establece en un lote de lectura acotado.
2. **Riesgo contenido:** no toca ningún elemento de alto riesgo nombrado.
3. **Reanudable desde el diff:** si la sesión se detuviera ahora, alguien podría terminar
   usando solo la solicitud original y `git diff`.

Si las tres son verdaderas, usa el camino pequeño: trabajo directo en línea, comprobaciones
focalizadas aplicables y comprobaciones de la suite, y ningún documento de funcionalidad ni
réplica en memoria salvo que la persona usuaria los solicite. Una tarea pendiente es opcional. El
camino pequeño es deliberadamente ligero porque ya tiene suficiente contexto para recuperarse.

El trabajo es grande solo cuando falla la prueba de reanudación. Podrían necesitarse varias
sesiones; una espera externa podría interrumpirlo; los requisitos podrían perderse por la
compactación; o las entregas podrían necesitar una secuencia duradera. Entonces ODD le da
seguimiento. El trabajo grande no necesita automáticamente quien escriba: la delegación necesita
su propia razón, como unidades independientes en paralelo o un respaldo de contexto.

## Los conteos son evidencia como mucho, nunca la regla

La cantidad de archivos, comandos, pruebas, correcciones o elementos de una lista de tareas
solicitados no clasifica una tarea. Tampoco el conteo de líneas de una solicitud. Un diff grande
puede seguir siendo plenamente comprendido y reanudable; un cambio diminuto en autenticación puede
tener consecuencias altas. Contar es tentador porque es visible, pero sustituye un indicador por
las preguntas reales: ¿comprendemos el trabajo?, ¿podemos recuperarlo? y ¿están contenidas las
consecuencias?

Unas 400 líneas modificadas creadas son una heurística de planificación orientativa para unidades
de trabajo coherentes y carga de revisión. No es un límite de tamaño de tarea, un criterio de
aceptación ni una detención automática. Nunca borres comentarios, espacios en blanco,
documentación o pruebas, ni comprimas código, solo para cumplirla. La lección **Commits y
segmentos** explica cómo se usa el presupuesto de revisión después de la clasificación.

## Trabajo de alto riesgo

Un cambio es de alto riesgo cuando un error sería difícil de encontrar, difícil de revertir o
llegaría más allá del cambio local. ODD nombra seis categorías:

1. **Datos o efectos irreversibles:** migraciones, borrar o reescribir datos almacenados,
   cambios de formato o escribir datos sin validación. Guardar registros nuevos no está en
   esta lista.
2. **Seguridad:** autenticación, permisos, credenciales, secretos, protecciones o límites de
   sandbox.
3. **Contratos existentes:** cambiar o eliminar una API pública, flag de CLI, formato de
   configuración, exportación o prompt replicado que otras personas ya usan. Agregar un flag,
   un comando o un campo opcional no está en esta lista.
4. **Concurrencia.**
5. **Entrega o entorno:** instaladores, lanzamientos, CI, despliegue o dependencias.
6. **Sin prueba de regresión:** un cambio para el que ninguna prueba detectaría una regresión.

No todo nuevo campo de API o comportamiento solicitado es un cambio de contrato incompatible. La
categoría se trata de rupturas no solicitadas en comportamientos de los que otras personas ya
dependen. Del mismo modo, “no claro” cuenta como alto riesgo solo cuando una revisión acotada no
puede determinar si se aplica una de las primeras cinco categorías.

El alto riesgo cambia la ruta de verificación, no la necesidad de comprender el trabajo. Un
elemento nombrado recibe autoverificación de quien escribe y una persona verificadora independiente
después de las comprobaciones propias del cambio. No significa que todo trabajo necesite una
revisión independiente solo porque sea sustancial. **Pruebas primero y verificación** cubre en
detalle la ruta de evidencia.

## La línea de riesgo

Cierra cada cambio de código—pequeño o delegado—con una declaración breve y explícita:

```text
Risk: item 2 (authentication guard changes access)
```

o:

```text
Risk: none
```

La línea hace observable la base de la verificación. Nombra la categoría numerada de alto riesgo
y una razón de una línea cuando corresponde. Esto evita que una decisión de encaminamiento
importante desaparezca dentro de un resumen vago. Una evaluación de riesgo nativa puede refinar
su propio nivel cuando está habilitada, pero no reemplaza nombrar un elemento de alto riesgo
conocido ni reduce el riesgo indicado después de una evaluación fallida.

## Ejemplos de clasificación

**Corrección de texto conocida.** El texto solicitado y la vista objetivo están claros; no hay
implicación de contrato, datos o seguridad; el diff muestra exactamente lo que queda. Esto es
pequeño. Su línea de riesgo probablemente sea `Risk: none`.

**Cambio en un formato de registro almacenado.** Incluso si la edición es de solo unas líneas,
los datos o la compatibilidad de formato están en juego. No cumple el riesgo contenido y pertenece
a alto riesgo. Explora las consecuencias y usa la ruta de verificación requerida.

**Una funcionalidad amplia con un punto de inicio claro.** Puedes conocer el primer archivo que
editar, pero si la solicitud original más un diff parcial no preservaran los requisitos y la prueba
restantes, no cumple la prueba de reanudación. Es grande y necesita seguimiento antes de la
primera escritura.

## Errores comunes

- **“Es solo un archivo”.** Un archivo puede contener un límite de seguridad o contrato.
- **“Tiene 500 líneas, así que es grande”.** La prueba de reanudación, no el volumen, decide.
- **Llamar inmediatamente alto riesgo a todo trabajo no claro.** Primero haz una revisión
  acotada; usa alto riesgo cuando esa revisión no pueda determinar las categorías 1–5.
- **Ocultar el riesgo en prosa.** Indica la línea de riesgo para que la ruta de verificación tenga
  una base visible.
- **Usar una etiqueta de alto riesgo como razón para evitar la implementación.** Requiere prueba
  proporcionada, no parálisis.

## Pruébalo

Elige un próximo cambio en el repositorio. Para cada condición de tarea pequeña, escribe una pieza
de evidencia: qué demuestra que la comprendes, por qué el riesgo está o no contenido, y si una
persona que contribuya en el futuro podría reanudar a partir de la solicitud y `git diff`. Luego
escribe su línea de riesgo. Si no puedes aportar una de esas piezas de evidencia, has aprendido
exactamente qué explorar o seguir después.
