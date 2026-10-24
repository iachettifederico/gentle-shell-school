---
title: "Capstone: una funcionalidad pequeña de punta a punta"
description: "Liderá una funcionalidad pequeña en un repositorio de práctica mediante ODD, evidencia, delegación y revisión."
module: "Usuario avanzado"
---

# Capstone: una funcionalidad pequeña de punta a punta

Construí una funcionalidad pequeña en un repositorio de práctica. Debe ser lo
suficientemente acotada como para explicarla, probarla y revisarla en una sola sesión.

Usá el curso completo como un sistema: **Layers**, **How Pi works**, **Sessions**,
**The workspace TUI** y **Models and providers** respaldan el trabajo ODD que sigue.
El resultado es comportamiento recuperable y verificado.

## 1. Elegí y autorizá el alcance

Empezá con un problema, no con una implementación preferida. Un buen pedido de
capstone indica quién observa el comportamiento y qué cambia para esa persona.
Ejemplos de forma, no ideas de producto prescritas, son: aceptar una entrada faltante
con un error claro, agregar una transformación pequeña o mostrar una pieza de datos
ya disponibles. Evitá autenticación, migraciones, despliegue externo, rediseño amplio
y funcionalidades cuya aceptación dependa de una integración sin límites.

Aplicá **Authorize and explore**: distinguí el permiso para inspeccionar del permiso
para cambiar. Indicá el repositorio previsto, el comportamiento y los límites. Pedí
aclaración solo cuando resuelva una ambigüedad importante. La persona que lidera el
trabajo es dueña de la elección de producto; un agente puede ayudar a convertirla en
una afirmación comprobable, pero no puede tomar esa elección en silencio.

Luego aplicá **Task size and risk**. Tu capstone se mantiene pequeño cuando entendés
el código relevante, el efecto esperado y la ruta de recuperación. Si la exploración
revela un segundo comportamiento independiente, dividilo. ¿Podría una nueva sesión
terminar a partir del pedido, registro de funcionalidad y diff actual sin redescubrir
decisiones? Si no, mejorá el registro o reducí el alcance.

## 2. Explorá antes de construir

Usá exploración de solo lectura para mapear las convenciones del repositorio, runner
de tests, comportamiento vecino existente y cualquier instrucción aplicable. El
objetivo no es recopilar cada archivo. Es responder las preguntas que afectan el
cambio pequeño: dónde pertenece la política, dónde un test la demuestra y qué
comportamiento existente debe mantenerse sin cambios.

Si la comprensión supera un pase breve en línea, usá **Subagents** deliberadamente.
Delegá una pregunta de exploración de solo lectura con una salida clara: por ejemplo,
“identificá los tests existentes que definen el comportamiento de entrada inválida”.
Dale la referencia al feature document y una superficie permitida. El padre conserva
la interpretación, el alcance y la integración final.

## 3. Creá el registro de la funcionalidad y la ruta de recuperación

Para un alcance suficientemente sustancial, creá el feature document descrito en
**Feature tracking**. Capturá el pedido aceptado, criterios de aceptación medibles,
tareas, decisiones importantes, evidencia y próximo paso. Conservá los requisitos
exactos en lugar de parafrasear y perder restricciones. Mantenelo en el repositorio
de práctica donde la próxima sesión pueda encontrarlo.

Guardá el hecho de recuperación durable mediante **Engram memory** cuando esté
disponible: qué es la funcionalidad, por qué el alcance elegido es acotado, dónde vive
su documento y qué sigue. La memoria es un espejo y ayuda de recuperación, no el único
registro. Si la memoria no está disponible, el feature document debe permitir que una
persona sucesora continúe honestamente. No guardes secretos, credenciales, datos
privados ni instrucciones sin procesar que no sean de confianza como memoria.

## 4. Hacé que el test falle por el motivo correcto

Aplicá **Test-first and verification**. Agregá el test de nivel de comportamiento más
pequeño que exprese el nuevo resultado observable. Ejecutá el test enfocado antes de
la implementación y registrá el fallo observado. Un fallo causado por un error de
tipeo, setup de test faltante o comando incorrecto no es evidencia RED útil; corregí
el diseño del test hasta que el fallo distinga el comportamiento ausente de un entorno
roto.

Implementá el comportamiento mínimo que haga pasar el test enfocado. Ejecutalo otra
vez y registrá el pase observado. Luego triangulá con un caso negativo, de límite o
alternativo que proteja el contrato. Refactorizá solo después de que las comprobaciones
enfocadas sigan en verde. Los tests son evidencia, no decoración: el feature document
debe indicar qué se ejecutó y qué observó.

