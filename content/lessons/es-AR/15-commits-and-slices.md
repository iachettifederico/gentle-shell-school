---
title: "Commits y porciones"
description: "Empaquetá comportamiento coherente en unidades de trabajo revisables y mantené explícita la entrega sobredimensionada."
module: "Desarrollo guiado orgánicamente"
---

# Commits y porciones

Un commit es más útil que un paquete de archivos con marca de tiempo. En ODD es una
**unidad de trabajo**: un comportamiento entregable, corrección, migración o unidad
de documentación que una persona revisora puede entender, verificar y revertir sin
desentramar cambios no relacionados. Los commits de unidad de trabajo proporcionan la
base para porciones de PR revisables cuando una funcionalidad crece.

Esta lección trata sobre estructura, no sobre entrega automática. Un commit o una
forma de PR elegida no autoriza hacer push, abrir un pull request, fusionar ni cambiar
el modo de revisión. Esas siguen siendo decisiones separadas de personas y de la
política del repositorio.

## Hacé commit por resultado, no por tipo de archivo

Una división débil refleja el árbol de directorios: “agregar modelos”, luego “agregar
servicios”, luego “agregar pruebas”. Ninguno de esos commits necesariamente funciona
por sí solo, así que una persona revisora debe reconstruir la funcionalidad a través
de varios cambios.

En cambio, una división por unidad de trabajo cuenta una historia. Por ejemplo:

```text
feat(auth): add token validation domain model and tests
feat(auth): wire token validation into login flow
```

Cada commit tiene un propósito claro y deja el repositorio en un estado sensato cuando
se aplica por separado. Las pruebas se quedan con el comportamiento que verifican. La
documentación se queda con la funcionalidad o el flujo de trabajo visible para la
persona usuaria que explica. Un buen mensaje explica el resultado, no meramente la
lista de archivos, y revertir elimina una unidad coherente en vez de trabajo colateral.

Antes de hacer commit, preguntate:

- ¿Este commit tiene un propósito claro?
- ¿El repositorio tiene sentido después de este commit por sí solo?
- ¿Están incluidas las pruebas y los documentos relevantes?
- ¿Se puede revertir sin revertir trabajo no relacionado?
- ¿El mensaje dice qué cambió para el proyecto o la persona usuaria?

ODD pide mensajes de Conventional Commit para sus unidades de trabajo. Esto da un
historial consistente y orientado al resultado, mientras conserva la evidencia real
de aceptación en el documento de funcionalidad.

## Las tareas, los commits y los candidatos son distintos

Una tarea de documento de funcionalidad es una unidad de progreso seguido. Un commit
puede contener una o más tareas completas con sus pruebas y documentos. Una porción de
PR es el grupo revisable de commits que la entrega expone. Están relacionados, pero no
son intercambiables.

El documento de funcionalidad registra el commit que contiene cada tarea como
evidencia. Una unidad de alto riesgo obtiene su propio commit para que pueda revisarse
por separado. El candidato de revisión nativa es ese commit de unidad de trabajo, o la
porción de PR cuando la revisión se difiere; nunca es una casilla de TODO ni toda la
rama de funcionalidad acumulada. Mantener claros estos límites permite que la
verificación y la reversión apunten al cambio real.

## El presupuesto de revisión es orientativo

ODD usa alrededor de **400 líneas modificadas creadas** —adiciones más eliminaciones—
como un presupuesto de revisión orientativo. Ayuda a pronosticar la carga de trabajo de
las personas revisoras y decidir si dividir la entrega. No es un límite, un clasificador
de tareas, una división forzada ni una razón para omitir trabajo de calidad. El mismo
número puede configurarse de otra forma para una sesión.

Nunca ajustes el presupuesto borrando comentarios, líneas en blanco, documentación o
pruebas, ni comprimiendo código. Primero hacé una división honesta por unidad de
trabajo coherente. Si ninguna división cohesiva deja cada porción bajo el presupuesto,
informá el menor conteo honesto y por qué no puede reducirse más; no iteres sin fin
hacia un número cosmético.

Un PR enfocado de 400 líneas o menos es razonable. Un PR sobredimensionado aumenta la
carga cognitiva de las personas revisoras, ralentiza la retroalimentación y acopla la
reversión de trabajo separable. La guía de PR encadenados busca mantener cada PR
revisable en unos 60 minutos.

## Estrategias de entrega

