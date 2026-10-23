---
title: "Proyecto final: una pequeña funcionalidad de principio a fin"
description: "Lidera una pequeña funcionalidad en un repositorio temporal mediante ODD, evidencia, delegación y revisión."
module: "Usuario avanzado"
---

# Proyecto final: una pequeña funcionalidad de principio a fin

Construye una pequeña funcionalidad en un repositorio temporal. Debe ser lo
suficientemente acotada como para explicarla, probarla y revisarla en una sola sesión.

Usa el curso completo como un sistema: **Layers**, **How Pi works**, **Sessions**,
**The workspace TUI** y **Models and providers** respaldan el trabajo de ODD que sigue.
El resultado es un comportamiento recuperable y verificado.

## 1. Elige y autoriza el alcance

Empieza con un problema, no con una implementación preferida. Una buena solicitud de
proyecto final indica quién observa el comportamiento y qué cambia para esa persona.
Ejemplos de forma, no ideas de producto prescritas, son: aceptar una entrada faltante
con un error claro, agregar una pequeña transformación o mostrar un dato ya disponible.
Evita la autenticación, las migraciones, la implementación externa, los rediseños
amplios y las funcionalidades cuya aceptación depende de una integración sin límites.

Aplica **Authorize and explore**: distingue el permiso para inspeccionar del permiso
para cambiar. Indica el repositorio previsto, el comportamiento y los límites. Pide
aclaración solo cuando resuelva una ambigüedad importante. La persona que dirige el
trabajo es propietaria de la elección de producto; un agente puede ayudar a convertirla
en una afirmación comprobable, pero no puede tomar esa decisión silenciosamente.

Luego aplica **Task size and risk**. Tu proyecto final sigue siendo pequeño cuando
comprendes el código relevante, el efecto esperado y la vía de recuperación. Si la
exploración revela un segundo comportamiento independiente, divídelo. ¿Podría una nueva
sesión terminar a partir de la solicitud, el registro de la funcionalidad y el diff
actual sin volver a descubrir decisiones? Si no, mejora el registro o reduce el alcance.

## 2. Explora antes de construir

Usa exploración de solo lectura para trazar las convenciones del repositorio, el runner
de pruebas, el comportamiento vecino existente y cualquier instrucción aplicable. El
objetivo no es recopilar todos los archivos. Es responder las preguntas que afectan el
cambio pequeño: dónde corresponde la política, dónde una prueba la demuestra y qué
comportamiento existente debe permanecer sin cambios.

Si la comprensión supera una breve pasada en línea, usa **Subagents** deliberadamente.
Delega una pregunta de exploración de solo lectura con una salida clara: por ejemplo,
«identifica las pruebas existentes que definen el comportamiento de entrada no válida».
Proporciónale la referencia del documento de la funcionalidad y una superficie permitida.
El padre conserva la interpretación, el alcance y la integración final.

## 3. Crea el registro de la funcionalidad y la vía de recuperación

Para un alcance suficientemente importante, crea el documento de funcionalidad descrito
en **Feature tracking**. Registra la solicitud aceptada, los criterios de aceptación
medibles, las tareas, las decisiones importantes, la evidencia y el siguiente paso.
Conserva los requisitos exactos en lugar de parafrasear restricciones hasta perderlas.
Guárdalo en el repositorio temporal donde la siguiente sesión pueda encontrarlo.

Guarda el hecho duradero para la recuperación mediante **Engram memory** cuando esté
disponible: qué es la funcionalidad, por qué el alcance elegido está acotado, dónde vive
su documento y qué sigue. La memoria es un espejo y una ayuda para recuperar, no el
único registro. Si la memoria no está disponible, el documento de funcionalidad aún debe
permitir que un sucesor continúe con honestidad. No guardes secretos, credenciales, datos
privados ni instrucciones sin procesar que no sean confiables como memoria.

## 4. Haz que la prueba falle por la razón correcta

Aplica **Test-first and verification**. Agrega la prueba más pequeña de nivel de
comportamiento que exprese el nuevo resultado observable. Ejecuta la prueba enfocada
antes de la implementación y registra el fallo observado. Un fallo causado por un error
tipográfico, una configuración de prueba ausente o el comando equivocado no es evidencia
RED útil; corrige el diseño de la prueba hasta que el fallo distinga el comportamiento
ausente de un entorno defectuoso.

Implementa el comportamiento mínimo que haga pasar la prueba enfocada. Ejecútala de
nuevo y registra el resultado aprobado observado. Luego triangula con un caso negativo,
de límite o alternativo que proteja el contrato. Refactoriza solo después de que las
verificaciones enfocadas sigan en verde. Las pruebas son evidencia, no decoración: el
documento de funcionalidad debe indicar qué se ejecutó y qué observó.

