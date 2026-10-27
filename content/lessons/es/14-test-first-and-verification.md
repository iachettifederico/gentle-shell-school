---
title: "Pruebas primero y verificación"
description: "Produce evidencia observable con RED, GREEN, casos alternativos y verificación proporcional."
module: "Desarrollo Impulsado Orgánicamente"
---

# Pruebas primero y verificación

Un comando de prueba no es evidencia de que un cambio funciona. Una suite en verde puede no estar relacionada
con el comportamiento que cambió, y una revisión puede detectar problemas de diseño sin
ejecutar el contrato. Por ello, ODD trata la verificación como una secuencia de
evidencia observable: usa desarrollo guiado por pruebas cuando una prueba de comportamiento determinista y ejecutable
tiene un resultado esperado claro, luego ejecuta verificaciones proporcionales para
la tarea real.

El objetivo no es el ritual. Es hacer que el comportamiento esperado sea concreto antes de que una
implementación facilite racionalizar el resultado incorrecto.

## Cuándo aplica probar primero

Para un cambio de comportamiento, aplica desarrollo guiado por pruebas de forma predeterminada cuando todo lo siguiente
es verdadero:

- una prueba determinista ejecutable es aplicable;
- el resultado esperado es claro; y
- un RED de comportamiento sería significativo.

La presencia de un framework de pruebas—incluso de pruebas cercanas—no establece esas
condiciones. Un cambio pasivo de documentación no necesita una prueba fallida artificial. Tampoco
un cambio no comprobable, un ejecutor no disponible o un caso donde no existe un RED
significativo. En esos casos, indica la excepción específica y ejecuta
verificación funcional o estructural ordinaria proporcional en su lugar. No afirmes evidencia RED/GREEN
que no se observó.

Esta distinción protege tanto la honestidad como la señal. Una prueba artificial que falla
por una razón no relacionada no enseña nada; fingir que la documentación tuvo un RED es
peor que describir una verificación estructural claramente.

## El ciclo RED → GREEN → triangular → refactorizar

Cuando aplique, usa un ciclo pequeño:

1. **RED:** agrega la prueba más pequeña a nivel de comportamiento que exprese el
   efecto observable solicitado. Ejecuta el comando enfocado y observa que falla por el
   comportamiento faltante previsto.
2. **GREEN:** implementa el cambio mínimo que hace que esa prueba pase. Ejecútala
   de nuevo y registra el resultado observado.
3. **TRIANGULATE:** ejercita casos negativos o alternativos relevantes que protejan materialmente
   el contrato. Un camino feliz suele ser demasiado débil cuando una entrada inválida,
   otra rama o una condición de límite podría regresar.
4. **REFACTOR:** mejora la claridad solo mientras las pruebas enfocadas sigan en verde.

La palabra “observado” es crucial. Escribir una prueba que debería fallar no es RED hasta
que el ejecutor informa el fallo previsto. Editar código que debería satisfacerla no es
GREEN hasta que el ejecutor informa un resultado exitoso.

Las aserciones deben dirigirse a cada efecto observable requerido por el comportamiento. Si un
cambio tiene una salida visible, un resultado almacenado, una condición de error y una
interacción con un colaborador, prueba los efectos que forman su contrato—no
solo una variable interna que casualmente cambia hoy. Esto hace que la refactorización sea
más segura porque las pruebas describen lo que los usuarios o quienes llaman pueden observar realmente.

## Primero las verificaciones enfocadas

Ejecuta la prueba enfocada mientras iteras. Da retroalimentación rápida cerca del
cambio. Luego ejecuta la suite más amplia aplicable al cierre. Este orden ayuda a
localizar fallos: un fallo enfocado apunta directamente al comportamiento, mientras que un
fallo de la suite puede revelar una unión de integración o un problema ambiental no relacionado.

Para trabajo delegado, el responsable proporciona el ejecutor y los comandos autorizados exactos
cuando se conocen, además de la política de pruebas primero y cualquier justificación de excepción. El escritor
ejecuta los comandos requeridos sincrónicamente en primer plano e informa cada uno como el
comando exacto con su resultado observado. Un comando requerido que falla no queda
oculto por un resumen limpio. Un fallo preexistente exacto nombrado por la tarea se
informa como evidencia; otro fallo requerido deja la tarea parcial.

