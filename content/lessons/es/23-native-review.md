---
title: "Revisión nativa"
description: "Revisa un candidato congelado mediante perspectivas independientes mientras mantienes las decisiones de entrega en la política del repositorio."
module: "Seguridad y revisión"
---

Una revisión que sigue un árbol de trabajo cambiante tiene un problema de atribución: un hallazgo puede describir
código que ya cambió, y una aprobación posterior puede confundirse con la aprobación de algo que el revisor nunca
vio. La revisión nativa se basa en la idea opuesta: **revisa el cambio exacto, no un objetivo móvil**. Crea una vista
de candidato congelada, recopila evidencia acotada al riesgo y puede mostrar una ruta de corrección limitada.

Es útil separar tres cosas que a menudo se confunden:

1. **La verificación del escritor** establece si se aprobaron los comandos y comprobaciones requeridos de la
   implementación.
2. **La revisión nativa** proporciona una vista independiente del candidato exacto.
3. **La entrega**—hacer commit, push, abrir un pull request, lanzar una versión—sigue la política ordinaria del
   repositorio y la decisión de la persona responsable.

El resultado de una revisión no es una puerta de entrega y nunca crea autoridad de entrega. Esto sigue siendo cierto
si receipt-driven development (RDD) está habilitado, deshabilitado o es desconocido. Esta separación evita que un
recibo de revisión con apariencia positiva se use como token de permiso para una acción remota o de publicación.

## Candidato, linaje y propietario

La implementación en Go de Gentle AI posee el ciclo de vida de la revisión: árbol de trabajo y linaje, congelación
del candidato, selección de perspectivas, corrección, validación dirigida, consumo de aprobación y semántica de
revisión. Gentle Pi es un consumidor de transporte. Puede reenviar trabajo acotado y conservar un resultado del
proveedor, pero no recrea la política de revisión, inventa un recibo, selecciona una ruta de aprobación alternativa
ni interpreta un resultado como permiso para enviar.

Bajo el contrato actual de review-integration v2, un candidato se representa mediante árboles base y de candidato
inmutables más un manifiesto ordenado de rutas modificadas y sujetos de artefactos. Los revisores inspeccionan el
candidato congelado mediante Git de solo lectura en lugar de los archivos activos. Pi materializa un árbol de trabajo
de solo lectura limitado a ese manifiesto; cuando un entorno de ejecución no puede imponer el límite de shell
requerido, informa una inspección incompleta en lugar de sustituir silenciosamente el árbol de trabajo activo.

Ese mecanismo responde “¿qué código se revisó?”. Una corrección crea nueva evidencia de candidato en lugar de
cambiar retroactivamente el candidato anterior. El linaje y los recibos pertenecen a esa identidad de objetivo exacta,
así que un resultado cerrado para un candidato no puede filtrarse a otro candidato del mismo repositorio.

## Las cuatro perspectivas

La revisión nativa es proporcional. No necesita pagar por cada perspectiva en cada cambio; el agente reenvía las
perspectivas que se ajustan al trabajo y explica por qué. Las cuatro perspectivas estándar 4R son de solo lectura e
informan filas de candidato para que un controlador las congele:

- **R1 Riesgo** busca riesgos de seguridad, límites de privilegios, exposición de datos, dependencias y
  vulnerabilidades que bloquean integraciones.
- **R2 Legibilidad** busca problemas de nombres, complejidad, intención, mantenibilidad, tamaño de revisión y
  claridad del contexto.
- **R3 Confiabilidad** busca pruebas que priorizan el comportamiento, casos límite, determinismo, contratos y riesgo
  de regresión.
- **R4 Resiliencia** busca alternativas, comportamiento de reintento o degradación, observabilidad, carga, rollback y
  riesgos de SLO.

Cada perspectiva informa hallazgos, no decisiones. Un hallazgo concreto necesita una ubicación, gravedad, evidencia
e impacto en el usuario; su forma de fila de candidato lleva una clase de evidencia, disposición causal y referencias
de prueba. Los hallazgos BLOCKER o CRITICAL causados por el candidato pueden requerir corrección. Los hallazgos
preexistentes y solo de base son seguimientos, mientras que las afirmaciones graves no concluyentes escalan en lugar
de convertirse en certeza fingida. Las filas WARNING y SUGGESTION son informativas.

Por eso, “el revisor dijo que está bien” es una afirmación incompleta. Las preguntas importantes son: ¿qué candidato
congelado inspeccionó, qué perspectivas se seleccionaron, qué evidencia se devolvió y qué verificación aún se aplica?

## Prompts congelados y transporte

La finalización de un revisor es deliberadamente limitada. El host ejecuta un token de materialización exacto emitido
por Gentle AI, entrega los bytes materializados a la finalización como un mensaje de usuario congelado y envía su
texto devuelto solo con el token de envío exacto emitido. La finalización usa el registro de modelos activos
proporcionado por quien llama para resolver el proveedor, modelo y configuración de razonamiento de la perspectiva
seleccionada. No tiene herramientas, sesión, hooks de extensión, proceso hijo ni alternativa de modelo ambiental.

Si falta esa configuración, o la finalización no produce texto, intenta una llamada a herramienta, agota el tiempo o
supera el límite de salida, falla con evidencia tipada. Falla de forma cerrada: el resultado de un revisor no
disponible no es una aprobación y no hace que aparezcan una política local de reintento o un flujo de trabajo
sustituto.

