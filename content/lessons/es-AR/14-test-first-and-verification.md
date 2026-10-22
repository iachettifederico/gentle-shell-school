---
title: "Pruebas primero y verificación"
description: "Generá evidencia observable con RED, GREEN, casos alternativos y verificación proporcional."
module: "Desarrollo guiado orgánicamente"
---

# Pruebas primero y verificación

Un comando de pruebas no es evidencia de que un cambio funciona. Una suite en verde
puede no tener relación con el comportamiento que cambió, y una revisión puede
advertir problemas de diseño sin ejecutar el contrato. Por eso, ODD trata la
verificación como una secuencia de evidencia observable: usá desarrollo guiado por
pruebas cuando una prueba de comportamiento determinista y ejecutable tiene un
resultado esperado claro, y luego ejecutá comprobaciones proporcionales para la
tarea real.

El objetivo no es el ritual. Es volver concreto el comportamiento esperado antes de
que una implementación haga fácil racionalizar un resultado equivocado.

## Cuándo se aplica probar primero

Para un cambio de comportamiento, aplicá desarrollo guiado por pruebas de manera
predeterminada cuando se cumplan todas estas condiciones:

- una prueba determinista y ejecutable es aplicable;
- el resultado esperado es claro; y
- un RED de comportamiento sería significativo.

La presencia de un framework de pruebas —o incluso de pruebas cercanas— no establece
esas condiciones. Un cambio pasivo de documentación no necesita una prueba fallida
artificial. Tampoco un cambio no testeable, un ejecutor no disponible o un caso donde
no existe un RED significativo. En esos casos, indicá la excepción específica y
ejecutá en su lugar una verificación funcional o estructural ordinaria proporcional.
No afirmes evidencia de RED/GREEN que no observaste.

Esta distinción protege tanto la honestidad como la señal. Una prueba artificial que
falla por una razón no relacionada no enseña nada; fingir que la documentación tuvo
un RED es peor que describir claramente una comprobación estructural.

## El ciclo RED → GREEN → triangular → refactorizar

Cuando corresponda, usá un ciclo pequeño:

1. **RED:** agregá la prueba más pequeña a nivel de comportamiento que exprese el
   efecto observable solicitado. Ejecutá el comando enfocado y observá que falle por
   el comportamiento faltante previsto.
2. **GREEN:** implementá el cambio mínimo que haga pasar esa prueba. Ejecutala de
   nuevo y registrá el resultado observado exitoso.
3. **TRIANGULATE:** ejercitá casos negativos o alternativos relevantes que protejan
   materialmente el contrato. Un único camino feliz suele ser demasiado débil cuando
   una entrada inválida, otra rama o una condición de límite podría tener una
   regresión.
4. **REFACTOR:** mejorá la claridad solo mientras las pruebas enfocadas sigan en
   verde.

La palabra “observado” es crucial. Escribir una prueba que debería fallar no es RED
hasta que el ejecutor informa el fallo previsto. Editar código que debería satisfacerla
no es GREEN hasta que el ejecutor informa un resultado exitoso.

Las aserciones deberían apuntar a cada efecto observable requerido por el
comportamiento. Si un cambio tiene una salida visible, un resultado almacenado, una
condición de error y una interacción con un colaborador, probá los efectos que forman
su contrato, no solamente una variable interna que hoy cambia de casualidad. Esto hace
más segura la refactorización porque las pruebas describen lo que las personas usuarias
o quienes llaman pueden observar realmente.

## Primero las comprobaciones enfocadas

Ejecutá la prueba enfocada mientras iterás. Da retroalimentación rápida cerca del
cambio. Luego ejecutá la suite más amplia aplicable al cierre. Este orden ayuda a
localizar fallos: un fallo enfocado apunta directamente al comportamiento, mientras
que un fallo de suite puede revelar una unión de integración o un problema ambiental
no relacionado.

