---
title: "Autorizar y explorar"
description: "Separá el permiso para investigar del permiso para cambiar un proyecto."
module: "Desarrollo Orgánico Impulsado"
---

# Autorizar y explorar

Antes de que un agente cambie un repositorio, dos preguntas necesitan respuestas
diferentes: **¿Puede cambiar algo?** y **¿Qué debe entender primero?** Combinarlas
es un modo de falla frecuente. Un agente puede confundir una solicitud de consejo
con permiso para editar, o puede empezar la implementación a partir de una lectura
superficial que no registra las restricciones reales del proyecto.

ODD responde la primera pregunta con autorización y la segunda con exploración
proporcional. Son pasos consecutivos porque el entendimiento debe preceder a una
escritura, pero protegen cosas distintas: el control humano y la corrección
técnica.

## Solo lectura es un modo operativo real

La investigación, explicación, revisión, comparación y las solicitudes de solo
propuesta son de solo lectura. El agente puede inspeccionar código y requisitos,
describir hallazgos y recomendar un camino. No debe crear artefactos de
implementación, enviar un writer ni aplicar cambios solo porque aprendió cómo
resolvería el problema.

El mismo límite se aplica a la investigación. La investigación puede reducir la
incertidumbre, pero sus hallazgos no autorizan alcance ni aceptación nuevos. Si
se necesita evidencia externa, el agente establece el problema, el resultado
deseado, las restricciones y la evidencia actual; usa fuentes autorizadas,
prefiere fuentes primarias y atribuye las afirmaciones relevantes. Su resultado
distingue los hechos verificados de las suposiciones, contradicciones,
preocupaciones sobre vigencia y vacíos. Una transferencia útil de investigación
también contiene una recomendación, ventajas y desventajas, preguntas abiertas e
implicaciones para la implementación.

Este límite es valioso incluso cuando un cambio solicitado parece obvio. Significa
que una propuesta puede examinarse con seguridad sin que el repositorio cambie
por debajo de la persona que la pidió.

## Cómo se ve la autorización

La autorización de implementación es permiso para mutar el proyecto dentro del
alcance de la solicitud. Cuando ese permiso es claro, ODD continúa con la
exploración. Cuando es ambiguo o condicional, el agente hace **una aclaración** y
espera. Esa pregunta debe estar enfocada: resuelve si se desea un cambio o decide
la única decisión de producto que vuelve imposible una implementación segura.

No conviertas cada preferencia en un interrogatorio. Si los requisitos existentes
y las convenciones del repositorio responden una pregunta, usá esa evidencia.
Preguntá solo cuando queda una decisión real sin resolver. Del mismo modo, una
formulación cautelosa como “puede que revise los commits más tarde” no le ordena
al agente detenerse; pide notas reanudables y commits separados mientras el
trabajo autorizado continúa. Solo una solicitud explícita de esperar es una
instrucción para detenerse.

Una aclaración bien formulada ofrece una elección cerrada y significativa. “¿Qué
querés?” es amplia y obliga a quien solicita a diseñar la solución. “¿Este campo
nuevo debería ser opcional u obligatorio para los registros existentes?” identifica
la consecuencia real y permite que el dueño decida.

## Explorá antes de la primera escritura

La exploración primero lee el código y los requisitos existentes. “Proporcional”
es la expresión clave. Una edición acotada y conocida podría necesitar solo el
archivo objetivo y su prueba. Un comportamiento transversal podría necesitar la
interfaz pública, la implementación existente, las pruebas relacionadas, la
configuración y las instrucciones del proyecto. El objetivo no es leer el
repositorio; es establecer la evidencia necesaria para la próxima acción segura.

El orquestador usa un presupuesto de evidencia para mantener esto eficiente.
Cuando el entendimiento cabe en un lote de lectura acotado, puede trabajar en
línea. Cuando necesita más que eso —o más de aproximadamente cinco consultas
secuenciales— un explorador de solo lectura puede mapear el área relevante y
devolver evidencia concisa de `path:line`. Este disparador trata sobre el
entendimiento faltante, no es una excusa para delegar una pequeña pregunta
puntual. La lectura que prepara una escritura delegada le corresponde al writer;
una escritura en línea lee en línea.

La exploración también debería validar premisas importantes. Si el fracaso de una
suposición invalidaría el enfoque, comprobala antes de construir. Reutilizá los
hallazgos confiables de trabajo paralelo en vez de releerlos, y luego verificá
solo lo que esté desactualizado o sea materialmente distinto.

## Resolvé la incertidumbre sin fabricarla

Después de explorar, distinguí un hecho faltante de una decisión abierta. Un
hecho faltante puede responderse leyendo un archivo de configuración o una fuente
primaria autorizada. Una decisión de producto abierta —como una elección de
comportamientos incompatibles— le corresponde al dueño humano. Hacé una pregunta
enfocada y luego esperá.

Para una premisa de alta consecuencia pero no probada, ODD permite como máximo un
cuestionamiento independiente, acotado y de solo lectura. Nombrá la premisa, la
evidencia que la respalda y la consecuencia si es incorrecta. Esto no es una
invitación a debatir fallas deterministas de pruebas: las fallas necesitan un
arreglo. Es una forma de evitar construir sobre una suposición sin examinar cuando
el costo de equivocarse es inusualmente alto.

La evidencia no disponible pausa solo la decisión insegura que depende de ella.
No debe bloquear el trabajo seguro no relacionado ni llevar a inventar hechos.

## Un ejemplo de exploración

Supongamos que la solicitud es: “Hacé que la exportación incluya al propietario
del proyecto”. Primero preguntá si esto autoriza la implementación; si la
respuesta es sí, inspeccioná el punto de entrada de la exportación, el objeto que
provee los datos del proyecto, las pruebas de exportación existentes y cualquier
contrato de formato declarado. Podrías descubrir que hay dos formatos de
exportación y que no se especifica la representación requerida del campo de
propietario. Esa es una decisión de producto real. Hacé una pregunta sobre la
representación en vez de adivinar.

Si en cambio la solicitud dice “Explicá dónde se ensamblan las exportaciones”,
detenete después de la exploración de solo lectura e informá la evidencia. Ni un
plan de implementación perfecto autorizaría una escritura.

## Errores comunes

- **Editar mientras “solo mirás”.** Una limpieza útil sigue siendo una mutación.
- **Hacer preguntas que el código ya responde.** Leé primero.
- **Hacer varias preguntas a la vez.** Resolvé la decisión que bloquea la
  próxima acción y después continuá.
- **Explorar de más un cambio acotado.** La evidencia debe coincidir con la
  consecuencia, no con una lista de verificación fija.
- **Tratar un resultado de investigación como aprobación.** Los hallazgos
  informan a un dueño; no amplían el alcance.

## Probalo

Tomá una solicitud actual y escribí dos oraciones: una que indique si otorga
autorización de implementación y otra que nombre la evidencia mínima que
necesitás antes de una primera escritura. Si realmente queda una decisión,
formulá una pregunta enfocada que explique qué cambia entre los resultados
disponibles. Si no queda ninguna decisión, no inventes una: seguí con la
clasificación en **Tamaño de tarea y riesgo**.
