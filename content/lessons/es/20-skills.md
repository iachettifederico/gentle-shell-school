---
title: "Habilidades"
description: "Aprende cómo Pi descubre y carga contratos de instrucciones enfocados para trabajo recurrente."
module: "Memoria y habilidades"
---

# Habilidades

Los agentes de programación acumulan dos tipos opuestos de contexto. Algunas instrucciones se
necesitan casi siempre: límites de seguridad, convenciones del proyecto y la solicitud activa.
Otras instrucciones importan solo para un tipo de trabajo específico, como
preparar un pull request, auditar una habilidad o generar un documento. Cargar
cada procedimiento especializado en cada conversación desperdicia contexto y hace que las
reglas importantes sean más difíciles de notar. Una **habilidad** de Pi resuelve esto al empaquetar un
contrato de instrucciones enfocado que se carga cuando su flujo de trabajo es relevante.

Una habilidad portátil es un directorio que contiene `SKILL.md`. También puede incluir archivos
que hacen práctico el contrato:

```text
pdf-tools/
├── SKILL.md
├── scripts/
│   └── extract.sh
├── references/
│   └── formats.md
└── assets/
    └── template.json
```

El archivo `SKILL.md` comienza con frontmatter y luego proporciona instrucciones directas
al agente. Su nombre y descripción son especialmente importantes. Al iniciar,
Pi explora las ubicaciones de habilidades configuradas y anuncia el nombre,
descripción y ruta de cada habilidad disponible en el prompt del sistema. **No** agrega el cuerpo
completo. Cuando la tarea coincide, el modelo lee `SKILL.md` y sigue sus
instrucciones. Ese mecanismo de carga diferida mantiene disponible un procedimiento especializado
sin pagar por todos sus detalles en cada solicitud.

## Elige el mecanismo reutilizable correcto

Una habilidad es para un flujo de trabajo que necesita más contexto que un prompt reutilizable, pero
no necesita un punto de integración ejecutable. Puede agrupar scripts de apoyo,
referencias y recursos junto a sus instrucciones. Por ejemplo, una habilidad puede
enseñar a un agente las puertas de decisión y el contrato de salida para un flujo de trabajo de revisión
recurrente, mientras mantiene material de referencia más extenso en un archivo cercano.

Una **plantilla de prompt** es más ligera. Convierte un archivo Markdown en un comando de barra
reutilizable y expande texto en la conversación del agente. Las plantillas pueden aceptar
argumentos, pero son mejores cuando quieres el mismo prompt otra vez sin comportamiento
ejecutable ni un conjunto mayor de instrucciones de apoyo. La lección **Plantillas de prompts**
cubre su sustitución de argumentos y comportamiento de comandos. Una extensión es diferente de nuevo: proporciona comportamiento de integración ejecutable.
No conviertas un prompt pequeño y reutilizable en una habilidad, ni una habilidad en una extensión,
a menos que su necesidad real cruce ese límite.

## Las descripciones son enrutamiento, no decoración

Pi depende de la descripción para ayudar al modelo a decidir si debe cargar una habilidad.
Una descripción debería indicar tanto qué hace la habilidad como cuándo aplica. “Ayuda
con PDF” deja la ruta ambigua; “Extrae texto y tablas de archivos PDF.
Úsala al leer, convertir o inspeccionar PDF” le da al agente un desencadenante útil.
Una persona usuaria puede anular una selección automática incierta con:

```text
/skill:pdf-tools
```

Los argumentos después de ese comando se agregan a las instrucciones cargadas como una solicitud de usuario,
así que esto también es válido:

```text
/skill:pdf-tools extract report.pdf
```

Una habilidad puede establecer `disable-model-invocation: true` en su frontmatter cuando
debería estar disponible solo mediante invocación explícita. La configuración `enableSkillCommands`
controla si el descubrimiento interactivo muestra comandos de habilidad; los comandos `/skill:name`
ingresados manualmente siguen funcionando. Estos controles separan *disponible*
de *seleccionada automáticamente*, lo cual es útil para flujos de trabajo potentes o poco frecuentes.

