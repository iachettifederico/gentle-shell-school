---
title: "Día del juicio"
description: "Usa una revisión adversarial dual ciega y limitada sin convertir la salida del revisor en autoridad de entrega."
module: "Seguridad y revisión"
---

Algunos cambios merecen una segunda mirada deliberadamente adversarial. El peligro es convertir ese deseo en una
multitud interminable de revisores, afirmaciones mutables y conclusiones vagas de “se ve bien”. **Judgment Day** es la
respuesta limitada de Gentle AI: una revisión dual independiente solicitada explícitamente, con un objetivo fijo, dos
jueces ciegos, hallazgos congelados, como máximo dos rondas de corrección y un juicio terminal.

Es independiente del flujo de trabajo de **Revisión nativa**. Judgment Day no habilita, reemplaza, inicia, configura
ni consume una revisión ordinaria para un linaje. Una revisión ordinaria solicitada por separado permanece
independiente. Ninguno de los procesos autoriza la entrega: el commit, push, pull request, lanzamiento y publicación
siguen siendo decisiones ordinarias de política del repositorio.

## Inicia solo con una solicitud explícita

Judgment Day no es un ritual de calidad en segundo plano. Solo comienza cuando un usuario solicita explícitamente
“Judgment Day”, “Judgement Day”, revisión dual, revisión adversarial o una solicitud equivalente. Antes de que se
ejecuten actores, el controlador resuelve un objetivo exacto, toma una instantánea del alcance completo y vincula el
árbol de revisión inicial.

Esa regla de activación protege tanto el costo como el significado. Sin un objetivo exacto, dos jueces pueden revisar
versiones o alcances diferentes. Sin una solicitud explícita, un agente servicial podría crear un proceso paralelo
costoso que el usuario no pidió. El objetivo no es más comentarios; es evidencia creíble, vinculada al candidato,
para un cambio importante.

## Descubrimiento inicial: dos barridos independientes

Judgment Day comienza con **exactamente dos jueces ciegos**—juez A y juez B—y **cero refutadores**. Se ejecutan de
forma concurrente con criterios de objetivo idénticos, pero no se coordinan ni dependen de las conclusiones del otro.
Ambos son de solo lectura.

El presupuesto normal de descubrimiento es un barrido exhaustivo de solo lectura por juez. Un objetivo a escala 4R
completa—como una ruta activa de autenticación, actualización, seguridad o pagos, o un cambio de más de 400 líneas—
puede usar como máximo dos barridos por juez. No hay un ciclo de “seguir buscando hasta que no haya nada”. Un barrido
limitado hace visible el costo de la revisión e impide que la fase de descubrimiento se convierta en una investigación
sin límites.

Durante el descubrimiento inicial, los jueces se ejecutan exactamente una vez contra el `initial_review_tree`
suministrado. No persisten estado, mutan afirmaciones, lanzan otros actores, solicitan correcciones, validan
correcciones ni entregan nada. Devuelven solo filas de candidato. Un candidato útil es concreto: tiene un
identificador estable, ubicación exacta, gravedad, clase de evidencia y una afirmación de evidencia que describe el
impacto en el usuario. Una revisión limpia es una lista de candidatos vacía, no un informe omitido.

El enfoque de los jueces difiere lo suficiente para reducir puntos ciegos correlacionados. El juez A enfatiza la
corrección, regresiones, pruebas faltantes, comportamiento inseguro y una falta de coincidencia con la solicitud. El
juez B cuestiona las suposiciones con énfasis en casos límite, riesgos de integración, brechas de pruebas y regresiones
visibles para el usuario. Su salida sigue siendo dato no confiable: no puede autorizar transiciones, correcciones,
recibos, puertas ni entrega.

## Congela las afirmaciones antes de corregir

El controlador canoniza y congela las filas de candidato después de que ambos jueces regresan. Ese es un mecanismo
clave. Una corrección posterior no puede reescribir silenciosamente la afirmación que supuestamente aborda, y el
nuevo juicio puede limitarse a un conjunto conocido de ID y a un diff conocido.

La gravedad importa. Los candidatos WARNING y SUGGESTION son filas informativas de una sola vez y nunca programan
correcciones. Para las filas graves que permanecen, el controlador solicita aprobación humana cuando se requiere y
luego autoriza un lote de corrección *acotado*. La persona y el controlador poseen esa autorización; un juez no puede
promover su propio hallazgo a una instrucción de edición.

