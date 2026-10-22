---
title: "Escribir habilidades"
description: "Crea contratos de instrucciones reutilizables y concisos para LLM que hagan el trabajo recurrente más seguro y claro."
module: "Memoria y habilidades"
---

# Escribir habilidades

Una buena habilidad cambia lo que un agente hace de manera confiable en una situación recurrente. No es
un artículo sobre un tema ni un lugar para recopilar todas las preferencias del equipo.
Es un **contrato de instrucciones de tiempo de ejecución** compacto: le indica a un agente futuro cuándo
activarse, qué restricciones no se pueden relajar, cómo elegir entre casos,
cómo ejecutar y qué evidencia devolver. Este enfoque es lo que hace que una habilidad
sea más útil que un prompt largo pegado en cada sesión.

Antes de escribir una, comprueba si el problema es realmente reutilizable. Crea o
actualiza una habilidad cuando un flujo de trabajo o convención se repite entre sesiones, las
restricciones locales difieren de la práctica general, un árbol de decisiones hace una elección más segura,
o las plantillas, esquemas y referencias mejorarían la repetibilidad. **No**
crees una habilidad para una tarea única, documentación genérica o reglas que deberían
aplicarse mediante código ejecutable, pruebas o un linter. Esas alternativas proporcionan
garantías más fuertes que las instrucciones del modelo.

Este límite también protege el contexto. Una habilidad que simplemente repite un README agrega
otro lugar donde las instrucciones pueden desviarse. Una habilidad acotada puede en cambio codificar las
decisiones operativas que un agente necesita tomar repetidamente. Si la necesidad es solo un
prompt de comando de barra reutilizado, elige una plantilla de prompt; consulta **Plantillas de prompts**.
Si la necesidad es comportamiento ejecutable, considera una extensión en lugar de disfrazar la lógica
del programa como prosa.

## Empieza con el contrato, no con el nombre de archivo

La guía de estilo de Gentle AI usa esta estructura de directorio portátil:

```text
skills/{skill-name}/
├── SKILL.md
├── assets/       # optional: templates, schemas, examples, fixtures
└── references/   # optional: longer local docs or rationale
```

`SKILL.md` es conciso porque se lee como contexto de trabajo. El objetivo del paquete
es 180–450 tokens, con un máximo recomendado de 700 y un máximo estricto de
1,000. Ese presupuesto no es una invitación a eliminar reglas importantes. En cambio,
mueve ejemplos extensos, plantillas generadas, esquemas y justificación de fondo a archivos locales
de `assets/` o `references/`. Las referencias deberían señalar archivos que se incluyen
con el proyecto o paquete, para que el contrato de tiempo de ejecución no dependa de una página externa
no examinada.

Usa frontmatter YAML con un nombre en kebab-case que normalmente coincida con el directorio,
una descripción entre comillas de una línea, una licencia y metadatos:

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

El ejemplo muestra dos restricciones importantes: la descripción es una línea física
segura para YAML y comienza con frases desencadenantes. Necesita
decir tanto *cuándo* aplica la habilidad como *qué* hace, porque el descubrimiento depende
de ese texto. No agregues una sección `Keywords` separada; coloca las palabras de enrutamiento
esenciales en la descripción.

## Dale al agente una ruta de decisión ordenada

El orden de secciones requerido es deliberado:

1. **Contrato de activación**
2. **Reglas estrictas**
3. **Puertas de decisión**
4. **Pasos de ejecución**
5. **Contrato de salida**
6. **Referencias**

El contrato de activación dice cuándo usar la habilidad y cuándo no hacerlo. Las reglas estrictas
hacen visibles los límites no negociables. Las puertas de decisión convierten la prosa de ramificación en
una tabla compacta, lo que ayuda a un agente a evitar tanto extralimitaciones inseguras como ceremonias
innecesarias. Los pasos de ejecución describen la secuencia repetible más pequeña. El contrato de
salida indica qué reportar, comúnmente archivos modificados, verificación realizada,
necesidades de actualización del registro, ambigüedad sin resolver y riesgo restante. Las referencias
señalan el material local detallado que el agente debería consultar.

