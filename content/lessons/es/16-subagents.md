---
title: "Subagentes enfocados"
description: "Delega trabajo delimitado sin renunciar a la responsabilidad por el resultado."
module: "Delegación"
---

# Subagentes enfocados

Un subagente es útil cuando hace que la sesión principal sea *más confiable*, no cuando
simplemente genera más actividad. Gentle Shell llama agentes enfocados a esta disposición: una
sesión principal conserva la responsabilidad mientras especialistas exploran, implementan o
verifican una parte delimitada del trabajo. La sesión principal es responsable del alcance, las
decisiones humanas, la resolución de la revisión y el informe final. Un agente hijo devuelve
evidencia y no puede convertir su propia salida en permiso para entregar el trabajo.

Esa división resuelve dos problemas comunes. Primero, una base de código amplia y desconocida
puede consumir el contexto de la sesión principal incluso antes de que comience la implementación.
Segundo, partes separadas de trabajo realmente independiente pueden tomar más tiempo si se
completan en serie. La delegación le da a cada ayudante un contexto nuevo y limitado, y una vía de
retorno a la sesión que todavía conoce la intención del usuario. No es la opción predeterminada para
cada solicitud de varios archivos: la coordinación tiene un costo de preparación y puede ocultar
dependencias.

## Tres roles, tres tipos de evidencia

Los roles incluidos ilustran el límite:

- El **explorador** es de solo lectura. Mapea archivos, símbolos, relaciones,
  evidencia observada e incertidumbre relevantes. No edita, ejecuta comandos, confirma cambios
  ni corrige hallazgos. La única excepción explícita: puede inicializar un índice de CodeGraph
  con alcance de cwd, lo que puede crear `.codegraph/`. Su trabajo es reducir una investigación a una entrega que la
  sesión principal pueda usar para elegir una ruta.
- El **trabajador** es un autor de implementación con alcance delimitado. Lee el contexto de la tarea,
  cambia solo las superficies autorizadas, ejecuta únicamente las verificaciones autorizadas por la sesión principal e
  informa lo que observó. No delega, confirma cambios, hace push ni es responsable de la revisión nativa.
- El **verificador** es de solo lectura e independiente del autor. Inspecciona la
  evidencia relevante y ejecuta únicamente verificaciones explícitamente autorizadas. Informa
  resultados y vacíos; no los repara.

Existen otros agentes incluidos para flujos de revisión especializados, pero eso no los
convierte en reemplazos genéricos de estos roles. Elige el rol cuya salida realmente
necesitas. Pedirle a un explorador que implemente vulnera su límite de evidencia de solo lectura;
pedirle a un trabajador que tome la decisión final de entrega vulnera la responsabilidad de la
sesión principal.

## Decide si delegar

La sesión principal delega por una razón identificada, no por la cantidad de archivos ni por una
comparación de precios de modelos. El trabajo puede permanecer en línea cuando es pequeño y se
entiende: lee los archivos relevantes, realiza un cambio coherente, ejecuta sus verificaciones
enfocadas e informa.

La exploración está justificada cuando la comprensión no cabe en el presupuesto de evidencia de la
sesión principal: más de un lote paralelo de aproximadamente tres llamadas y unos 10,000 tokens, o
más de aproximadamente cinco consultas secuenciales. El explorador debe devolver evidencia de
ruta y línea en una entrega breve. No uses un explorador para una pregunta pequeña y específica, y
no le hagas releer material que la sesión principal ya necesita para una edición en línea.

Un trabajador está justificado solo para una unidad delimitada con una razón identificada. Una razón
es el paralelismo: dos o más unidades de comportamiento independientes, cada una lo suficientemente
sustancial como para compensar la preparación, con superficies de edición disjuntas. Otra es el
respaldo de contexto del tiempo de ejecución durante una sesión larga. Una tarea grande por sí sola
no es suficiente. Si las unidades dependen entre sí, o si son pequeñas, hazlas en línea y en
secuencia. Cuando un elemento independiente de alto riesgo requiere verificación separada, el
verificador aporta una vista externa adicional después de las propias verificaciones del trabajador,
no un sustituto de ellas.

