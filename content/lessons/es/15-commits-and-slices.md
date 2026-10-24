---
title: "Commits y porciones"
description: "Empaqueta comportamiento coherente en unidades de trabajo revisables y mantén explícita la entrega sobredimensionada."
module: "Desarrollo Impulsado Orgánicamente"
---

# Commits y porciones

Un commit es más útil que un conjunto de archivos con marca de tiempo. En ODD es una
**unidad de trabajo**: un comportamiento entregable, corrección, migración o unidad de documentación
que una persona revisora puede comprender, verificar y revertir sin desenredar
cambios no relacionados. Los commits de unidades de trabajo proporcionan la base para porciones de PR
revisables cuando una funcionalidad crece.

Esta lección trata sobre estructura, no sobre entrega automática. En el trabajo ODD grande
autorizado, los commits por unidad de trabajo en la rama de la funcionalidad forman parte de esa
autorización: el agente los hace a medida que avanza. Un commit o una forma de PR
elegida no autoriza hacer push, abrir un pull request, fusionar ni cambiar el modo de revisión. Esas
siguen siendo decisiones separadas de personas y de la política del repositorio.

## Haz commits por resultado, no por tipo de archivo

Una división débil refleja el árbol de directorios: “agregar modelos”, luego “agregar servicios”, luego
“agregar pruebas”. Ninguno de esos commits necesariamente funciona por sí solo, así que una persona revisora
debe reconstruir la funcionalidad a través de varios cambios.

En cambio, una división por unidad de trabajo cuenta una historia. Por ejemplo:

```text
feat(auth): add token validation domain model and tests
feat(auth): wire token validation into login flow
```

Cada commit tiene un propósito claro y deja el repositorio en un estado razonable
cuando se aplica por sí solo. Las pruebas permanecen con el comportamiento que verifican. La documentación
permanece con la funcionalidad o flujo de trabajo visible para el usuario que explica. Un buen mensaje
explica el resultado, no solo la lista de archivos, y revertir elimina una unidad coherente
en vez de trabajo colateral.

Antes de hacer commit, pregunta:

- ¿Este commit tiene un propósito claro?
- ¿El repositorio tiene sentido después de este commit por sí solo?
- ¿Están incluidas las pruebas y los documentos relevantes?
- ¿Se puede revertir sin revertir trabajo no relacionado?
- ¿El mensaje indica qué cambió para el proyecto o el usuario?

ODD pide mensajes de Conventional Commit para sus unidades de trabajo. Esto da un
historial consistente y orientado a resultados, mientras mantiene la evidencia de aceptación real
en el documento de funcionalidad.

## Las tareas, los commits y los candidatos son diferentes

Una tarea de documento de funcionalidad es una unidad de progreso seguido. Un commit puede contener una o
más tareas completas con sus pruebas y documentos. Una porción de PR es el grupo de
commits revisable que expone la entrega. Están relacionados pero no son intercambiables.

El documento de funcionalidad registra el commit que contiene cada tarea como evidencia. Una
unidad de alto riesgo obtiene su propio commit para que pueda revisarse sola. El candidato de
revisión nativa es ese commit de unidad de trabajo, o la porción de PR cuando se difiere la revisión; nunca
es una casilla TODO ni toda la rama acumulada de la funcionalidad. Mantener claros estos
límites permite que la verificación y la reversión apunten al cambio real.

## El presupuesto de revisión es orientativo

ODD usa cerca de **400 líneas modificadas por el autor**—adiciones más eliminaciones—como un
presupuesto de revisión orientativo. Ayuda a prever la carga de trabajo de la persona revisora y a decidir si
se debe dividir la entrega. No es un límite, un clasificador de tareas, una división forzada ni una
razón para omitir trabajo de calidad. El mismo número puede configurarse de forma diferente para
una sesión.

Nunca ajustes el presupuesto eliminando comentarios, líneas en blanco, documentación o pruebas,
o comprimiendo código. Primero realiza una división honesta por unidad de trabajo coherente.
Si ninguna división cohesiva coloca cada porción bajo el presupuesto, informa el conteo honesto más pequeño y por
qué no puede reducirse más; no iteres interminablemente hacia un número cosmético.

Un PR enfocado de 400 líneas o menos es razonable. Un PR sobredimensionado aumenta la carga cognitiva
de la persona revisora, ralentiza la retroalimentación y acopla la reversión de trabajo que de otro modo sería separable. La guía
de PR encadenados busca mantener cada PR revisable en unos 60 minutos.

