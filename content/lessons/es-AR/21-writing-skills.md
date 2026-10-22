---
title: "Escribir skills"
description: "Creá contratos de instrucciones reutilizables y concisos para LLM que hagan más seguro y claro el trabajo recurrente."
module: "Memoria y habilidades"
---

# Escribir skills

Una buena skill cambia lo que un agente hace de manera confiable en una
situación recurrente. No es un artículo sobre un tema ni un lugar para reunir
todas las preferencias del equipo. Es un **contrato de instrucciones de tiempo
de ejecución** compacto: le indica a un agente futuro cuándo activarse, qué
restricciones no puede relajar, cómo elegir entre casos, cómo ejecutar y qué
evidencia devolver. Este enfoque es lo que hace que una skill sea más útil que
un prompt largo pegado en cada sesión.

Antes de escribir una, probá si el problema realmente es reutilizable. Creá o
actualizá una skill cuando un flujo de trabajo o una convención se repite entre
sesiones, las restricciones locales difieren de la práctica genérica, un árbol
de decisión vuelve más segura una elección, o las plantillas, los esquemas y
las referencias mejorarían la repetibilidad. **No** crees una skill para una
tarea única, documentación genérica o reglas que deberían hacerse cumplir con
código ejecutable, pruebas o un linter. Esas alternativas ofrecen garantías más
fuertes que las instrucciones de un modelo.

Este límite también protege el contexto. Una skill que simplemente repite un
README agrega otro lugar donde las instrucciones pueden desfasarse. En cambio,
una skill acotada puede codificar las decisiones operativas que un agente
necesita tomar repetidamente. Si la necesidad es solo un prompt de comando de
barra reutilizado, elegí una plantilla de prompt; consultá **Plantillas de
prompts**. Si la necesidad es comportamiento ejecutable, considerá una
extensión en vez de disfrazar la lógica del programa como prosa.

## Empezá por el contrato, no por el nombre de archivo

La guía de estilo de Gentle AI usa esta forma de directorio portable:

```text
skills/{skill-name}/
├── SKILL.md
├── assets/       # optional: templates, schemas, examples, fixtures
└── references/   # optional: longer local docs or rationale
```

`SKILL.md` es conciso porque se lee como contexto de trabajo. El objetivo del
paquete es de 180 a 450 tokens, con un máximo recomendado de 700 y un máximo
estricto de 1.000. Ese presupuesto no es una invitación a eliminar reglas
importantes. En cambio, mové los ejemplos largos, plantillas generadas,
esquemas y fundamentos de contexto a archivos locales en `assets/` o
`references/`. Las referencias deben apuntar a archivos que se distribuyen con
el proyecto o paquete, para que el contrato de tiempo de ejecución no dependa
de una página externa no examinada.

Usá frontmatter YAML con un nombre en kebab-case que normalmente coincida con el
directorio, una descripción entre comillas de una línea, una licencia y
metadatos:

```yaml
---
name: release-notes
description: "Trigger: release notes, changelog draft. Draft release notes from verified changes."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---
```

El ejemplo expone dos restricciones importantes: la descripción es una única
línea física segura para YAML y comienza con frases de disparador. Necesita
decir tanto *cuándo* aplica la skill como *qué* hace, porque el descubrimiento
depende de ese texto. No agregues una sección `Keywords` separada; colocá las
palabras esenciales de enrutamiento en la descripción.

## Dale al agente un camino de decisión ordenado

El orden de secciones requerido es deliberado:

1. **Contrato de activación**
2. **Reglas estrictas**
3. **Puertas de decisión**
4. **Pasos de ejecución**
5. **Contrato de salida**
6. **Referencias**

El contrato de activación indica cuándo usar la skill y cuándo no. Las reglas
estrictas vuelven visibles los límites no negociables. Las puertas de decisión
convierten la prosa con bifurcaciones en una tabla compacta, lo que ayuda a un
agente a evitar tanto el exceso inseguro como la ceremonia innecesaria. Los
pasos de ejecución describen la secuencia repetible más pequeña. El contrato de
salida nombra qué informar, comúnmente los archivos modificados, la verificación
realizada, las necesidades de actualizar el registro, la ambigüedad sin resolver
y el riesgo restante. Las referencias apuntan al material local detallado que el
agente debería consultar.

