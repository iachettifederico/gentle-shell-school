---
title: "Modos de permisos"
description: "Elegí Normal, Auto, YOLO o Super Yolo sin confundir la comodidad con un límite de seguridad."
module: "Seguridad y revisión"
---

Los avisos de permisos son un problema de coordinación: un agente de
programación puede realizar muchas acciones pequeñas mientras vos todavía
necesitás un control significativo sobre las que tienen consecuencias. Gentle
Shell ofrece cuatro formas de manejar esas preguntas en la sesión **principal**
actual: **Normal**, **Auto**, **YOLO** y **Super Yolo**. No son cuatro niveles de
seguridad y ninguno es un sandbox del sistema operativo. Los procesos, herramientas y
extensiones de Pi todavía actúan con los permisos de la cuenta que inició Pi.
El aislamiento, las credenciales limitadas y el acceso de red limitado siguen
siendo los controles que contienen una acción mala u hostil.

Esta lección trata sobre el camino de decisión de permisos. Sigue el límite
establecido en **Autorizar y explorar**: cambiar un modo no amplía la tarea que
autorizaste, no vuelve conocido un destino remoto ni decide una elección de
producto sin resolver.

## Los cuatro modos

**Normal** conserva el comportamiento de permisos existente y es el respaldo
cuando no hay una preferencia global guardada válida. Usalo cuando quieras tomar
decisiones individuales en el flujo normal de interacción.

**Auto** coloca una comprobación independiente delante de las llamadas a
herramientas principales elegibles. Esa comprobación usa el modelo de la sesión
actual y compara la acción propuesta con tu pedido y restricciones vigentes. No
hace que la conversación actuante se apruebe a sí misma. Auto cubre lecturas
locales además de escrituras, herramientas de shell, herramientas personalizadas
y MCP, y llamadas anidadas que pasan por la canalización de eventos de
herramientas de Pi. La localidad no es una exención: si dijiste que no se lea un
archivo, una lectura local sigue sujeta a esa restricción.

Auto tiene un costo. La inferencia independiente agrega latencia y, según el
proveedor, costo de tokens. Está deliberadamente acotada: las comprobaciones
comunes no usan herramientas; una comprobación de script elegible puede
inspeccionar solo archivos de proyecto seleccionados por el host, como máximo
dos archivos completos de hasta 8 KiB cada uno, a través de como máximo tres
llamadas al proveedor. La inspección reúne evidencia, nunca autoriza. Un
veredicto ausente, obsoleto, inválido, cancelado, agotado o no disponible no
ejecuta la acción. Acotá la acción propuesta, esperá y reintentá, o tomá una
decisión manual de permisos; no intentés disfrazar el mismo efecto mediante otra
herramienta o un delegado.

**YOLO** proporciona permiso permanente para trabajo común que ya está dentro
del alcance: implementación, verificaciones, commits comunes, pushes sin force
y creación de pull requests. Evita avisos rutinarios repetidos durante una
execución larga, autónoma pero acotada. YOLO no tiene clasificador Auto.

La palabra importante es *acotada*. YOLO no autoriza una cuenta, credencial,
destino remoto, destino de despliegue, divulgación sensible para la privacidad o
una decisión con consecuencias que la tarea deja abierta. Tampoco les da a los
hijos delegados su permiso elevado ni permiso de entrega independiente.

**Super Yolo** es autonomía máxima deliberada para un espacio de trabajo cuyas
consecuencias aceptás. Elimina todos los avisos de permisos, incluso las
confirmaciones de pérdida de datos y las reglas configuradas de guardarraíles
`confirm` y `block`: `rm` recursivo, drops SQL, rebases, borrado forzado de ramas
y `npm publish` se ejecutan sin diálogo. El clasificador Auto no se ejecuta.
Quedan dos líneas. La guarda de rutas sensibles sigue bloqueada de forma estricta:
leer, escribir o editar archivos `.env`, `.ssh`, keychains, archivos
`*.pem`/`*.key`/`*.p12`/`*.pfx`, directorios `secrets/` y archivos de credenciales
de nube se rechaza en todos los modos. Las denegaciones catastróficas a nivel de
código también permanecen: `rm -rf /`, `rm -rf ~`, `--no-preserve-root`,
`git reset --hard`, forced clean y force push se bloquean sin diálogo. Las
herramientas de preguntas a usuarios, el consentimiento de proveedores y las
decisiones de tokens opacos nunca se responden automáticamente, y los hijos nunca
heredan Super Yolo.

## Cambiá el modo activo deliberadamente

Usá los comandos de modo en una sesión principal interactiva:

```text
/gentle:mode status
/gentle:mode auto
/gentle:mode normal
/gentle:mode yolo
/gentle:mode super-yolo
```

El primer comando es una comprobación útil sin cambios: muestra el modo actual
y el valor predeterminado guardado. Los comandos de selección de modo afectan
exactamente a la sesión principal interactiva actual. También podés usar el
atajo YOLO más antiguo:

```text
/gentle:yolo enable
/gentle:yolo disable
/gentle:yolo status
```

`enable` selecciona YOLO para la sesión activa; `disable` selecciona Normal.
Sin argumento, `/gentle:yolo` abre su menú interactivo cuando esa UI está
disponible, o informa el estado en caso contrario. Los argumentos inválidos no
cambian nada. El interruptor muestra **ON** mientras Super Yolo está activo, y
apagarlo vuelve a Normal.

