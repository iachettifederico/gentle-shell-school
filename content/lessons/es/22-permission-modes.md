---
title: "Modos de permisos"
description: "Elige Normal, Auto o YOLO sin confundir la conveniencia con un límite de seguridad."
module: "Seguridad y revisión"
---

Las solicitudes de permiso son un problema de coordinación: un agente de programación puede realizar muchas
acciones pequeñas mientras tú aún necesitas un control significativo sobre las importantes. Gentle Shell ofrece tres
formas de gestionar esas preguntas en la sesión **principal** actual: **Normal**, **Auto** y **YOLO**. No son tres
niveles de seguridad y ninguna es un sandbox del sistema operativo. Los procesos, herramientas y extensiones de Pi
siguen actuando con los permisos de la cuenta que inició Pi. El aislamiento, las credenciales limitadas y el acceso a
la red limitado siguen siendo los controles que contienen una acción dañina u hostil.

Esta lección trata sobre la ruta de decisión de permisos. Sigue el límite establecido en **Autoriza y explora**:
cambiar un modo no amplía la tarea que autorizaste, no hace conocido un destino remoto ni decide una elección de
producto sin resolver.

## Los tres modos

**Normal** conserva el comportamiento de permisos existente y es la alternativa cuando no hay una preferencia
global guardada válida. Úsalo cuando quieras tomar decisiones individuales en el flujo de interacción normal.

**Auto** coloca una comprobación independiente delante de las llamadas elegibles a herramientas principales. Esa
comprobación usa el modelo de la sesión actual y compara la acción propuesta con tu solicitud y restricciones
actuales. No hace que la conversación que actúa se apruebe a sí misma. Auto cubre lecturas locales, así como
escrituras, herramientas de shell, herramientas personalizadas y MCP, y llamadas anidadas que pasan por la
canalización de eventos de herramientas de Pi. La localidad no es una exención: si dijiste que no se leyera un
archivo, una lectura local sigue sujeta a esa restricción.

Auto tiene un costo. La inferencia independiente agrega latencia y, según el proveedor, costo de tokens. Está
limitada deliberadamente: las comprobaciones ordinarias no usan herramientas; una comprobación de script elegible
puede inspeccionar solo archivos del proyecto seleccionados por el host, como máximo dos archivos completos de hasta
8 KiB cada uno, en un máximo de tres llamadas al proveedor. La inspección recopila evidencia, nunca autoriza. Un
veredicto ausente, desactualizado, no válido, cancelado, agotado por tiempo o no disponible no ejecuta la acción.
Acota la acción propuesta, espera y vuelve a intentarlo, o toma una decisión manual de permiso; no intentes
disimular el mismo efecto mediante otra herramienta o un delegado.

**YOLO** proporciona permiso permanente para el trabajo ordinario que ya está dentro del alcance: implementación,
comprobaciones, commits ordinarios, pushes sin force y creación de pull requests. Evita solicitudes rutinarias
repetidas durante una ejecución larga, autónoma pero acotada. YOLO no tiene clasificador Auto.

La palabra importante es *acotado*. YOLO no autoriza una cuenta nueva, credencial, destino remoto, destino de
despliegue, divulgación sensible para la privacidad ni una decisión importante que la tarea deje abierta. Tampoco
otorga a los hijos delegados su permiso elevado ni permiso de entrega independiente.

## Cambia el modo activo deliberadamente

Usa los comandos de modo en una sesión principal interactiva:

```text
/gentle:mode status
/gentle:mode auto
/gentle:mode normal
/gentle:mode yolo
```

El primer comando es una comprobación útil sin cambios: muestra el modo actual y el valor predeterminado guardado.
Los comandos de selección de modo afectan exactamente a la sesión principal interactiva actual. También puedes usar
el atajo antiguo de YOLO:

```text
/gentle:yolo enable
/gentle:yolo disable
/gentle:yolo status
```

`enable` selecciona YOLO para la sesión activa; `disable` selecciona Normal. Sin argumentos, `/gentle:yolo` abre
su menú interactivo cuando esa interfaz está disponible, o informa el estado de lo contrario. Los argumentos no
válidos no cambian nada.

La interfaz Customize expone la misma distinción. En
`/gentle:customize` → **Editor**, **Session permissions** cambia el modo actual, mientras que **Default permissions**
guarda una preferencia para sesiones futuras. La fila de YOLO es explícitamente solo para la sesión. Explorar,
previsualizar, cerrar un menú o presionar Escape nunca concede permiso.

Para guardar un valor predeterminado para una sesión principal *nueva*, usa un comando separado:

```text
/gentle:mode default auto
/gentle:mode default yolo
/gentle:mode default normal
```