Al crear un documento de funcionalidad, pronosticá las líneas modificadas creadas a
partir de las tareas y elegí una estrategia de entrega. Mantené un conteo actualizado
a partir de los commits de unidad de trabajo. Si el pronóstico o el conteo actualizado
supera el presupuesto orientativo, aplicá la estrategia seleccionada antes del
siguiente commit.

La opción predeterminada es `ask-on-risk`: preguntá una vez mediante el menú de
entrega sobredimensionada. Con `auto-chain`, preguntá solo si la elección de cadena no
está ya almacenada en caché, y luego dividí automáticamente. `single-pr` mantiene un
solo PR sujeto a la política del repositorio de destino. `exception-ok` registra una
excepción de política aceptada explícitamente cuando el destino tiene esa vía. Una
selección de PR único no es, por sí misma, una excepción aceptada.

Cuando se necesita una elección de cadena, las opciones aparecen en este orden:

1. **Cadena de rama de funcionalidad/tracker** (`feature-branch-chain`): las porciones
   hijas se revisan antes de la integración final de la funcionalidad.
2. **Cadena de rama predeterminada/main verificada** (`stacked-to-main`): las porciones
   revisables de forma independiente aterrizan en orden en la rama predeterminada
   verificada del repositorio, cualquiera sea su nombre.
3. **Un único PR — el menos recomendado** (`single-pr`): mantené el cambio
   sobredimensionado junto.

“Menos recomendado” se aplica solo a un menú de PR único sobredimensionado. No
significa que todos los PR únicos sean malos. La tercera opción borra cualquier elección
de cadena pendiente; no es en sí misma una estrategia de cadena. En contextos no
interactivos donde no se puede responder ninguna pregunta, la guía de ODD usa la cadena
de rama de funcionalidad/tracker y registra esa elección en el Log.

## Qué requiere una cadena

Antes de crear ramas o PR, verificá la rama predeterminada del repositorio de destino
en vez de asumir que se llama `main`. No mezcles estrategias una vez que se eligió una.
En una cadena, cada PR hijo contiene una unidad de trabajo entregable con sus pruebas y
documentos, describe sus estados inicial y final, dependencias, trabajo de seguimiento
e ítems fuera de alcance, e incluye un diagrama de dependencias que marca el PR actual.

Una cadena de rama de funcionalidad usa un PR tracker en borrador, sin fusión. El primer
hijo apunta a la rama tracker; cada hijo posterior apunta a la rama padre inmediata.
Una cadena apilada hacia main usa, en cambio, la rama predeterminada verificada como
destino de integración. Si el diff de un hijo incluye trabajo de la base equivocada,
tratalo como un problema de diff contaminado y corregí la base para que la persona
revisora vea solo la unidad actual.

Para un único PR, no crees artefactos exclusivos de cadena como un tracker o un
diagrama de dependencias hijo. Seguí la plantilla de PR y la política de contribución
normales del destino. `size:exception` no es una etiqueta universal: usala solo si la
política de destino la define y se cumplen sus condiciones de autorización.

## Inspección local útil

Antes de un commit, inspeccioná tanto la historia como el tamaño:

```bash
git diff --stat
git diff --cached --stat
git log --oneline -5
```

Las estadísticas del diff revelan el trabajo bajo revisión; los mensajes recientes del
log muestran el estilo de commits del repositorio. No deciden el tamaño de la tarea ni
sustituyen la lectura del diff real.

## Errores comunes

- **Separar las pruebas en un commit posterior.** Hace que el comportamiento quede
  temporalmente sin verificar.
- **Dividir por carpetas.** Dividí por resultados comprensibles de manera
  independiente.
- **Tratar 400 líneas como un límite rígido.** Preservá el código coherente y la
  evidencia.
- **Asumir `main`.** Verificá la rama predeterminada.
- **Tratar una estrategia elegida como permiso de entrega.** El push, la creación de
  PR y la fusión siguen siendo autorizaciones separadas.

## Probalo

Ejecutá `git diff --stat` y observá el cambio actual. Describí su resultado coherente
más pequeño en una oración, y luego enumerá las pruebas y la documentación que le
corresponden. Si el trabajo superara el presupuesto de revisión, decidí si sus unidades
pueden aterrizar de manera independiente o necesitan integración a nivel de
funcionalidad. Eso te indica qué opción de cadena presentarías, sin crear un PR ni
suponer que la aprobación para elegir una forma es aprobación para entregar.