## Descubrimiento, alcance y confianza

Pi descubre directorios `SKILL.md` recursivamente en ubicaciones de habilidades configuradas.
Admite las ubicaciones de Agent Skills `~/.agents/skills/` y `.agents/skills/`.
Los directorios de proyecto `.agents/skills/` se descubren desde el directorio de trabajo
hasta sus ancestros, deteniéndose en la raíz del repositorio cuando existe una. Pi también
acepta algunas habilidades Markdown independientes, pero un directorio que contiene `SKILL.md`
es la forma portátil.

Esa comodidad tiene una implicación de seguridad: una habilidad de proyecto puede indicarle a un agente que
ejecute scripts o modifique archivos. Revisa habilidades desconocidas y sus archivos de apoyo
antes de otorgar confianza al proyecto. Un `SKILL.md` mal formado, o una habilidad declarada sin
descripción, no se carga. Si las habilidades comparten un nombre, Pi conserva la primera que descubre
y emite una advertencia. El nombre y la descripción de enrutamiento son por lo tanto parte
del comportamiento, no meramente etiquetas.

Después de agregar o editar una habilidad durante una sesión activa de Pi, ejecuta `/reload` para que
Pi la recargue. Para distribuir habilidades mediante npm o Git, usa un paquete de Pi y
mantén la configuración de entorno requerida en ese paquete.

## El registro de habilidades de Gentle AI

Gentle AI agrega un flujo de trabajo de registro para quienes delegan. El archivo generado
`.atl/skill-registry.md` es un índice de nombres de habilidades, descripciones de desencadenantes,
alcances y rutas exactas a `SKILL.md`. No es un sustituto abreviado de las
habilidades mismas. Un agente padre compara una tarea con el registro, pasa
solo rutas exactas relevantes a un subagente y le indica a ese subagente que lea esos
archivos antes de trabajar. Esto evita copiar resúmenes con pérdida en las entregas y permite
que la habilidad siga siendo la fuente de verdad.

La habilidad del registro indica actualizar después de instalar, eliminar, crear, mover
o renombrar habilidades. Su comando de actualización es:

```text
/skill-registry:refresh
```

El registro de paquetes explora directorios de habilidades conocidos del proyecto y de la persona usuaria, excluye
`_shared`, `skill-registry` y nombres que comienzan con `sdd-`, y elimina duplicados por
nombre de habilidad, con preferencia por una habilidad de proyecto sobre una de usuario. Si no se encuentran
habilidades, escribe un registro vacío para que los agentes dejen de buscar a ciegas. La
extensión también puede actualizar un registro después de cambios en directorios de habilidades observados;
el comando explícito sigue siendo la forma deliberada de regenerarlo.

Las habilidades incluidas demuestran el punto: skill-registry indexa habilidades, mientras que
skill-creator proporciona un contrato de tiempo de ejecución para crear habilidades reutilizables y
skill-improver proporciona un contrato que prioriza la auditoría para mejorar habilidades existentes.
La siguiente lección, **Escribir habilidades**, profundiza en esas reglas de autoría.

## Pruébalo

Abre una sesión e inspecciona los nombres y las descripciones de habilidades que expone. Elige una
cuya descripción coincida claramente con una tarea que podrías realizar; explica por qué su
desencadenante es lo bastante específico. Luego localiza su `SKILL.md` antes de depender de ella.
Si mantienes habilidades de proyecto, actualiza el registro después de un cambio aprobado
deliberadamente y compara la entrada del índice con el archivo fuente.

El resultado al que debes aspirar es la proporción: mantén pequeño el contexto común, carga instrucciones de flujo de trabajo precisas solo cuando apliquen y trata las instrucciones descubiertas como material adyacente al código que vale la pena revisar antes de que dirijan trabajo real.