Esta es una fuente común de errores: `/gentle:mode default auto` no cambia la sesión actual, y
`/gentle:mode normal` no borra un valor predeterminado guardado para sesiones futuras. Para devolver tanto esta
sesión como las sesiones futuras a Normal, ejecuta `/gentle:mode normal` y `/gentle:mode default normal`.
La selección de la sesión actual tiene precedencia sobre el valor predeterminado global. La configuración del
repositorio y los perfiles visuales no pueden proporcionar ese valor predeterminado.

Los permisos activos están vinculados a la identidad de la sesión y del espacio de trabajo o clon. Recargar, cerrar
o reemplazar la sesión revoca la selección activa y las acciones pendientes. Una sesión recién inicializada puede
aplicar un valor predeterminado guardado, pero eso es una nueva aplicación de una preferencia global, no la
restauración de una concesión de una transcripción anterior.

## Los límites que permanecen

Auto y YOLO reducen las preguntas rutinarias repetidas; no eliminan las protecciones independientes. Las denegaciones
estrictas existentes, las restricciones configuradas, las rutas sensibles y las limitaciones explícitas del usuario
siguen aplicándose. Las herramientas de preguntas al usuario, las opciones de token opaco, el consentimiento de
mantenimiento o recuperación, el control de delegación y el consentimiento de revisión nativa conservan sus propios
contratos. Ninguno de los modos descubre credenciales ambientales ni elige por ti un destino remoto desconocido.

Las operaciones destructivas reconocidas merecen atención especial. YOLO conserva la confirmación nueva o la
denegación estricta para eliminación amplia, acciones destructivas de base de datos y operaciones de Git protegidas.
Un force push, hard reset o forced clean se bloquea estrictamente. Los hijos delegados propiedad del paquete bloquean
las operaciones destructivas reconocidas en lugar de solicitar confirmación. Hay una excepción estrictamente definida
para la eliminación recursiva del espacio temporal propio de una sesión bajo YOLO activo; no es un permiso general
para eliminar rutas que parezcan temporales.

Auto también conserva estas protecciones. Un veredicto de permitir simplemente devuelve el control al ejecutor
original y a las protecciones restantes. Las definiciones de herramientas y las descripciones de plugins proporcionadas
como contexto son descripciones no confiables; el nombre de una herramienta no otorga permiso ni demuestra que su
implementación sea segura.

## Por qué la protección no es contención

Auto solo puede clasificar la acción y el contexto limitado que recibe. Su ventana de mensajes activos es limitada;
vuelve a expresar una restricción que deba mantenerse durante una sesión larga. La inspección de scripts no ejecuta
el script ni recorre sus dependencias. El reconocimiento usado para comandos destructivos de shell es léxico, no una
evaluación de shell o SQL. Los scripts, las herramientas personalizadas, la inyección de prompts y las formas de
comando no reconocidas pueden evadir una comprensión semántica de las consecuencias.

Por eso, la guía de seguridad de Pi recomienda un diseño más fuerte cuando el impacto importa: ejecútalo en un
contenedor, VM o sandbox; expón solo los archivos y servicios necesarios; usa credenciales de alcance limitado y
vida corta; y restringe el acceso a la red cuando sea innecesario. Los controles de confianza del proyecto controlan
la carga de recursos del proyecto al inicio, pero tampoco son un límite a lo que las herramientas habilitadas pueden
acceder después del inicio.

## Errores comunes

- **Tratar YOLO como autonomía ilimitada.** Es permiso permanente para trabajo ordinario *ya autorizado*, no una
  ampliación de alcance.
- **Tratar una denegación de Auto como un veredicto sobre la tarea.** Un timeout o un clasificador no disponible
  significa que la acción no se ejecutó, no que sea insegura.
- **Guardar un valor predeterminado por accidente.** Los comandos de sesión y predeterminados son distintos.
- **Suponer que los hijos heredan el modo del progenitor.** Conservan el alcance delegado acotado y sus propias rutas
  de seguridad.
- **Usar modos como aislamiento.** Usa límites del sistema operativo o virtualización y credenciales restringidas para
  la contención.

## Pruébalo

En una sesión principal interactiva, ejecuta:

```text
/gentle:mode status
```

Lee ambos campos antes de cambiar algo: el modo activo indica cómo esta sesión gestionará las acciones elegibles,
mientras que el valor predeterminado guardado afecta las sesiones principales futuras. Para una tarea rutinaria y
estrictamente acotada, explica cuál de Normal, Auto o YOLO elegirías y nombra la decisión que aún te requeriría.

A continuación, **Revisión nativa** explica un tipo de control diferente: evidencia sobre un candidato de código
congelado. No otorga permiso para entregar ese candidato.
