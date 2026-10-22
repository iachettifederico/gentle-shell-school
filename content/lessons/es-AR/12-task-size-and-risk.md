---
title: "Tamaño de tarea y riesgo"
description: "Clasificá el trabajo por entendimiento, capacidad de reanudación y consecuencias, no por conteos."
module: "Desarrollo Orgánico Impulsado"
---

# Tamaño de tarea y riesgo

“Pequeño” suele usarse para decir “no muchas líneas”. En ODD, eso no es lo que
significa. Un cambio de dos líneas puede ser peligroso; un cambio en varios
archivos puede ser rutinario y recuperable con facilidad. El tamaño de la tarea
decide si el trabajo necesita seguimiento duradero. El riesgo decide si un error
podría ser difícil de detectar, difícil de deshacer o alcanzar más allá del
cambio. Mantené las dos decisiones separadas.

## La definición de pequeño

Una tarea es pequeña solo cuando se cumplen **las tres** condiciones:

1. **Entendida:** se conocen el resultado, qué cambia y dónde cambia; no queda
   abierta ninguna decisión de producto o diseño; esto se establece en un lote de
   lectura acotado.
2. **Riesgo contenido:** no toca ningún elemento de alto riesgo nombrado.
3. **Reanudable desde el diff:** si la sesión se detuviera ahora, alguien podría
   terminar usando solo la solicitud original y `git diff`.

Si las tres son verdaderas, usá el camino pequeño: trabajo directo en línea,
comprobaciones enfocadas aplicables y comprobaciones de suite, sin documento de
funcionalidad ni reflejo en memoria salvo que la persona usuaria los pida. Una
tarea pendiente es opcional. El camino pequeño es deliberadamente liviano porque
ya tiene suficiente contexto para recuperarse.

El trabajo es grande solo cuando falla la prueba de reanudación. Podrían necesitarse
varias sesiones; una espera externa podría interrumpirlo; los requisitos podrían
perderse por la compactación; o las entregas podrían necesitar una secuencia
duradera. Entonces ODD lo registra. El trabajo grande no necesita automáticamente
un writer: la delegación necesita su propia razón, como unidades independientes en
paralelo o un respaldo de contexto.

## Los conteos son evidencia como mucho, nunca la regla

La cantidad de archivos, comandos, pruebas, arreglos o elementos de tareas
pendientes solicitados no clasifica una tarea. Tampoco lo hace el conteo de líneas
de una solicitud. Un diff grande puede seguir estando completamente entendido y
ser reanudable; un cambio diminuto en autenticación puede tener consecuencias
altas. Contar es tentador porque es visible, pero sustituye las preguntas reales:
¿entendemos el trabajo?, ¿podemos recuperarlo? y ¿las consecuencias están
contenidas?

Alrededor de 400 líneas de cambio de autoría es una heurística de planificación
orientativa para unidades de trabajo coherentes y carga de revisión. No es un
límite de tamaño de tarea, un criterio de aceptación ni una detención automática.
Nunca borres comentarios, espacios en blanco, documentación o pruebas, ni
comprimas código, solo para cumplirla. La lección **Commits y porciones** explica
cómo se usa el presupuesto de revisión después de la clasificación.

## Trabajo de alto riesgo

Un cambio es de alto riesgo cuando un error sería difícil de encontrar, difícil
de revertir o llegaría más allá del cambio local. ODD nombra seis categorías:

1. **Datos o efectos irreversibles:** migraciones, borrar o reescribir datos
   almacenados, cambios de formato o escribir datos sin validación.
2. **Seguridad:** autenticación, permisos, credenciales, secretos, guardas o
   límites de sandbox.
3. **Contratos existentes:** cambiar o quitar una API pública, flag de CLI,
   formato de configuración, exportación o prompt reflejado que otras personas
   ya usan.
4. **Concurrencia.**
5. **Entrega o entorno:** instaladores, lanzamientos, CI, despliegue o
   dependencias.
6. **Sin prueba de regresión:** un cambio para el cual ninguna prueba detectaría
   una regresión.

No todo campo nuevo de API ni comportamiento solicitado es un cambio de contrato
rupturista. La categoría trata de rupturas no solicitadas en comportamientos de los
que ya dependen otros consumidores. Del mismo modo, “poco claro” cuenta como alto
riesgo solo cuando una exploración acotada no puede determinar si se aplica una
de las primeras cinco categorías.

El alto riesgo cambia la ruta de verificación, no la necesidad de entender el
trabajo. Un elemento nombrado recibe autoverificación del writer y un verificador
independiente después de las comprobaciones propias del cambio. No significa que
todo trabajo necesite una revisión independiente solo porque sea sustancial.
**Pruebas primero y verificación** cubre en detalle la ruta de evidencia.

## La línea de riesgo

Cerrá cada cambio de código —pequeño o delegado— con una declaración corta y
explícita:

```text
Risk: item 2 (authentication guard changes access)
```

o:

```text
Risk: none
```

La línea vuelve observable la base para la verificación. Cuando corresponde,
nombra la categoría de alto riesgo numerada y una razón de una línea. Esto evita
que una decisión de encaminamiento importante desaparezca dentro de un resumen
vago. Una evaluación de riesgo nativa puede refinar su propio nivel cuando está
habilitada, pero no reemplaza nombrar un elemento de alto riesgo conocido ni
reduce el riesgo declarado después de una evaluación fallida.

## Ejemplos de clasificación

**Corrección de texto conocida.** El texto solicitado y la vista objetivo son
claros; no hay implicación de contrato, datos ni seguridad; el diff muestra
exactamente lo que falta. Esto es pequeño. Su línea de riesgo probablemente sea
`Risk: none`.

**Cambio en un formato de registro almacenado.** Incluso si la edición tiene solo
unas pocas líneas, los datos o la compatibilidad de formato están en juego. No
cumple el riesgo contenido y pertenece al alto riesgo. Explorá las consecuencias
y usá la ruta de verificación requerida.

**Una funcionalidad amplia con un punto de partida claro.** Podés conocer el
primer archivo que editar, pero si la solicitud original más un diff parcial no
preservarían los requisitos y la prueba restantes, falla la prueba de reanudación.
Es grande y necesita seguimiento antes de la primera escritura.

## Errores comunes

- **“Es solo un archivo.”** Un archivo puede contener un límite de seguridad o
  de contrato.
- **“Tiene 500 líneas, así que es grande.”** Decide la prueba de reanudación, no
  el volumen.
- **Llamar de inmediato alto riesgo a todo trabajo poco claro.** Primero hacé
  una exploración acotada; usá alto riesgo cuando eso no pueda determinar las
  categorías 1–5.
- **Ocultar el riesgo en prosa.** Indicá la línea de riesgo para que la ruta de
  verificación tenga una base visible.
- **Usar una etiqueta de alto riesgo como motivo para evitar la implementación.**
  Exige prueba proporcional, no parálisis.

## Probalo

Elegí un próximo cambio de repositorio. Para cada condición de tarea pequeña,
escribí una pieza de evidencia: qué prueba que lo entendés, por qué el riesgo está
o no contenido y si una persona colaboradora futura podría retomarlo a partir de
la solicitud y `git diff`. Después escribí su línea de riesgo. Si no podés aportar
una de esas piezas de evidencia, acabás de aprender exactamente qué explorar o
registrar después.