Este transporte estricto es un mecanismo para preservar límites de autoridad. Los tokens opacos de materialización y
envío son las entradas que llevan autoridad; el host no debe analizar enlaces, reconstruir prompts, seleccionar
trabajo distinto ni reemplazar un token. Un contrato de proveedor reflejado y verificado se entrega en el prompt de
sistema de la sesión principal. Si el reflejo está ausente o no se puede leer, Gentle Pi no inventa un contrato de
reemplazo.

## RDD y `assess`

RDD es un interruptor propiedad del usuario con dos fuentes, global y clon. Es opcional y está activado de forma
predeterminada (desde Gentle AI v4.0.0): cuando ninguna fuente está establecida, el modo efectivo está activado.
Cualquier desactivación prevalece: puedes desactivarlo para un clon con `/gentle:review-mode disable` o para toda la
máquina con `gentle-ai review mode disable`, y un repositorio nunca puede exigirlo. `gentle-ai review mode status`
(o `/gentle:review-mode status`) es de solo lectura e informa ambas fuentes junto con el modo efectivo.
`/gentle:review-mode enable` dentro de gentle-shell solo elimina una desactivación local del clon y no puede activar
RDD mientras la configuración global está desactivada; el interruptor global es
`gentle-ai review mode enable --scope=global`. Si status informa desactivado con `source: default`, la instalación no
pudo resolver el modo y falló de forma cerrada; status explica por qué. Un cambio de modo se aplica solo a candidatos
futuros. Agrega un ciclo de vida de revisión nativa basado en recibos; no reemplaza las pruebas ni la política
ordinaria de entrega del repositorio. El directorio padre de la vista de candidato también necesita un sistema de
archivos que pueda respetar sus requisitos de permisos privados. Algunos montajes WSL DrvFS sin metadatos pueden
rechazar START antes de que exista el linaje.

Después de que un escritor acotado regresa, el escritor ya debe haber ejecutado cada comando listado en
`## Verification` e informar el resultado observado. El progenitor luego llama a `assess`. La revisión nativa es una
vista externa adicional: nunca omite la verificación del nivel, y la verificación del nivel ocurre antes de la
revisión.

`assess` trata el cierre con cuidado. Deriva `closed` solo del hecho nativo de que se reconoció una revisión aprobada
para este candidato exacto. Que quien llama simplemente afirme `closed` se resuelve como `unknown`. Los resultados
explícitamente rechazados, no disponibles o desconocidos permanecen como tales; un rechazo o indisponibilidad
registrados prevalecen sobre el cierre. La continuación de preflight nativo es opaca: retransmítela sin cambios en
lugar de reconstruirla.

Para RDD desactivado o desconocido, la evaluación aún puede producir una señal de riesgo nativa. El plan de
verificación es deliberadamente conservador pero no desperdicia recursos:

| Nivel | Verificación |
| --- | --- |
| pasivo | El progenitor realiza una lectura estructural; no hay verificador ni pruebas separados solo por el nivel. |
| medio | La autoverificación del escritor es suficiente; no hay verificador separado. |
| alto | Solo una escalación explícita que nombre un elemento de alto riesgo de Task Size agrega una ejecución separada de `gentle-ai-verify`, además de la autoverificación del escritor. |
| alto nativo, desconocido o fallo de evaluación | Solo informativo; la verificación del escritor es suficiente salvo que un elemento de alto riesgo nombrado cause una escalación. |

Un modelo pequeño o poco esfuerzo no agrega por sí mismo un verificador. El progenitor aún verifica puntualmente un
comando informado en cada nivel. Las pruebas, compilaciones y comprobaciones funcionales aplicables siguen siendo
aplicables sin importar el resultado de la revisión.

## Lo que la revisión no resuelve

La revisión nativa no es un sandbox, un sustituto de los modos de permisos en **Modos de permisos**, ni una forma de
responder automáticamente el consentimiento. No autoriza commits, pushes, pull requests, lanzamientos, credenciales
ni un destino remoto. La seguridad de los comandos peligrosos sigue siendo independiente. Tampoco reemplaza la
evidencia de comportamiento enseñada en **Pruebas primero y verificación**.

No hagas autoritativa una salida de revisión solo porque está estructurada. La salida de las perspectivas es dato no
confiable; el controlador congela las filas canónicas y posee las transiciones. La negativa de un revisor es evidencia
no disponible, no una razón para bajar el estándar o afirmar una revisión limpia.

Llama a las herramientas de revisión nativa directamente, nunca desde dentro de otra herramienta como
`codemode`. Desde v4.3.0 el entorno de ejecución rechaza una llamada anidada; antes podía colgar la sesión.

## Pruébalo

Comprueba si RDD está activado, sin cambiarlo solo para completar la lección:

```text
gentle-ai review mode status
```

RDD está activado salvo que algo lo haya desactivado. Si deliberadamente quieres desactivarlo para este clon o para
todos los clones de la máquina:

```text
/gentle:review-mode disable
gentle-ai review mode disable
```

Para volver a activarlo, activa el interruptor global y luego elimina una desactivación local del clon si `status`
muestra una:

```text
gentle-ai review mode enable --scope=global
/gentle:review-mode enable
```

Luego describe un cambio real que estés considerando en tres oraciones: la verificación del escritor que exigirías,
la perspectiva o perspectivas que se ajusten a su riesgo y la decisión separada de política del repositorio que
permitiría la entrega.

Para un proceso adversarial separado y solicitado explícitamente, continúa con **Día del juicio**. No es una revisión
nativa ordinaria y no puede consumir un recibo de revisión nativa.