Para trabajo delegado, el padre proporciona el ejecutor y los comandos autorizados
exactos cuando se conocen, junto con la política de pruebas primero y toda
justificación de excepción. El writer ejecuta los comandos requeridos de forma
sincrónica en primer plano e informa cada uno como el comando exacto con su resultado
observado. Un comando requerido que falla no se oculta con un resumen prolijo. Un
fallo preexistente exacto nombrado por la tarea se informa como evidencia; otro fallo
requerido deja la tarea parcial.

## La verificación es más amplia que una prueba

Cada tarea necesita comprobaciones funcionales aplicables. Los detalles dependen de
lo que cambió: una prueba unitaria o de solicitud, una compilación o verificación de
tipos, una comprobación de navegador o UI, o una comprobación de carga estructural
para contenido. Una casilla de TODO no activa un ciclo de revisión ni demuestra el
comportamiento.

La revisión nativa de código tampoco sustituye la verificación funcional. La revisión
examina el cambio candidato desde una perspectiva independiente; las pruebas, las
compilaciones y las comprobaciones funcionales manuales ejecutan o inspeccionan el
contrato. Cuando la revisión nativa está habilitada, su candidato es un commit de
unidad de trabajo o una porción de PR, nunca una casilla de TODO ni toda la rama de
funcionalidad acumulada. Los tipos de evidencia separados detectan errores distintos.

Un padre también verifica puntualmente un comando informado antes de la entrega. Esto
evita construir una conclusión únicamente a partir de una entrega y ayuda a revelar
comandos no coincidentes o suposiciones ambientales.

## El riesgo cambia quién verifica

La regla de verificación es proporcional. Un cambio normal de riesgo bajo o medio usa
la autoverificación del writer y sus pruebas aplicables. Un cambio que toca un ítem de
alto riesgo nombrado recibe tanto autoverificación como una ejecución de verificador
separado. El disparador es la categoría de alto riesgo nombrada —datos, seguridad,
contratos existentes, concurrencia, entrega/entorno o falta de una prueba de
regresión—, no la cantidad de archivos, la elección de modelo ni el tamaño de la
tarea.

Incluso una evaluación nativa no disponible o fallida no demuestra que el trabajo sea
de bajo riesgo. A la inversa, la información de nivel nativo no excusa las
comprobaciones funcionales enfocadas. La línea de Riesgo de **Tamaño de la tarea y
riesgo** proporciona una razón clara para esta ruta.

## Ejemplo: agregar validación

Supongamos que una solicitud requiere rechazar un nombre de proyecto vacío. Escribí
una prueba que envíe el nombre vacío y afirme el rechazo observable. Ejecutala y
observá el fallo esperado. Implementá solo la validación suficiente para hacerla pasar.
Luego probá un nombre válido y, quizás, espacios en blanco si eso es parte del contrato
indicado. Una vez que esas comprobaciones estén en verde, refactorizá la configuración
duplicada sin cambiar el comportamiento afirmado.

Si la tarea solicitada es únicamente corregir un párrafo de una lección, el paso RED
no tiene un resultado de comportamiento significativo. Indicá que la excepción es
documentación pasiva y ejecutá en su lugar la comprobación de carga de contenido del
curso.

## Errores comunes

- **Llamar RED a una prueba no ejecutada.** La evidencia debe ser observada.
- **Probar aspectos internos en vez de efectos.** Preservá el comportamiento durante
  las refactorizaciones.
- **Detenerte después de GREEN.** Considerá casos alternativos que protejan el
  contrato.
- **Usar la revisión como reemplazo de pruebas.** Ambas son necesarias cuando
  corresponde.
- **Inventar un ejecutor.** Usá el comando autorizado del proyecto o informá la
  limitación.

## Probalo

Elegí un comportamiento que esperás cambiar. Indicá el efecto observable en una
oración y escribí la aserción más pequeña que distinguiría el comportamiento anterior
del nuevo. Nombrá el comando que mostrará RED y luego el mismo comando que mostrará
GREEN. Si no podés hacer esa distinción, identificá la excepción honesta y la
comprobación estructural o funcional que todavía aporta evidencia.
