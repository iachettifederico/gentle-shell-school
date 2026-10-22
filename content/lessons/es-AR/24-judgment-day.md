---
title: "Judgment Day"
description: "Usá una revisión adversarial dual, ciega y acotada sin convertir la salida del revisor en autoridad de entrega."
module: "Seguridad y revisión"
---

Algunos cambios merecen una segunda mirada deliberadamente adversarial. El peligro es
convertir ese deseo en una multitud interminable de revisores, afirmaciones mutables y
conclusiones vagas de “se ve bien”. **Judgment Day** es la respuesta acotada de Gentle AI:
una revisión dual independiente solicitada explícitamente, con un objetivo fijo, dos
jueces ciegos, hallazgos congelados, como máximo dos rondas de corrección y un veredicto
terminal.

Es independiente del flujo de trabajo de **Revisión nativa**. Judgment Day no habilita,
reemplaza, inicia, configura ni consume la revisión habitual de un linaje. Una revisión
habitual solicitada por separado sigue siendo independiente. Ninguno de los procesos
autoriza la entrega: el commit, push, pull request, publicación de versión y publicación
siguen siendo decisiones ordinarias de la política del repositorio.

## Empezá solo con una solicitud explícita

Judgment Day no es un ritual de calidad de fondo. Solo comienza cuando una persona usuaria
solicita explícitamente “Judgment Day”, “Judgement Day”, dual review, adversarial review
o una solicitud equivalente. Antes de que se ejecuten actores, el controlador resuelve un
objetivo exacto, toma una instantánea del alcance completo y vincula el árbol de revisión
inicial.

Esa regla de activación protege tanto el costo como el significado. Sin un objetivo
exacto, dos jueces pueden revisar versiones o alcances diferentes. Sin una solicitud
explícita, un agente servicial podría crear un proceso paralelo costoso que la persona
usuaria no pidió. El objetivo no es más comentarios; es evidencia creíble y vinculada al
candidato para un cambio importante.

## Descubrimiento inicial: dos recorridos independientes

Judgment Day empieza con **exactamente dos jueces ciegos**—juez A y juez B—y **cero
refutadores**. Se ejecutan en simultáneo con criterios de objetivo idénticos, pero no se
coordinan ni dependen de las conclusiones del otro. Ambos son de solo lectura.

El presupuesto de descubrimiento normal es un recorrido exhaustivo de solo lectura por
juez. Un objetivo a escala 4R completa—como una ruta activa de autenticación,
actualización, seguridad o pagos, o un cambio de más de 400 líneas—puede usar como máximo
dos recorridos por juez. No hay un bucle de “seguir buscando hasta que no quede nada”. Un
recorrido acotado hace visible el costo de la revisión y evita que la fase de
descubrimiento se convierta en una investigación sin límites.

Durante el descubrimiento inicial, los jueces se ejecutan exactamente una vez contra el
`initial_review_tree` proporcionado. No conservan estado, modifican afirmaciones, lanzan
otros actores, solicitan correcciones, validan correcciones ni entregan nada. Devuelven
solo filas de candidato. Un candidato útil es concreto: tiene un identificador estable,
ubicación exacta, gravedad, clase de evidencia y una afirmación de evidencia que describe
el impacto en la persona usuaria. Una revisión limpia es una lista de candidatos vacía,
no un informe omitido.

El foco de los jueces difiere lo suficiente como para reducir puntos ciegos correlacionados.
El juez A enfatiza corrección, regresiones, pruebas faltantes, comportamiento inseguro y
un desajuste con la solicitud. El juez B cuestiona supuestos, con énfasis en casos límite,
riesgos de integración, brechas de pruebas y regresiones visibles para la persona usuaria.
Su salida sigue siendo data no confiable: no puede autorizar transiciones, correcciones,
recibos, compuertas ni entrega.

## Congelá las afirmaciones antes de corregir

El controlador canoniza y congela las filas de candidato después de que regresan ambos
jueces. Es un mecanismo clave. Una corrección posterior no puede reescribir en silencio
la afirmación que supuestamente aborda, y la nueva evaluación puede limitarse a un
conjunto conocido de ID y un diff conocido.

La gravedad importa. Los candidatos WARNING y SUGGESTION son filas informativas de una
sola vez y nunca programan correcciones. Para las filas graves que persisten, el
controlador pide aprobación humana cuando es necesaria y luego autoriza un lote de
corrección *acotado*. La persona humana y el controlador son responsables de esa
autorización; un juez no puede promover su propio hallazgo a una instrucción de edición.