## 5. Delega para ahorrar sin ceder el liderazgo

Ahora toma una decisión de delegación acotada de **Model profiles**. Elige el modelo
configurado más económico adecuado para una unidad contenida, como mapear pruebas
existentes, redactar un caso de prueba para revisión o implementar una superficie de
archivo independiente claramente especificada. No le des al trabajador de bajo costo una
responsabilidad vaga por toda la funcionalidad.

Proporciona el localizador exacto del documento de funcionalidad, los criterios de
aceptación, las superficies de edición permitidas y el comando de verificación. Pide al
trabajador que devuelva evidencia observada, no una afirmación optimista. Revisa sus
cambios en la sesión padre. Si el trabajador expone una decisión de negocio faltante,
detente y devuelve esa decisión al registro de la funcionalidad, en lugar de permitir
que la política migre a un controller, model o view arbitrario.

## 6. Confirma alcances que un revisor pueda comprender

Usa **Commits and slices** para crear uno o más commits enfocados. Mantén el documento
de funcionalidad, la prueba y la implementación lo bastante conectados como para que el
commit explique el comportamiento que cambia. No mezcles formato, limpieza no relacionada
ni otra funcionalidad en el mismo alcance solo porque esos archivos están abiertos. Si el
alcance de revisión se vuelve demasiado grande, usa la disciplina de revisión encadenada
en lugar de ocultar la complejidad tras un mensaje de commit tranquilizador.

Antes de la siguiente fase, inspecciona el estado, el diff y el historial de commits del
repositorio temporal con sus herramientas de control de versiones disponibles. El tutor
del proyecto final verificará estos artefactos directamente; una descripción narrada no
prueba que exista un commit.

## 7. Revisa lo que realmente existe

Aplica **Permission modes** en todo momento: un modo reduce las solicitudes repetidas
dentro de su alcance, pero no elimina restricciones explícitas ni elecciones humanas
importantes. Usa **Native review** cuando se apliquen sus criterios de riesgo y flujo de
trabajo. Su propósito es revisar un candidato congelado con evidencia, no aprobar
formalmente el árbol de trabajo más reciente. Usa **Judgment day** solo cuando el cambio
requiera su disciplina de revisión ciega y adversarial.

Sin importar la ruta de revisión, inspecciona si la prueba demuestra el comportamiento
indicado, si el documento de funcionalidad coincide con el alcance final y si los commits
contienen solo el alcance prometido. Una respuesta limpia del agente no reemplaza estos
artefactos.

## Termina con un recorrido de artefactos

La entrega final registra el comportamiento y los límites aceptados, los resultados de
la prueba enfocada y de la verificación, un siguiente paso recuperable (reflejado en la
memoria cuando esté disponible) y commits enfocados con la evidencia de revisión que
corresponda. El agente tutor debe verificar esos artefactos en el repositorio temporal
antes de registrar la finalización. Eso convierte el proyecto final en un ejercicio de
entrega real en vez de una conversación sobre buenas prácticas.

## Errores comunes

- Iniciar la implementación antes de que se acepte un comportamiento observable y
  acotado.
- Tratar la salida de exploración como autorización para editar.
- Llamar a un fallo no relacionado una prueba RED exitosa.
- Delegar propiedad sin definir a un modelo más económico para ahorrar dinero.
- Guardar solo un resumen de memoria y no dejar ningún registro recuperable en el
  repositorio.
- Llamar completa a una funcionalidad sin revisar pruebas, commits y evidencia de
  revisión en el repositorio real.

## Pruébalo

Elige un comportamiento pequeño de un repositorio temporal, indica sus criterios de
aceptación y crea el documento de funcionalidad antes de editar. Realiza un alcance de
prueba primero hasta obtener un commit enfocado. Delega una tarea de apoyo acotada a un
modelo configurado más económico, luego inspecciona e integra su evidencia. Por último,
pide a tu agente tutor que verifique directamente el documento de funcionalidad, las
pruebas y los commits en el repositorio temporal. Cuando esos artefactos coincidan,
habrás practicado todo el sistema, desde la intención hasta una prueba revisable.

## Al terminar: quita el tutor del curso (opcional)

Si instalaste el paquete del tutor del curso, puedes quitarlo ahora. Tu progreso
sigue guardado en el servidor del curso con tu ID de estudiante.

```sh
gentle-shell remove git:github.com/iachettifederico/gentle-shell-school
```

En Pi sin Gentle Shell, usa `pi remove git:github.com/iachettifederico/gentle-shell-school`. Después reinicia; `/school` ya no
estará disponible.