Escribe instrucciones imperativas, no prosa explicativa de tutorial. Prefiere viñetas
y tablas de decisión a párrafos. Mantén las reglas concretas: “lee la guía de estilo
antes de editar” da una acción; “ten cuidado con la calidad” no. No inventes políticas de dominio, desencadenantes o restricciones para que una habilidad parezca completa.
Cuando una regla necesaria sea ambigua, pregunta o marca la ambigüedad para revisión humana.

Aquí hay un patrón pequeño de puerta de decisión:

```markdown
| Situation | Action |
| --- | --- |
| An existing skill already covers the workflow | Update it instead of creating a duplicate |
| Templates or fixtures are needed | Put them in `assets/` |
| A rule is unclear | Report it; do not rewrite it automatically |
```

La tabla hace más que mejorar el formato. Obliga a un agente futuro a manejar las
bifurcaciones conocidas de forma predecible y facilita la revisión: una persona revisora puede preguntar
si las situaciones indicadas tienen una acción segura.

## Crea y luego mejora sin borrar la intención

La habilidad incluida `gentle-ai-skill-creator` proporciona un flujo de trabajo de autoría. Comienza por aclarar el comportamiento reutilizable, el tiempo de ejecución, las frases desencadenantes y los objetivos excluidos cuando no son evidentes. Inspecciona las habilidades existentes antes de crear una nueva, usa el frontmatter y el orden de secciones requeridos, y pide actualizar el registro después de cambios de habilidades de proyecto. La plantilla de prompt `/skill-creation` puede iniciar el mismo flujo de trabajo:

```text
/skill-creation <skill idea or name>
```

Una habilidad nueva no siempre es la respuesta. Las puertas de decisión de skill-creator indican actualizar una habilidad existente cuando ya cubre el comportamiento. Esto limita
instrucciones en competencia con desencadenantes superpuestos.

Para una habilidad existente, usa el flujo de trabajo `gentle-ai-skill-improver`. De forma predeterminada
es solo de auditoría: lee la guía de estilo y el registro, inspecciona los metadatos, la claridad de los desencadenantes, el orden de secciones, el presupuesto del cuerpo, la capacidad de acción, las puertas de decisión, el contrato de salida y las referencias locales; luego devuelve los cambios propuestos. Modifica archivos
solo cuando la persona usuaria pide explícitamente aplicar mejoras. Conserva la intención de la persona autora, las reglas críticas, la semántica de activación y los requisitos de salida. Nunca
elimines contenido significativo silenciosamente; mueve material extenso a un archivo de apoyo
cuando eso conserve el contrato.

## Termina el trabajo del ecosistema

Pi descubre directamente un `SKILL.md` de proyecto válido. El registro de habilidades de Gentle AI
es un índice separado para delegación: registra nombres, descripciones, alcances y rutas exactas disponibles;
el archivo fuente sigue siendo autoritativo. Después de crear, eliminar, mover o
renombrar una habilidad de proyecto, actualízalo cuando esté disponible:

```text
/skill-registry:refresh
```

Para habilidades empaquetadas de gentle-pi, el flujo de trabajo del creador también pide
agregar la habilidad a `scripts/verify-package-files.mjs`. Eso hace que la comprobación del contenido
del paquete conozca el nuevo archivo distribuido. La lección **Habilidades** explica
cómo Pi descubre habilidades y cómo el registro permite que quien delega pase rutas exactas
a una persona trabajadora en lugar de parafrasear sus reglas.

## Pruébalo

Elige un problema repetido de tu propio proyecto. Antes de escribir nada, indica
su desencadenante, su objetivo excluido y por qué una prueba o documentación ordinaria no sería
una mejor solución. Inspecciona una habilidad existente relacionada para evitar duplicación. Redacta
solo su frontmatter y los seis encabezados de sección, luego pregunta si cada encabezado puede
contener una instrucción o decisión concreta. Si el flujo de trabajo no es realmente
reutilizable, detente ahí: esa es una decisión de diseño exitosa.

Una habilidad completada es lo bastante pequeña para cargar cuando sea necesaria, lo bastante específica para enrutarse
correctamente y lo bastante explícita para que un agente pueda devolver resultados verificables
sin convertir las convenciones del proyecto en política inventada.