El agente de corrección es deliberadamente quirúrgico. Su despacho contiene la declaración de activación explícita de
Judgment Day, los ID graves exactos autorizados, un número de ronda (`1 of 2` o `2 of 2`), un SHA-256 del registro
congelado, las filas congeladas exactas y las superficies de edición permitidas. Corrige solo esos ID proporcionados,
conserva la intención original del diseño, agrega pruebas enfocadas cuando cambia el comportamiento y devuelve
evidencia del árbol de candidato y del diff de corrección. No agrega hallazgos, altera afirmaciones congeladas,
entrega, publica ni inicia otro actor.

Este es un patrón útil más allá de Judgment Day: limita a un editor mediante el problema, candidato y superficie de
edición específicos en vez de darle una instrucción abierta como “haz feliz a la revisión”.

## Nuevo juicio acotado, no una nueva pasada de descubrimiento

Después del lote, el nuevo juicio recibe solo los ID congelados solicitados, sus filas exactas vinculadas por hash y
el diff de corrección. Los jueces resuelven solo esos ID y regresiones en las líneas de corrección. No pueden agregar
hallazgos nuevos, cambiar afirmaciones congeladas, solicitar otra corrección, lanzar actores, conservar autoridad ni
repetir su barrido.

Para cada ID proporcionado, la resolución es una de estas:

- **verified** — la preocupación proporcionada se verifica como resuelta;
- **corroborated** — la preocupación proporcionada sigue respaldada; o
- **regression** — las líneas de corrección introducen una regresión relevante para el alcance proporcionado.

Esta distinción mantiene honesto el nuevo juicio. No es una oportunidad de ampliar el alcance ni de transformar una
comprobación de corrección en otra auditoría completa.

Judgment Day puede usar como máximo dos rondas de corrección/nuevo juicio. Si las filas graves sobreviven la segunda
ronda, **escalan**. No existe transición a una tercera ronda. La escalación es un resultado veraz: indica que el
proceso limitado no resolvió esos riesgos, por lo que una persona debe decidir la siguiente ruta en lugar de consumir
más ciclos de revisión no planificados.

## Evidencia terminal y límites

Si no sobreviven filas graves, el controlador realiza la verificación final y se detiene. Al final ejecuta exactamente
una verificación final y devuelve uno de dos juicios terminales:

```text
JUDGMENT: APPROVED
JUDGMENT: ESCALATED
```

El resultado debe incluir el objetivo, los ID de hallazgos congelados, las rondas de corrección usadas, la evidencia
de verificación final, la resolución de habilidades y el juicio terminal. No debe afirmar que la salida en prosa de un
actor o un registro en prosa sea autoridad.

Judgment Day es deliberadamente independiente de la entrega y de la seguridad de comandos peligrosos. No realiza
ningún commit, push, creación de pull request, lanzamiento, publicación ni cambio de versión. Si alguien desea uno de
esos efectos, es una acción separada bajo la política normal del repositorio y los controles de permisos aplicables de
**Modos de permisos**.

## Errores comunes

- **Iniciarlo automáticamente después de cada cambio.** Necesita una solicitud explícita del usuario y un objetivo
  exacto.
- **Permitir que los jueces se coordinen antes del descubrimiento.** La ceguera es parte del mecanismo de
  independencia.
- **Pedir a un juez que corrija código.** El descubrimiento es de solo lectura; solo un lote de corrección acotado y
  autorizado puede editar.
- **Reabrir el descubrimiento durante el nuevo juicio.** El nuevo juicio resuelve solo los ID congelados suministrados
  y las regresiones de las líneas de corrección.
- **Intentar una tercera ronda de corrección.** Quienes sobreviven la segunda ronda escalan por diseño.
- **Tratar APPROVED como permiso de envío.** Es evidencia de revisión, no autoridad para entregar.

## Pruébalo

Sin iniciar una revisión, inspecciona el tamaño del cambio que estás considerando:

```text
git diff --stat
```

Indica un objetivo de revisión exacto—por ejemplo, el candidato actual para una funcionalidad nombrada—y explica por
qué justifica una revisión dual ciega solicitada explícitamente. Luego ensaya el límite: dos jueces ciegos descubren;
el controlador congela; un lote acotado aprobado por una persona corrige; el nuevo juicio resuelve solo los ID
congelados; y la política ordinaria del repositorio decide si algo se entrega.

En el proyecto final, puedes combinar esto solo cuando su costo e independencia se ajusten al cambio; es una
herramienta deliberada, no un paso final predeterminado.