La interfaz Customize expone la misma distinción. En
`/gentle:customize` → **Editor**, **Session permissions** cambia el modo actual,
mientras que **Default permissions** guarda una preferencia para sesiones
futuras. La fila YOLO es explícitamente solo de sesión. Explorar, previsualizar,
cerrar un menú o presionar Escape nunca otorga permiso.

Para guardar un valor predeterminado para una sesión principal *nueva*, usá un
comando separado:

```text
/gentle:mode default auto
/gentle:mode default yolo
/gentle:mode default super-yolo
/gentle:mode default normal
```

Esta es una fuente común de errores: `/gentle:mode default auto` no cambia la
sesión actual, y `/gentle:mode normal` no elimina un valor predeterminado
guardado para sesiones futuras. Para devolver tanto esta sesión como las
sesiones futuras a Normal, ejecutá `/gentle:mode normal` y
`/gentle:mode default normal`. La selección de la sesión actual tiene prioridad
sobre el valor predeterminado global. La configuración del repositorio y los
perfiles visuales no pueden proporcionar ese valor predeterminado.

Los permisos activos están vinculados a la identidad de la sesión y del espacio
de trabajo o clon. Recargar, apagar o reemplazar la sesión revoca la selección
activa y las acciones pendientes. Una sesión recién inicializada puede aplicar
un valor predeterminado guardado, pero eso es una nueva aplicación de una
preferencia global, no la restauración de una concesión de una transcripción
anterior.

## Los límites que permanecen

Auto y YOLO reducen las preguntas rutinarias repetidas; no eliminan las guardas
independientes. Super Yolo va más lejos y es la excepción descripta arriba: solo
permanecen la guarda de rutas sensibles y las denegaciones catastróficas a nivel
de código. Las denegaciones estrictas existentes, las restricciones configuradas,
las rutas sensibles y las restricciones explícitas de la persona usuaria siguen
aplicándose. Las herramientas de preguntas a usuarios, las
elecciones de tokens opacos, el consentimiento de mantenimiento o recuperación,
el control de delegación y el consentimiento de revisión nativa conservan sus
propios contratos. Ningún modo descubre credenciales de ambiente ni elige por
vos un destino remoto desconocido.

Las operaciones destructivas reconocidas merecen especial atención. YOLO
conserva una confirmación nueva o una denegación estricta para eliminación
amplia, acciones destructivas de base de datos y operaciones de Git protegidas.
Un force push, hard reset o forced clean queda bloqueado de forma estricta. Los
hijos delegados propiedad del paquete bloquean las operaciones destructivas
reconocidas en vez de pedir confirmación. Hay una excepción estrechamente
definida para eliminación recursiva del scratch temporal propio de una sesión
bajo YOLO activo; no es un permiso general para eliminar rutas que parecen
temporales.

Auto también conserva estas guardas. Un veredicto de permitir solo devuelve el
control al ejecutor original y a las salvaguardas restantes. Las definiciones de
herramientas y las descripciones de plugins proporcionadas como contexto son
descripciones no confiables; el nombre de una herramienta no otorga permiso ni
prueba que su implementación sea segura.

## Por qué la guarda no es contención

Auto solo puede clasificar la acción y el contexto acotado que recibe. Su
ventana de mensajes activa es limitada; repetí una restricción que deba
mantenerse durante una sesión larga. La inspección de scripts no ejecuta el
script ni recorre sus dependencias. El reconocimiento usado para comandos de
shell destructivos es léxico, no una evaluación de shell ni SQL. Los scripts,
las herramientas personalizadas, la inyección de prompts y las formas de
comandos no reconocidas pueden evadir una comprensión semántica de las
consecuencias.

Por lo tanto, la guía de seguridad de Pi recomienda un diseño más fuerte cuando
el impacto importa: ejecutalo en un contenedor, VM o sandbox; exponé solo los
archivos y servicios requeridos; usá credenciales de alcance estrecho y corta
vida; y restringí el acceso de red cuando no sea necesario. Los controles de
confianza del proyecto controlan la carga al inicio de recursos del proyecto,
pero tampoco son un límite sobre lo que las herramientas habilitadas pueden
acceder después del inicio.

## Errores comunes

- **Tratar YOLO como autonomía ilimitada.** Es permiso permanente para trabajo
  común *ya autorizado*, no una ampliación del alcance.
- **Elegir Super Yolo por comodidad.** Renuncia a las confirmaciones de pérdida
  de datos; usalo solo en un espacio de trabajo donde aceptes esas consecuencias,
  idealmente uno aislado.
- **Tratar una denegación de Auto como veredicto sobre la tarea.** Un timeout o
  clasificador no disponible significa que la acción no se ejecutó, no que sea
  insegura.
- **Guardar un valor predeterminado por accidente.** Los comandos de sesión y
  predeterminados son separados.
- **Suponer que los hijos heredan el modo padre.** Conservan un alcance delegado
  acotado y sus propios caminos de seguridad.
- **Usar los modos como aislamiento.** Usá límites del sistema operativo o de
  virtualización y credenciales restringidas para contención.

## Probalo

En una sesión principal interactiva, ejecutá:

```text
/gentle:mode status
```

Leé ambos campos antes de cambiar nada: el modo activo te indica cómo esta
sesión manejará las acciones elegibles, mientras que el valor predeterminado
guardado afecta las sesiones principales futuras. Para una tarea rutinaria y
estrechamente acotada, explicá cuál de Normal, Auto, YOLO o Super Yolo elegirías y
nombrá la decisión que todavía requeriría de vos.

A continuación, **Revisión nativa** explica un tipo diferente de control:
evidencia sobre un candidato de código congelado. No concede permiso para
entregar ese candidato.