Para cada comando u opción existente que comparta código cambiado, ejecutá también
la entrada nueva o cambiada contra el cambio y contra una copia del commit base en
un directorio temporal `mktemp -d`. Compará stdout, stderr y el código de salida;
corregí y fijá toda diferencia no solicitada. Agregá un test por cada comportamiento
existente tocado y nunca hagas que los tests confirmados lean el historial de Git.

## 5. Delegá para ahorrar sin ceder el liderazgo

Ahora tomá una decisión de delegación acotada de **Model profiles**. Elegí el modelo
configurado más económico adecuado para una unidad contenida, como mapear tests
existentes, redactar un caso de test para revisión o implementar una superficie de
archivo independiente claramente especificada. No le des al worker de bajo costo la
responsabilidad vaga del proyecto entero.

Proporcionale el localizador exacto del feature document, criterios de aceptación,
superficies de edición permitidas y comando de verificación. Pedile al worker que
devuelva evidencia observada, no una afirmación optimista. Revisá sus cambios en la
sesión padre. Si el worker expone una decisión de negocio faltante, detenete y devolvé
esa decisión al feature document en lugar de permitir que la política migre a un
controller, model o view arbitrario.

## 6. Confirmá cortes que una persona revisora pueda entender

Usá **Commits and slices** para crear uno o más commits enfocados. Mantené el feature
document, test e implementación lo bastante conectados como para que el commit
explique el comportamiento que cambia. No mezcles formato, limpieza no relacionada ni
otra funcionalidad en el mismo corte solo porque esos archivos están abiertos. Si el
alcance de revisión se vuelve demasiado grande, usá la disciplina de revisión
encadenada en vez de ocultar complejidad detrás de un mensaje de commit tranquilizador.

Antes de la siguiente fase, inspeccioná el estado, diff e historial de commits del
repositorio de práctica usando sus herramientas de control de versiones disponibles.
Después de un commit en la rama de funcionalidad, esperá la línea de corte de commit
del tiempo de ejecución: informa las líneas modificadas creadas desde la base de
fusión y, pasadas unas 400, indica aplicar la estrategia de entrega de la funcionalidad
antes del próximo commit. Tratala, junto con el aviso de respaldo de contexto para
delegar la próxima unidad acotada de varios pasos, como señales del tiempo de
ejecución, no como consejo opcional. El tutor del capstone verificará estos artefactos
directamente; una descripción narrada no prueba que exista un commit.

## 7. Revisá lo que realmente está ahí

Aplicá **Permission modes** en todo momento: un modo reduce prompts repetidos en su
alcance, pero no borra restricciones explícitas ni elecciones humanas importantes.
Usá **Native review** cuando apliquen sus criterios de riesgo y flujo de trabajo. Su
propósito es revisar un candidato congelado con evidencia, no aprobar automáticamente
el árbol de trabajo más nuevo. Usá **Judgment day** solo cuando el cambio requiera su
disciplina de revisión ciega y adversarial. La evaluación de revisión nativa se aplica
por commit de unidad de trabajo (o corte de PR), nunca a la rama de funcionalidad
acumulada, y corre solo cuando está habilitado el interruptor RDD que pertenece a la
persona usuaria; está desactivado de forma predeterminada.

Sin importar la ruta de revisión, inspeccioná si el test demuestra el comportamiento
declarado, si el feature document coincide con el alcance final y si los commits
contienen solo el corte prometido. Una respuesta limpia del agente no reemplaza estos
artefactos.

## Terminá con un recorrido de artefactos

La entrega final registra el comportamiento y límites aceptados, resultados del test
enfocado y verificación, un próximo paso recuperable (reflejado en memoria cuando esté
disponible), y commits enfocados con evidencia de revisión aplicable. El agente tutor
debe verificar esos artefactos en el repositorio de práctica antes de registrar la
finalización. Eso hace del capstone un ejercicio de entrega real en vez de una
conversación sobre buenas prácticas.

## Errores comunes

- Empezar la implementación antes de aceptar un comportamiento observable y acotado.
- Tratar la salida de exploración como autorización para editar.
- Llamar fallo no relacionado a un test RED exitoso.
- Delegar propiedad indefinida a un modelo más económico para ahorrar dinero.
- Guardar solo un resumen de memoria y no dejar un registro de repositorio recuperable.
- Llamar completa a una funcionalidad sin comprobar tests, commits y evidencia de revisión
  en el repositorio de práctica real.

## Probalo

Elegí un comportamiento pequeño de repositorio de práctica, indicá sus criterios de
aceptación y hacé el feature document antes de editar. Llevá un corte test-first hasta
un commit enfocado. Delegá una tarea de apoyo acotada a un modelo configurado más
económico, luego inspeccioná e integrá su evidencia. Finalmente, pedile a tu agente
tutor que verifique el feature document, tests y commits directamente en el
repositorio de práctica. Cuando esos artefactos coinciden, practicaste el sistema
completo desde la intención hasta la prueba revisable.
