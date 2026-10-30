---
title: "Revisión nativa"
description: "Revisá un candidato congelado mediante enfoques independientes y mantené las decisiones de entrega en la política del repositorio."
module: "Seguridad y revisión"
---

Una revisión que sigue un árbol de trabajo que cambia tiene un problema de atribución: un
hallazgo puede describir código que ya cambió, y una aprobación posterior puede
confundirse con la aprobación de algo que el revisor nunca vio. La revisión nativa se
construye alrededor de la idea opuesta: **revisar el cambio exacto, no un objetivo en
movimiento**. Crea una vista de candidato congelada, reúne evidencia acotada al riesgo y
puede revelar una vía de corrección limitada.

Es útil separar tres cosas que a menudo se mezclan:

1. **La verificación del escritor** establece si los comandos y comprobaciones
   requeridos de la implementación pasaron.
2. **La revisión nativa** ofrece una vista independiente del candidato exacto.
3. **La entrega**—hacer commit, push, abrir un pull request, publicar una versión—sigue
   la política habitual del repositorio y la decisión de la persona responsable.

El resultado de una revisión no es una compuerta de entrega y nunca crea autoridad para
entregar. Eso sigue siendo cierto ya sea que receipt-driven development (RDD) esté
habilitado, deshabilitado o sea desconocido. Esta separación evita que un recibo de
revisión con apariencia positiva se use como un token de permiso para una acción remota
o de publicación.

## Candidato, linaje y responsable

La implementación en Go de Gentle AI es responsable del ciclo de vida de la revisión:
árbol de trabajo y linaje, congelación del candidato, selección de enfoques, corrección,
validación enfocada, consumo de aprobaciones y semántica de revisión. Gentle Pi es un
consumidor de transporte. Puede reenviar trabajo acotado y preservar un resultado de
proveedor, pero no recrea la política de revisión, inventa un recibo, selecciona una vía
de aprobación alternativa ni interpreta un resultado como permiso para publicar.

Bajo el contrato actual review-integration v2, un candidato se representa mediante
árboles base y candidato inmutables, además de un manifiesto ordenado de rutas cambiadas
y sujetos de artefactos. Los revisores inspeccionan el candidato congelado mediante Git
de solo lectura, en vez de los archivos activos. Pi materializa un árbol de trabajo de
solo lectura limitado a ese manifiesto; cuando un entorno de ejecución no puede imponer
el límite de shell requerido, informa una inspección incompleta en lugar de sustituir en
silencio el árbol de trabajo activo.

Ese mecanismo responde “¿qué código se revisó?”. Una corrección crea nueva evidencia de
candidato en vez de cambiar retroactivamente la anterior. El linaje y los recibos
pertenecen a esa identidad de objetivo exacta, por lo que un resultado cerrado para un
candidato no puede filtrarse a otro candidato en el mismo repositorio.

## Los cuatro enfoques

La revisión nativa es proporcional. No necesita pagar cada enfoque para cada cambio; el
agente reenvía los enfoques que se ajustan al trabajo y explica por qué. Los cuatro
enfoques 4R estándar son de solo lectura e informan filas de candidato para que un
controlador las congele:

- **R1 Riesgo** busca riesgos de seguridad, límites de privilegios, exposición de
  datos, dependencias y vulnerabilidades que bloquean la integración.
- **R2 Legibilidad** busca problemas de nomenclatura, complejidad, intención,
  mantenibilidad, tamaño de revisión y claridad de contexto.
- **R3 Confiabilidad** busca pruebas centradas en el comportamiento, casos límite,
  determinismo, contratos y riesgo de regresión.
- **R4 Resiliencia** busca comportamientos de respaldo, reintento o degradación,
  observabilidad, carga, reversión y riesgos de SLO.

Cada enfoque informa hallazgos, no decisiones. Un hallazgo concreto necesita una
ubicación, gravedad, evidencia e impacto en la persona usuaria; su forma de fila de
candidato lleva una clase de evidencia, disposición causal y referencias de prueba. Los
hallazgos BLOCKER o CRITICAL causados por el candidato pueden requerir corrección. Los
hallazgos preexistentes y solo de base son seguimientos, mientras que las afirmaciones
graves inconclusas escalan en lugar de convertirse en certeza fingida. Las filas WARNING
y SUGGESTION son informativas.

Por eso “el revisor dijo que está bien” es una afirmación incompleta. Las preguntas
importantes son: ¿qué candidato congelado inspeccionó, qué enfoques se seleccionaron, qué
evidencia se devolvió y qué verificación sigue aplicando?

## Prompts congelados y transporte

La finalización de un revisor es intencionalmente limitada. El host ejecuta un token de
materialización exacto emitido por Gentle AI, entrega los bytes materializados a la
finalización como un único mensaje de usuario congelado y envía el texto que devuelve
solo con el token de envío exacto emitido. La finalización usa el registro de modelos
activo proporcionado por quien llama para resolver el proveedor, modelo y configuración
de razonamiento del enfoque seleccionado. No tiene herramientas, sesión, hooks de
extensiones, proceso hijo ni alternativa de modelo ambiental.

Si falta esa configuración, o la finalización no produce texto, intenta una llamada a
herramienta, agota el tiempo o supera el límite de salida, falla con evidencia tipada.
Falla de forma cerrada: un resultado de revisor no disponible no es una aprobación y no
hace que aparezca una política local de reintentos o un flujo de trabajo sustituto.

