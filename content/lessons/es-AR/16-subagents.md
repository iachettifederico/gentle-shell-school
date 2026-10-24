---
title: "Subagentes enfocados"
description: "Delegá trabajo acotado sin ceder la responsabilidad por el resultado."
module: "Delegación"
---

# Subagentes enfocados

Un subagente es útil cuando hace que la sesión padre sea *más confiable*, no cuando
simplemente genera más actividad. Gentle Shell llama agentes enfocados a este
arreglo: una sesión padre conserva la responsabilidad mientras especialistas
exploran, implementan o verifican una parte acotada del trabajo. El padre es dueño
del alcance, las decisiones humanas, la disposición de revisión y el informe final.
Un hijo devuelve evidencia y no puede convertir su propia salida en permiso para
entregar.

Esa división resuelve dos problemas habituales. Primero, una base de código amplia
y desconocida puede consumir el contexto del padre antes de que la implementación
siquiera empiece. Segundo, partes separadas de trabajo genuinamente independiente
pueden tardar más cuando se completan en serie. La delegación le da a cada ayudante
un contexto fresco y acotado, y una vía de regreso a la sesión que todavía conoce
la intención de la persona usuaria. No es la opción predeterminada para cada pedido
con varios archivos: coordinar tiene costo de preparación y puede ocultar
dependencias.

## Tres roles, tres clases de evidencia

Los roles empaquetados ilustran el límite:

- El **explorador** es de solo lectura. Mapea archivos, símbolos, relaciones,
  evidencia observada e incertidumbre relevantes. No edita, ejecuta comandos,
  confirma ni corrige hallazgos. La única excepción explícita: puede inicializar
  un índice CodeGraph acotado al cwd, que puede crear `.codegraph/`. Su trabajo es
  reducir una investigación a una entrega que el padre pueda usar para elegir una
  ruta.
- El **worker** es quien escribe una implementación con alcance definido. Lee el
  contexto de la tarea, cambia solo las superficies autorizadas, ejecuta únicamente
  las comprobaciones autorizadas por el padre e informa lo que observó. No delega,
  confirma, hace push ni es dueño de la revisión nativa.
- El **verificador** es de solo lectura e independiente del writer. Inspecciona la
  evidencia relevante y ejecuta únicamente comprobaciones autorizadas de forma
  explícita. Informa resultados y brechas; no las repara.

Existen otros agentes empaquetados para flujos de revisión especializados, pero eso
no los convierte en reemplazos genéricos de estos roles. Elegí el rol cuya salida
realmente necesitás. Pedirle a un explorador que implemente derrota su límite de
evidencia de solo lectura; pedirle a un worker que tome la decisión final de entrega
derrota la responsabilidad del padre.

## Decidí si delegar

El padre delega por una razón concreta, no por cantidad de archivos ni por una
comparación de precios de modelos. El trabajo puede quedarse en línea cuando es
pequeño y se entiende: leé los archivos relevantes, hacé un cambio coherente,
ejecutá sus comprobaciones enfocadas e informá.

La exploración se justifica cuando el entendimiento no entra en el presupuesto de
evidencia del padre: más de un lote paralelo de aproximadamente tres llamadas y
unos 10.000 tokens, o más de unas cinco consultas secuenciales. El explorador
debería devolver evidencia de ruta y línea en una entrega breve. No uses un
explorador para una pregunta pequeña y dirigida, ni le hagas releer material que el
padre ya necesita para una edición en línea.

Un writer se justifica únicamente para una unidad acotada con una razón nombrada.
Una razón es el paralelismo: dos o más unidades de comportamiento independientes,
cada una lo bastante sustancial para compensar la preparación, con superficies de
edición disjuntas. Otra es el respaldo de contexto del tiempo de ejecución durante
una sesión larga. Una tarea grande por sí sola no alcanza. Si las unidades dependen
entre sí, o son pequeñas, hacelas en línea y en secuencia. Cuando un ítem
independiente de alto riesgo requiere verificación separada, el verificador es una
mirada externa adicional después de las propias comprobaciones del writer, no un
sustituto de ellas.

