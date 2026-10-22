---
title: "Autoriza y explora"
description: "Separa el permiso para investigar del permiso para cambiar un proyecto."
module: "Desarrollo Impulsado Orgánicamente"
---

# Autoriza y explora

Antes de que un agente cambie un repositorio, dos preguntas necesitan respuestas diferentes:
**¿Puede cambiar algo?** y **¿Qué debe comprender primero?** Combinarlas es un modo de fallo
común. Un agente puede confundir una solicitud de consejo con permiso para editar, o puede
comenzar la implementación tras una lectura superficial que no detecta las restricciones reales
del proyecto.

ODD responde la primera pregunta con autorización y la segunda con exploración proporcionada.
Son pasos consecutivos porque la comprensión debe preceder a una escritura, pero protegen cosas
diferentes: el control humano y la corrección técnica.

## El modo de solo lectura es un modo operativo real

La investigación, la explicación, la revisión, la comparación y las solicitudes de solo
propuesta son de solo lectura. El agente puede inspeccionar código y requisitos, describir
hallazgos y recomendar un camino. No debe crear artefactos de implementación, enviar un
trabajador escritor ni aplicar cambios solo porque ha aprendido cómo resolvería el problema.

El mismo límite se aplica a la investigación. La investigación puede reducir la incertidumbre,
pero sus hallazgos no autorizan un nuevo alcance ni aceptación. Si se necesita evidencia
externa, el agente establece el problema, el resultado deseado, las restricciones y la evidencia
actual; usa fuentes autorizadas, prefiere las fuentes primarias y atribuye las afirmaciones
relevantes. Su resultado distingue los hechos verificados de las suposiciones, contradicciones,
preocupaciones de vigencia y vacíos. Un traspaso de investigación útil también contiene una
recomendación, concesiones, preguntas abiertas e implicaciones de implementación.

Este límite es valioso incluso cuando un cambio solicitado parece obvio. Significa que una
propuesta puede examinarse de forma segura sin que el repositorio cambie por debajo de la persona
que la solicitó.

## Cómo se ve la autorización

La autorización de implementación es permiso para modificar el proyecto dentro del alcance de
la solicitud. Cuando ese permiso es claro, ODD procede a la exploración. Cuando es ambiguo o
condicional, el agente hace **una aclaración** y espera. Esa pregunta debe estar enfocada:
resuelve si se desea el cambio o determina la decisión de producto que hace imposible una
implementación segura.

No conviertas cada preferencia en un interrogatorio. Si los requisitos existentes y las
convenciones del repositorio responden una pregunta, usa esa evidencia. Pregunta solo cuando
quede una decisión real sin resolver. Del mismo modo, una redacción dubitativa como “puedo
revisar commits más tarde” no le ordena al agente detenerse; solicita notas que permitan
reanudar y commits separados mientras el trabajo autorizado continúa. Solo una solicitud
explícita de esperar es una instrucción de detención.

Una aclaración bien formulada ofrece una elección cerrada y significativa. “¿Qué quieres?” es
amplia y obliga a quien solicita a diseñar la solución. “¿Este nuevo campo debería ser opcional
o requerido para los registros existentes?” identifica la consecuencia real y permite que la
persona responsable decida.

## Explora antes de la primera escritura

La exploración lee primero el código y los requisitos existentes. “Proporcionadamente” es la
palabra clave. Una edición acotada y conocida podría necesitar solo el archivo objetivo y su
prueba. Un comportamiento transversal puede necesitar la interfaz pública, la implementación
existente, las pruebas relacionadas, la configuración y las instrucciones del proyecto. El
objetivo no es leer el repositorio; es establecer la evidencia necesaria para la siguiente acción
segura.

La persona que orquesta usa un presupuesto de evidencia para mantener esto eficiente. Cuando la
comprensión cabe en un lote de lectura acotado, puede trabajar en línea. Cuando necesita más que
eso—o más de aproximadamente cinco consultas secuenciales—un explorador de solo lectura puede
mapear el área relevante y devolver evidencia concisa de `path:line`. Este disparador se trata de
comprensión faltante, no de una excusa para delegar una pregunta pequeña y específica. La lectura
que prepara una escritura delegada corresponde a quien escribe; una escritura en línea lee en
línea.

La exploración también debe validar premisas importantes. Si el fallo de una suposición
invalidaría el enfoque, compruébala antes de construir. Reutiliza hallazgos confiables del trabajo
de otros en paralelo en vez de volver a leerlos, y luego verifica solo lo que esté desactualizado
o sea materialmente diferente.

## Resuelve la incertidumbre sin fabricarla

Después de explorar, distingue entre un hecho faltante y una decisión abierta. Un hecho faltante
podría responderse leyendo un archivo de configuración o una fuente primaria autorizada. Una
decisión abierta de producto—como una elección de comportamiento incompatible—corresponde a la
persona responsable. Haz una pregunta enfocada y luego espera.

Para una premisa de altas consecuencias pero no comprobada, ODD permite como máximo un desafío
acotado, independiente y de solo lectura. Nombra la premisa, la evidencia que la respalda y la
consecuencia si está equivocada. Esto no es una invitación a debatir fallas deterministas de las
pruebas: las fallas necesitan una corrección. Es una forma de evitar construir sobre una
suposición sin examinar cuando el costo de equivocarse es inusualmente alto.

La evidencia no disponible pausa solo la decisión insegura dependiente. No debe bloquear trabajo
seguro no relacionado ni conducir a hechos inventados.

## Un ejemplo de exploración

Supón que la solicitud es: “Haz que la exportación incluya a la persona propietaria del proyecto”.
Primero pregunta si esto autoriza la implementación; si la respuesta es sí, inspecciona el punto
de entrada de la exportación, el objeto que proporciona los datos del proyecto, las pruebas de
exportación existentes y cualquier contrato de formato indicado. Podrías descubrir que hay dos
formatos de exportación y que la representación requerida del campo de la persona propietaria no
está especificada. Esa es una decisión real de producto. Haz una pregunta sobre la representación
en lugar de adivinar.

Si la solicitud dice en cambio “Explica dónde se ensamblan las exportaciones”, detente después de
la exploración de solo lectura e informa la evidencia. Incluso un plan de implementación perfecto
no autorizaría una escritura.

## Errores comunes

- **Editar mientras “solo miras”.** Una limpieza útil sigue siendo una modificación.
- **Hacer preguntas que el código ya responde.** Lee primero.
- **Hacer varias preguntas a la vez.** Resuelve la decisión que bloquea la siguiente acción y
  luego continúa.
- **Explorar de más un cambio acotado.** La evidencia debe corresponder a la consecuencia, no a
  una lista de verificación fija.
- **Tratar un resultado de investigación como aprobación.** Los hallazgos informan a una persona
  responsable; no expanden el alcance.

## Pruébalo

Toma una solicitud actual y escribe dos oraciones: una que indique si concede autorización para
implementar y otra que nombre la evidencia mínima que necesitas antes de una primera escritura.
Si realmente queda una decisión, formula una pregunta enfocada que explique qué cambia entre los
resultados disponibles. Si no queda ninguna decisión, no inventes una: pasa a la clasificación en
**Tamaño de la tarea y riesgo**.