## La verificación es más amplia que una prueba

Cada tarea necesita verificaciones funcionales aplicables. Los detalles dependen de lo que
cambió: una prueba de unidad o de solicitud, una compilación o verificación de tipos, una
verificación de navegador o interfaz de usuario, o una verificación de carga estructural para contenido. Una casilla
TODO no activa un ciclo de revisión ni prueba el comportamiento.

La revisión de código nativa tampoco sustituye la verificación funcional. La revisión
examina el cambio candidato desde una perspectiva independiente; las pruebas, compilaciones y
verificaciones funcionales manuales ejecutan o inspeccionan el contrato. Cuando la revisión nativa
está habilitada, su candidato es un commit de unidad de trabajo o una porción de PR, nunca una
casilla de verificación ni toda la rama acumulada de la funcionalidad. Los tipos de evidencia separados detectan
errores diferentes.

Un responsable también verifica puntualmente un comando informado antes de la entrega. Esto evita
construir una conclusión únicamente a partir de una transferencia y ayuda a revelar comandos
desajustados o suposiciones ambientales.

## El riesgo cambia quién verifica

La regla de verificación es proporcional. Un cambio normal de riesgo bajo o medio usa
la autoverificación del escritor y sus pruebas aplicables. Un cambio que toca un elemento de
alto riesgo nombrado recibe tanto autoverificación como una ejecución de verificación separada. El
activador es la categoría de alto riesgo nombrada—datos, seguridad, contratos existentes,
concurrencia, entrega/entorno o falta de una prueba de regresión—no el conteo de archivos,
la elección de modelo ni el tamaño de la tarea.

Incluso una evaluación nativa no disponible o fallida no prueba que el trabajo sea de bajo
riesgo. Por el contrario, la información del nivel nativo no excusa las verificaciones funcionales
enfocadas. La línea de riesgo de **Tamaño y riesgo de la tarea** ofrece una razón clara para
esta ruta.

## Ejemplo: agregar validación

Supón que una solicitud requiere rechazar un nombre de proyecto vacío. Escribe una prueba que
envíe el nombre vacío y afirme el rechazo observable. Ejecútala y observa el fallo
esperado. Implementa solo la validación suficiente para hacerla pasar. Luego prueba un
nombre válido y, quizás, espacios en blanco si eso es parte del contrato establecido. Una vez
que esas verificaciones estén en verde, refactoriza la configuración duplicada sin cambiar el comportamiento
afirmado.

Si la tarea solicitada es solo corregir un párrafo de una lección, el paso RED no tiene un
resultado de comportamiento significativo. Indica que la excepción es documentación pasiva y ejecuta la
verificación de carga de contenido del curso en su lugar.

## Comprobación diferencial

Cuando tu diff cambia código compartido (opciones, analizadores, ayudantes) que también usa un
comando existente que la solicitud no nombró, protege el comportamiento que no se pretendía
cambiar. Antes de terminar, ejecuta una comprobación diferencial como un único script: para cada
comando así, ejecuta la entrada nueva o cambiada tanto contra el cambio como contra una copia del
commit base en un directorio temporal `mktemp -d`, y compara stdout, stderr y el código de salida.
Una diferencia no solicitada es una regresión: corrígela y fíjala con una prueba. Cuando el diff no
toca código compartido, omite la comprobación. Mantén una prueba por cada comportamiento existente
tocado; las pruebas confirmadas nunca leen el historial de Git.

## Errores comunes

- **Llamar RED a una prueba no ejecutada.** La evidencia debe observarse.
- **Probar elementos internos en vez de efectos.** Conserva el comportamiento mediante refactorizaciones.
- **Detenerse después de GREEN.** Considera casos alternativos que protejan el contrato.
- **Usar revisión como reemplazo de pruebas.** Ambas son necesarias cuando aplican.
- **Inventar un ejecutor.** Usa el comando autorizado del proyecto o informa la
  limitación.

## Pruébalo

Elige un comportamiento que esperas cambiar. Indica el efecto observable en una oración y escribe
la aserción más pequeña que distinguiría el comportamiento anterior del nuevo. Nombra el comando
que mostrará RED, luego el mismo comando que mostrará GREEN. Si no puedes hacer esa
distinción, identifica la excepción honesta y la verificación estructural o funcional que aún proporciona
evidencia.