### Señales de orquestación del tiempo de ejecución

Gentle Shell también impone algunas reglas de orquestación. El respaldo de contexto
padre es `min(150k tokens, 0.15 × context window)`; cuando el contexto medido lo
alcanza, un único aviso le indica al padre delegar la próxima unidad acotada de
varios pasos. Las ediciones pequeñas y únicas siguen en línea, y los subagentes
nunca reciben este aviso. Los lanzamientos de verificadores pasan una comprobación
de admisión: el verificador corre para un ítem de alto riesgo nombrado, una tarea
de un documento de funcionalidad o una sesión padre que alcanzó el respaldo; si no,
la sesión padre verifica en línea. El progreso de TODO surge de los conteos de tareas, cada subagente recibe
su propio `TMPDIR` y una guarda analiza los tests entregados.

## Hacé ejecutable la entrega

Una entrega útil es un contrato compacto, no un ensayo. Para trabajo registrado,
remití al hijo al documento de funcionalidad y decile que lea desde la sección
`## Specs` hasta `## Log`; no parafrasees requisitos exactos. Nombrá su rol, tarea,
criterios de aceptación, evidencia previa relevante y los comandos exactos que
puede ejecutar. Los artefactos técnicos y las instrucciones dirigidas a subagentes
se redactan en inglés de manera predeterminada.

Sobre todo, dale a un writer **superficies de edición permitidas** exactas: rutas
relativas al repositorio o globs acotados, incluidos los directorios de archivos
nuevos que pueda usar. El padre debe derivarlas antes de iniciarlo. Un writer no
cambia nada fuera de esas superficies, y los writers paralelos necesitan superficies
disjuntas (o worktrees aislados). Este es un mecanismo práctico de concurrencia:
convierte una edición superpuesta en un error de planificación, en lugar de una
sorpresa descubierta al fusionar.

Por ejemplo, un padre podría delegar una unidad de documentación así:

```text
Spec: odd/tasks/search.md (read until "## Log"). Do T2; S1.
Role: worker.
Allowed edit surfaces:
- docs/search.md
- spec/docs/search_spec.rb
Verification:
- bin/rspec spec/docs/search_spec.rb
```

El ejemplo nombra deliberadamente tanto el comportamiento como su prueba. No
transfiere responsabilidad por las decisiones de producto ni permiso para ampliar
el alcance.

## Observá y después integrá

Gentle Agents le da al padre una vista en vivo del trabajo de subagentes. Abrí
`/gentle:agents` para ver los subagentes activos de esta sesión; la vista también
puede enumerar orquestadores abiertos en el perfil. Un hijo completado devuelve una
entrega estructurada. Tratala como evidencia para inspeccionar, no como una
instrucción en la que confiar ciegamente. El padre reconcilia resultados
independientes, ejecuta las comprobaciones requeridas e informa qué ocurrió.

Un error frecuente es “delegar porque esto parece grande”. Eso crea prompts, espera
e interpretación de entregas sin mejorar la decisión. Otro es dividir un único
comportamiento entre quien escribe la prueba, quien escribe código y quien escribe
documentación. Esas partes comparten un contrato y deberían avanzar juntas. Un
tercero es una superficie vaga como todo el repositorio: elimina el límite que hace
seguro el trabajo paralelo.

## Probalo

Abrí `/gentle:agents`. Después tomá una tarea reciente y escribí una nota de
asignación de tres líneas: si se quedaría en línea o usaría un
explorador/worker/verificador, la razón específica y la salida exacta que exigirías
de ese rol. Si usarías un worker, enumerá el conjunto más pequeño de rutas que puede
cambiar. Ese ejercicio es la habilidad: elegí una topología que preserve una vía de
regreso clara hacia vos.