Escribí instrucciones imperativas, no prosa explicativa de tutorial. Preferí
viñetas y tablas de decisión antes que párrafos. Mantené las reglas concretas:
“read the style guide before editing” da una acción; “be careful with quality”
no. No inventes políticas de dominio, disparadores o restricciones para que una
skill parezca completa. Cuando una regla necesaria sea ambigua, preguntá o
marcá la ambigüedad para revisión humana.

Acá hay un patrón pequeño de puerta de decisión:

```markdown
| Situation | Action |
| --- | --- |
| An existing skill already covers the workflow | Update it instead of creating a duplicate |
| Templates or fixtures are needed | Put them in `assets/` |
| A rule is unclear | Report it; do not rewrite it automatically |
```

La tabla hace más que mejorar el formato. Obliga a un agente futuro a manejar de
forma predecible las bifurcaciones conocidas y facilita la revisión: una persona
revisora puede preguntar si las situaciones indicadas tienen una acción segura.

## Creá y después mejorá sin borrar la intención

La skill incluida `gentle-ai-skill-creator` proporciona un flujo de autoría.
Empieza por aclarar el comportamiento reutilizable, el tiempo de ejecución, las
frases de disparador y los no objetivos cuando no son evidentes. Inspecciona las
skills existentes antes de crear una nueva, usa el frontmatter y el orden de
secciones requeridos, y solicita actualizar el registro después de cambios en
skills de proyecto. La plantilla de prompt `/skill-creation` puede iniciar el
mismo flujo:

```text
/skill-creation <skill idea or name>
```

Una skill nueva no siempre es la respuesta. Las puertas de decisión de
skill-creator indican actualizar una skill existente cuando ya cubre el
comportamiento. Esto limita las instrucciones que compiten con disparadores
superpuestos.

Para una skill existente, usá el flujo `gentle-ai-skill-improver`. De forma
predeterminada es solo de auditoría: leé la guía de estilo y el registro,
inspeccioná los metadatos, la claridad de los disparadores, el orden de las
secciones, el presupuesto del cuerpo, la capacidad de acción, las puertas de
decisión, el contrato de salida y las referencias locales; luego devolvé los
cambios propuestos. Modifica archivos solo cuando la persona usuaria pide
explícitamente aplicar las mejoras. Preservá la intención de la persona autora,
las reglas críticas, la semántica de activación y los requisitos de salida.
Nunca elimines contenido significativo en silencio; mové el material extenso a
un archivo de apoyo cuando eso preserve el contrato.

## Terminá el trabajo del ecosistema

Pi descubre directamente un `SKILL.md` de proyecto válido. El registro de
skills de Gentle AI es un índice separado para delegación: registra nombres,
descripciones, alcances y rutas exactas disponibles; el archivo fuente sigue
siendo la autoridad. Después de crear, eliminar, mover o renombrar una skill de
proyecto, actualizalo cuando esté disponible:

```text
/skill-registry:refresh
```

Para las skills empaquetadas de gentle-pi, el flujo de creación además indica
agregar la skill a `scripts/verify-package-files.mjs`. Eso hace que la
verificación del contenido del paquete conozca el nuevo archivo distribuido. La
lección **Skills** explica cómo Pi descubre skills y cómo el registro permite a
un delegador pasar rutas exactas a un trabajador en lugar de parafrasear sus
reglas.

## Probalo

Elegí un problema repetido de tu propio proyecto. Antes de escribir nada,
indicá su disparador, su no objetivo y por qué una prueba o documentación común
no sería una mejor solución. Inspeccioná una skill relacionada existente para
evitar duplicación. Redactá solo su frontmatter y los seis encabezados de
sección, y luego preguntá si cada encabezado puede contener una instrucción o
decisión concreta. Si el flujo de trabajo no es verdaderamente reutilizable,
detenete ahí: esa es una decisión de diseño exitosa.

Una skill completa es lo suficientemente pequeña como para cargarse cuando se
necesita, lo suficientemente específica como para enrutar correctamente y lo
suficientemente explícita como para que un agente pueda devolver resultados
verificables sin convertir las convenciones del proyecto en políticas
inventadas.