## Estrategias de entrega

Al crear un documento de funcionalidad, prevé las líneas modificadas por el autor a partir de las tareas y
elige una estrategia de entrega. Mantén un conteo continuo de los commits de unidades de trabajo. Si el
pronóstico o el conteo continuo supera el presupuesto orientativo, aplica la estrategia seleccionada antes
del siguiente commit.

El valor predeterminado es `ask-on-risk`: pregunta una vez usando el menú de entrega sobredimensionada. Con
`auto-chain`, pregunta solo si la elección de cadena aún no está almacenada en caché, luego divide
automáticamente. `single-pr` mantiene un PR sujeto a la política del repositorio de destino.
`exception-ok` registra una excepción de política aceptada explícitamente cuando el destino tiene tal
ruta. Una selección de un solo PR no es, por sí sola, una excepción aceptada.

Cuando se necesita una elección de cadena, las opciones aparecen en este orden:

1. **Cadena de rama de funcionalidad/seguimiento** (`feature-branch-chain`): las porciones secundarias se
   revisan antes de la integración final de la funcionalidad.
2. **Cadena de rama predeterminada/main verificada** (`stacked-to-main`): las porciones revisables de forma independiente aterrizan en orden en la rama predeterminada verificada del repositorio, cualquiera que sea su nombre.
3. **Un solo PR — menos recomendado** (`single-pr`): mantén el cambio sobredimensionado
   junto.

“Menos recomendado” aplica solo a un menú de PR único sobredimensionado. No
significa que todos los PR únicos sean malos. La tercera opción borra cualquier elección de cadena
pendiente; no es en sí misma una estrategia de cadena. En contextos no interactivos donde no se puede
responder ninguna pregunta, la guía ODD usa la cadena de rama de funcionalidad/seguimiento y
registra esa elección en el Log.

## Lo que requiere una cadena

Antes de crear ramas o PR, verifica la rama predeterminada del repositorio de destino en vez de asumir que
se llama `main`. No mezcles estrategias una vez que se elige una. En una cadena, cada PR
secundario contiene una unidad de trabajo entregable con sus pruebas y documentos, describe su estado
inicial y final, dependencias, trabajo de seguimiento y elementos fuera de alcance, e incluye un
diagrama de dependencias que marca el PR actual.

Una cadena de rama de funcionalidad usa un PR de seguimiento en borrador, sin fusionar. El primer
PR secundario apunta a la rama de seguimiento; cada PR posterior apunta a la rama secundaria
inmediatamente anterior. Una cadena apilada hacia main usa en cambio la rama predeterminada verificada como
destino de integración. Si el diff de un secundario incluye trabajo de la base incorrecta,
trátalo como un problema de diff contaminado y corrige la base para que la persona revisora vea
solo la unidad actual.

Para un solo PR, no crees artefactos exclusivos de cadena como un seguimiento o un diagrama de
dependencias secundarias. Sigue la plantilla normal de PR y la política de contribución del destino.
`size:exception` no es una etiqueta universal: úsala solo si la política de destino la define y
se cumplen sus condiciones de autorización.

## Inspección local útil

Antes de un commit, inspecciona tanto la historia como el tamaño:

```bash
git diff --stat
git diff --cached --stat
git log --oneline -5
```

Las estadísticas del diff revelan el trabajo bajo revisión; los mensajes recientes del registro muestran el
estilo de commits del repositorio. No deciden el tamaño de la tarea ni sustituyen leer el
diff real.

## Errores comunes

- **Separar las pruebas en un commit posterior.** Hace que el comportamiento quede temporalmente
  sin verificar.
- **Dividir por carpetas.** Divide por resultados comprensibles de forma independiente.
- **Tratar 400 líneas como un límite estricto.** Conserva código y evidencia coherentes.
- **Asumir `main`.** Verifica la rama predeterminada.
- **Tratar una estrategia elegida como permiso de entrega.** Hacer push, crear PR y fusionar
  siguen siendo autorizaciones separadas.

## Pruébalo

Ejecuta `git diff --stat` y mira el cambio actual. Describe su resultado coherente más pequeño
en una oración, luego enumera las pruebas y la documentación que le corresponden. Si el trabajo
superara el presupuesto de revisión, decide si sus unidades pueden aterrizar de forma independiente o
necesitan integración a nivel de funcionalidad. Eso te indica qué opción de cadena presentarías—sin crear un PR ni asumir que la
aprobación para elegir una forma es aprobación para entregar.