El agente de corrección es deliberadamente quirúrgico. Su despacho contiene la declaración
explícita de activación de Judgment Day, los ID graves exactos autorizados, un número de
ronda (`1 of 2` o `2 of 2`), un SHA-256 de libro mayor congelado, filas congeladas exactas
y superficies de edición permitidas. Corrige solo esos ID proporcionados, preserva la
intención de diseño original, agrega pruebas enfocadas cuando cambia el comportamiento y
devuelve evidencia del árbol candidato y del diff de corrección. No agrega hallazgos,
altera afirmaciones congeladas, entrega, publica ni inicia otro actor.

Este es un patrón útil más allá de Judgment Day: limitá a un editor mediante el problema,
candidato y superficie de edición específicos, en lugar de darle una instrucción abierta
como “hacé feliz a la revisión”.

## Nueva evaluación acotada, no un nuevo recorrido de descubrimiento

Después del lote, la nueva evaluación recibe solo los ID congelados solicitados, sus filas
exactas vinculadas por hash y el diff de corrección. Los jueces resuelven solo esos ID y
las regresiones en las líneas de corrección. No pueden agregar hallazgos nuevos, cambiar
afirmaciones congeladas, solicitar otra corrección, lanzar actores, conservar autoridad ni
repetir su recorrido.

Para cada ID proporcionado, la resolución es una de estas:

- **verified** — se verifica que la preocupación proporcionada está resuelta;
- **corroborated** — la preocupación proporcionada sigue respaldada; o
- **regression** — las líneas de corrección introducen una regresión relevante para el
  alcance proporcionado.

Esta distinción mantiene honesta la nueva evaluación. No es una oportunidad para ampliar
el alcance ni transformar una comprobación de corrección en otra auditoría completa.

Judgment Day puede usar como máximo dos rondas de corrección/nueva evaluación. Si las
filas graves sobreviven la segunda ronda, **escalan**. No existe una transición a una
tercera ronda. La escalada es un resultado sincero: dice que el proceso acotado no
resolvió esos riesgos, por lo que una persona humana debe decidir el camino siguiente en
vez de quemar más ciclos de revisión no planeados.

## Evidencia terminal y límites

Si no sobrevive ninguna fila grave, el controlador realiza la verificación final y se
detiene. Al final ejecuta exactamente una verificación final y devuelve uno de dos
veredictos terminales:

```text
JUDGMENT: APPROVED
JUDGMENT: ESCALATED
```

El resultado debe incluir el objetivo, los ID de hallazgos congelados, las rondas de
corrección usadas, la evidencia de verificación final, la resolución de skill y el
veredicto terminal. No debe afirmar que la salida en prosa de un actor o un libro mayor en
prosa es autoridad.

Judgment Day es intencionalmente independiente de la entrega y de la seguridad de comandos
peligrosos. No realiza commits, pushes, creación de pull requests, publicaciones de
versiones, publicaciones ni cambios de versión. Si alguien quiere uno de esos efectos, es
una acción separada bajo la política normal del repositorio y los controles de permisos
aplicables de **Modos de permisos**.

## Errores comunes

- **Iniciarlo automáticamente después de cada cambio.** Necesita una solicitud explícita
  de la persona usuaria y un objetivo exacto.
- **Dejar que los jueces se coordinen antes del descubrimiento.** La ceguera es parte del
  mecanismo de independencia.
- **Pedirle a un juez que corrija código.** El descubrimiento es de solo lectura; solo un
  lote de corrección acotado y autorizado puede editar.
- **Reabrir el descubrimiento durante la nueva evaluación.** La nueva evaluación resuelve
  solo ID congelados proporcionados y regresiones de líneas de corrección.
- **Intentar una tercera ronda de corrección.** Quienes sobreviven a la segunda ronda
  escalan por diseño.
- **Tratar APPROVED como permiso para publicar.** Es evidencia de revisión, no autoridad
  para entregar.

## Probalo

Sin iniciar una revisión, inspeccioná el tamaño del cambio que estás considerando:

```text
git diff --stat
```

Indicá un objetivo de revisión exacto—por ejemplo, el candidato actual para una función
nombrada—y explicá por qué amerita una revisión dual ciega solicitada explícitamente.
Después ensayá el límite: dos jueces ciegos descubren; el controlador congela; un lote
acotado aprobado por una persona humana corrige; la nueva evaluación resuelve solo ID
congelados; y la política habitual del repositorio decide si algo se entrega.

En el proyecto integrador, podés combinar esto solo cuando su costo e independencia se
ajusten al cambio; es una herramienta deliberada, no un paso de finalización predeterminado.