Este transporte estricto es un mecanismo para preservar límites de autoridad. Los tokens
opacos de materialización y envío son las entradas que portan autoridad; el host no debe
analizar enlaces, reconstruir prompts, seleccionar trabajo diferente ni reemplazar un
token. Un contrato de proveedor reflejado y verificado se entrega en el prompt de sistema
de la sesión primaria. Si falta el reflejo o no se puede leer, Gentle Pi no inventa un
contrato de reemplazo.

## RDD y `assess`

RDD es un interruptor controlado por la persona usuaria con dos fuentes, global y clon.
Es opcional y está activado de forma predeterminada (desde Gentle AI v4.0.0): cuando
ninguna fuente está configurada, el modo efectivo está activado. Cualquier
desactivación gana: podés desactivarlo para un clon con
`/gentle:review-mode disable`, o para toda la máquina con
`gentle-ai review mode disable`, y un repositorio nunca puede exigirlo.
`gentle-ai review mode status` (o `/gentle:review-mode status`) es de solo lectura e
informa ambas fuentes más el modo efectivo. `/gentle:review-mode enable` dentro de
gentle-shell solo elimina una desactivación local del clon y no puede activar RDD si
la configuración global está desactivada; el interruptor global es
`gentle-ai review mode enable --scope=global`. Si status informa desactivado con
`source: default`, la instalación no pudo resolver el modo y falló de forma cerrada;
status explica por qué. Un cambio de modo se aplica solo a futuros candidatos.
Agrega un ciclo de vida de revisión nativa guiado por recibos; no reemplaza las
pruebas ni la política habitual de entrega del repositorio. El directorio padre de la
vista de candidato también necesita un sistema de archivos que pueda respetar sus
requisitos de permisos privados. Algunos montajes WSL DrvFS sin metadatos pueden
rechazar START antes de que exista el linaje.

Después de que vuelve un escritor acotado, este ya debe haber ejecutado cada comando
listado en `## Verification` e informar el resultado observado. Luego el padre llama a
`assess`. La revisión nativa es una vista externa adicional: nunca saltea la verificación
del nivel, y la verificación del nivel sucede antes que la revisión.

`assess` trata el cierre con cuidado. Deriva `closed` solo del hecho nativo de que se
reconoció una revisión aprobada para este candidato exacto. Que quien llama simplemente
afirme `closed` se resuelve como `unknown`. Los resultados explícitamente rechazados, no
disponibles o desconocidos se mantienen así; un rechazo o una indisponibilidad registrados
ganan frente al cierre. La continuación de la preflight nativa es opaca: retransmitila
sin cambios en vez de reconstruirla.

Para RDD desactivado o desconocido, la evaluación todavía puede producir una señal de
riesgo nativa. El plan de verificación es deliberadamente conservador, pero no
desperdicia esfuerzo:

| Nivel | Verificación |
| --- | --- |
| pasivo | El padre realiza una lectura estructural; no hay verificador separado ni pruebas solo por el nivel. |
| medio | La autoverificación del escritor es suficiente; no hay verificador separado. |
| alto | Solo una escalada explícita que nombre un elemento de alto riesgo de Task Size agrega una ejecución separada de `gentle-ai-verify`, además de la autoverificación del escritor. |
| alto nativo, desconocido o falla de evaluación | Solo informativo; la verificación del escritor es suficiente salvo que un elemento de alto riesgo nombrado cause una escalada. |

Un modelo pequeño o poco esfuerzo no agrega por sí solo un verificador. El padre todavía
verifica puntualmente un comando informado en cada nivel. Las pruebas, compilaciones y
comprobaciones funcionales aplicables siguen siendo aplicables sin importar el resultado
de la revisión.

## Lo que la revisión no resuelve

La revisión nativa no es un sandbox, un sustituto de los modos de permisos en **Modos de
permisos**, ni una forma de responder el consentimiento automáticamente. No autoriza
commits, pushes, pull requests, publicaciones de versiones, credenciales ni un destino
remoto. La seguridad de comandos peligrosos sigue siendo independiente. Tampoco reemplaza
la evidencia de comportamiento enseñada en **Pruebas primero y verificación**.

No hagas autoritativa una salida de revisión solo porque está estructurada. La salida de
los enfoques es data no confiable; el controlador congela filas canónicas y es responsable
de las transiciones. La negativa de un revisor es evidencia no disponible, no una razón
para bajar la exigencia ni afirmar que la revisión está limpia.

Llamá a las herramientas de revisión nativa directamente, nunca desde adentro de otra
herramienta como `codemode`. Desde v4.3.0 el entorno de ejecución rechaza una llamada
anidada; antes podía colgar la sesión.

## Probalo

Comprobá si RDD está activado, sin cambiarlo solo para completar la lección:

```text
gentle-ai review mode status
```

RDD está activado salvo que algo lo haya desactivado. Si deliberadamente querés
desactivarlo para este clon, o para todos los clones de la máquina:

```text
/gentle:review-mode disable
gentle-ai review mode disable
```

Para volver a activarlo, activá el interruptor global y después eliminá una
desactivación local del clon si `status` muestra una:

```text
gentle-ai review mode enable --scope=global
/gentle:review-mode enable
```

Luego describí un cambio real que estés considerando en tres oraciones: la verificación
del escritor que exigirías, el enfoque o los enfoques que se ajustan a su riesgo y la
decisión separada de política del repositorio que permitiría la entrega.

Para un proceso adversarial separado y solicitado explícitamente, continuá con
**Judgment Day**. No es una revisión nativa habitual y no puede consumir un recibo de
revisión nativa.