### Señales de orquestación del tiempo de ejecución

Gentle Shell también impone algunas reglas de orquestación. El respaldo de contexto
padre es `min(150k tokens, 0.15 × context window)`; cuando el contexto medido lo
alcanza, un único aviso indica al padre que delegue la siguiente unidad delimitada
de varios pasos. Las ediciones pequeñas y únicas siguen en línea, y los subagentes
nunca reciben este aviso. Los lanzamientos de verificadores pasan una comprobación
de admisión: el verificador se ejecuta para un elemento de alto riesgo nombrado, una
tarea de un documento de funcionalidad o una sesión padre que alcanzó el respaldo; si no,
la sesión padre verifica en línea. El progreso de TODO se obtiene de los conteos de tareas, cada
subagente recibe su propio `TMPDIR` y una protección analiza las pruebas entregadas.

## Haz que la entrega sea ejecutable

Una entrega útil es un contrato compacto, no un ensayo. Para trabajo con seguimiento, indica al
agente hijo el documento de funcionalidad y dile que lea la sección `## Specs` hasta
`## Log`; no parafrasees requisitos exactos. Nombra su rol, tarea, criterios de aceptación,
evidencia previa relevante y los comandos exactos que puede ejecutar. Los artefactos técnicos y las
instrucciones dirigidas a subagentes se usan en inglés de forma predeterminada.

Lo más importante es dar a un trabajador **superficies de edición permitidas** exactas: rutas
relativas al repositorio o globs delimitados, incluidos los directorios de archivos nuevos que puede
usar. La sesión principal debe derivarlas antes del inicio. Un trabajador no cambia nada fuera de
esas superficies, y los trabajadores paralelos necesitan superficies disjuntas (o worktrees
aislados). Este es un mecanismo práctico de concurrencia: convierte una edición superpuesta en un
error de planificación en vez de una sorpresa descubierta en una fusión.

Por ejemplo, una sesión principal podría delegar una unidad de documentación así:

```text
Spec: odd/tasks/search.md (read until "## Log"). Do T2; S1.
Role: worker.
Allowed edit surfaces:
- docs/search.md
- spec/docs/search_spec.rb
Verification:
- bin/rspec spec/docs/search_spec.rb
```

El ejemplo nombra deliberadamente tanto el comportamiento como su prueba. No transfiere la
responsabilidad de las decisiones de producto ni el permiso para ampliar el alcance.

## Observa y luego integra

Gentle Agents le da a la sesión principal una vista en vivo del trabajo de los subagentes. Abre
`/gentle:agents` para ver los subagentes activos de esta sesión; la vista también puede mostrar
orquestadores abiertos en el perfil. Un agente hijo completado devuelve una entrega estructurada.
Trátala como evidencia para inspeccionar, no como una instrucción en la que confiar ciegamente. La
sesión principal reconcilia resultados independientes, ejecuta las verificaciones requeridas e
informa lo que ocurrió.

Un error común es “delegar porque esto parece grande”. Eso genera prompts, espera e interpretación
de entregas sin mejorar la decisión. Otro es dividir un solo comportamiento entre un autor de
pruebas, un autor de código y un autor de documentación. Esas partes comparten un contrato y deben
avanzar juntas. Un tercero es una superficie vaga como todo el repositorio: elimina el límite que
hace seguro el trabajo paralelo.

## Pruébalo

Abre `/gentle:agents`. Luego toma una tarea reciente y escribe una nota de enrutamiento de tres
líneas: si se mantendría en línea o usaría un explorador/trabajador/verificador, la razón específica
y la salida exacta que requerirías de ese rol. Si usarías un trabajador, enumera el conjunto más
pequeño de rutas que puede cambiar. Ese ejercicio es la habilidad: elige una topología que conserve
una vía de retorno clara hacia ti.
