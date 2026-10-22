---
title: "Skills"
description: "Aprendé cómo Pi descubre y carga contratos de instrucciones enfocados para trabajo recurrente."
module: "Memoria y habilidades"
---

# Skills

Los agentes de programación acumulan dos tipos opuestos de contexto. Algunas
instrucciones se necesitan casi siempre: límites de seguridad, convenciones del
proyecto y el pedido en curso. Otras instrucciones importan solo para un tipo
acotado de trabajo, como preparar un pull request, auditar una skill o generar
un documento. Cargar cada procedimiento especializado en cada conversación
desperdicia contexto y vuelve más difíciles de notar las reglas importantes.
Una **skill** de Pi resuelve esto al empaquetar un contrato de instrucciones
enfocado que se carga cuando su flujo de trabajo es pertinente.

Una skill portable es un directorio que contiene `SKILL.md`. También puede
incluir archivos que vuelven práctico el contrato:

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

El archivo `SKILL.md` empieza con frontmatter y luego proporciona instrucciones
directas al agente. Su nombre y descripción son especialmente importantes. Al
iniciarse, Pi escanea las ubicaciones configuradas para skills y anuncia el
nombre, la descripción y la ruta de cada skill disponible en el prompt de
sistema. **No** agrega el cuerpo completo. Cuando la tarea coincide, el modelo
lee `SKILL.md` y sigue sus instrucciones. Ese mecanismo de carga diferida
mantiene disponible un procedimiento especializado sin pagar por todo su
detalle en cada pedido.

## Elegí el mecanismo reutilizable adecuado

Una skill sirve para un flujo de trabajo que necesita más contexto que un prompt
reutilizable, pero no necesita un punto de integración ejecutable. Puede agrupar
scripts de apoyo, referencias y recursos junto con sus instrucciones. Por
ejemplo, una skill puede enseñarle a un agente las puertas de decisión y el
contrato de salida para un flujo de revisión recurrente, mientras conserva el
material de referencia más extenso en un archivo cercano.

Una **plantilla de prompt** es más liviana. Convierte un archivo Markdown en un
comando de barra reutilizable y expande texto en la conversación del agente.
Las plantillas pueden aceptar argumentos, pero son mejores cuando querés usar
el mismo prompt otra vez sin comportamiento ejecutable ni un conjunto mayor de
instrucciones de apoyo. La lección **Plantillas de prompts** cubre su
sustitución de argumentos y comportamiento de comandos. Una extensión es
diferente otra vez: aporta comportamiento de integración ejecutable. No
conviertas un prompt reutilizable pequeño en una skill, ni una skill en una
extensión, salvo que su necesidad real cruce ese límite.

## Las descripciones son enrutamiento, no decoración

Pi se apoya en la descripción para ayudar al modelo a decidir si debe cargar una
skill. Una descripción debe indicar tanto qué hace la skill como cuándo aplica.
“Helps with PDFs” deja ambigua la ruta; “Extract text and tables from PDF files.
Use when reading, converting, or inspecting PDFs” le da al agente un
disparador útil. Una persona puede anular una selección automática incierta con:

```text
/skill:pdf-tools
```

Los argumentos después de ese comando se agregan a las instrucciones cargadas
como un pedido de usuario, así que esto también es válido:

```text
/skill:pdf-tools extract report.pdf
```

Una skill puede establecer `disable-model-invocation: true` en su frontmatter
cuando solo debería estar disponible mediante invocación explícita. La
configuración `enableSkillCommands` controla si el descubrimiento interactivo
muestra comandos de skills; los comandos `/skill:name` ingresados manualmente
siguen funcionando. Estos controles separan *disponible* de *seleccionada
automáticamente*, lo que resulta útil para flujos de trabajo potentes o poco
frecuentes.

## Descubrimiento, alcance y confianza

Pi descubre directorios `SKILL.md` de forma recursiva en las ubicaciones de
skills configuradas. Admite las ubicaciones de Agent Skills `~/.agents/skills/`
y `.agents/skills/`. Los directorios de proyecto `.agents/skills/` se descubren
desde el directorio de trabajo pasando por sus antecesores, y se detienen en la
raíz del repositorio cuando existe una. Pi también acepta algunas skills
Markdown independientes, pero un directorio que contiene `SKILL.md` es la forma
portable.

Esa comodidad tiene una implicación de seguridad: una skill del proyecto puede
decirle a un agente que ejecute scripts o modifique archivos. Revisá las skills
desconocidas y sus archivos de apoyo antes de otorgar confianza al proyecto. Un
`SKILL.md` mal formado, o una skill declarada sin descripción, no se carga. Si
las skills comparten un nombre, Pi conserva la primera descubierta y emite una
advertencia. El nombre y la descripción de enrutamiento son por lo tanto parte
del comportamiento, no meras etiquetas.

Después de agregar o editar una skill durante una sesión activa de Pi, ejecutá
`/reload` para que Pi la recargue. Para distribuir skills a través de npm o Git,
usá un paquete de Pi y mantené la configuración de entorno requerida en ese
paquete.

## El registro de skills de Gentle AI

Gentle AI agrega un flujo de registro para delegadores. El
`.atl/skill-registry.md` generado es un índice de nombres de skills,
descripciones de disparadores, alcances y rutas exactas de `SKILL.md`. No es un
sustituto abreviado de las propias skills. Un agente padre compara una tarea con
el registro, pasa solo las rutas exactas pertinentes a un subagente y le indica
a ese subagente que lea esos archivos antes de trabajar. Esto evita copiar
resúmenes con pérdida en los handoffs y permite que la skill siga siendo la
fuente de verdad.

La skill de registro dice que hay que actualizar después de instalar, eliminar,
crear, mover o renombrar skills. Su comando de actualización es:

```text
/skill-registry:refresh
```

El registro del paquete escanea directorios conocidos de skills de proyecto y
de usuario, excluye `_shared`, `skill-registry` y los nombres que empiezan con
`sdd-`, y deduplica por nombre de skill con preferencia de una skill de proyecto
sobre una de usuario. Si no se encuentran skills, escribe un registro vacío para
que los agentes dejen de buscar a ciegas. La extensión también puede actualizar
un registro después de cambios observados en directorios de skills; el comando
explícito sigue siendo la forma deliberada de regenerarlo.

Las skills incluidas demuestran el punto: skill-registry indexa skills, mientras
que skill-creator proporciona un contrato de tiempo de ejecución para crear
skills reutilizables y skill-improver proporciona un contrato centrado primero
en la auditoría para mejorar skills existentes. La próxima lección, **Escribir
skills**, se adentra en esas reglas de autoría.

## Probalo

Abrí una sesión e inspeccioná los nombres y descripciones de skills que expone.
Elegí una cuya descripción coincida claramente con una tarea que realmente
podrías hacer; explicá por qué su disparador es lo bastante específico. Luego
ubicá su `SKILL.md` antes de confiar en ella. Si mantenés skills de proyecto,
actualizá el registro después de un cambio deliberadamente aprobado y compará la
entrada del índice con el archivo fuente.

El resultado al que apuntar es la proporción: mantené pequeño el contexto común,
cargá instrucciones precisas de flujo de trabajo solo cuando aplican y tratá las
instrucciones descubiertas como material cercano al código que vale la pena
revisar antes de que dirijan trabajo real.
