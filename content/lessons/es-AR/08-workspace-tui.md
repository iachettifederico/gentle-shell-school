---
title: "El espacio de trabajo y la UI de terminal"
description: "Navegá el espacio de trabajo de terminal de Pi y Gentle Shell sin confundir las vistas con automatización oculta."
module: "Primeros pasos"
---

# El espacio de trabajo y la UI de terminal

Un agente de programación debería poder inspeccionarse mientras trabaja. Pi proporciona la
interfaz de conversación de terminal; Gentle Shell agrega vistas de espacio de trabajo
alrededor de la misma sesión de Pi. Estas interfaces mejoran la visibilidad y la
navegación, pero no hacen que el trabajo suceda por sí solas. Todavía leés comandos,
inspeccionás diffs y tomás decisiones sobre el repositorio.

## Primero aprendé la superficie de Pi

La terminal interactiva de Pi tiene una transcripción, un editor e información de estado.
La transcripción muestra prompts, respuestas, llamadas a herramientas, resultados y
errores. El editor es donde escribís el próximo prompt. El pie informa la carpeta de
trabajo, la sesión, el modelo, el uso de contexto, y el uso y costo acumulados.

Vale la pena aprender algunos controles directos antes de cualquier atajo personalizado del
espacio de trabajo:

- **Enter** envía un prompt; **Shift+Enter** inserta un salto de línea.
- **Ctrl+G** abre un prompt más largo en el editor externo configurado.
- Escribí **`@`** para buscar un archivo que agregar a un prompt; **Tab** completa una ruta.
- **Ctrl+O** expande o contrae la salida de herramientas.
- **Ctrl+T** muestra u oculta los bloques de razonamiento.
- **Escape** detiene la tarea actual.
- **Alt+Enter** pone trabajo de seguimiento en cola, y **Alt+Up** restaura los mensajes en
  cola al editor.

Pi tiene dos modos de visualización. El modo de pantalla completa mantiene fijos el editor
y el área de estado mientras la transcripción se desplaza dentro de la terminal; el modo
normal usa el scrollback habitual de la terminal. Elegí un modo con `/settings` o la opción
`--tui-mode`. El comportamiento del mouse y algunos atajos dependen del soporte de la
terminal, así que no dependas de la interacción con puntero sin una ruta de teclado.

## Los comandos se pueden descubrir, no son una prueba de memoria

Escribí `/` en el editor para buscar comandos disponibles en la sesión actual. El menú es
la fuente de verdad porque las extensiones, las plantillas de prompts y las skills pueden
agregar comandos. Los comandos de sesión integrados de Pi incluyen `/new`, `/resume`,
`/tree`, `/fork`, `/clone` y `/compact`; los comandos de modelo incluyen `/model`,
`/thinking`, `/login` y `/settings`.

Ejecutá `/hotkeys` para ver los atajos de teclado activos en la sesión actual. Esto es mejor
que asumir los predeterminados, porque los keybindings pueden cambiarse en el archivo
`keybindings.json` del directorio del agente. Después de editar ese archivo, `/reload` lo
aplica a la sesión activa.

Los valores predeterminados ilustran el patrón: `Ctrl+L` abre el selector de modelos,
`Shift+Tab` recorre un nivel de razonamiento compatible, `Ctrl+O` expande la salida de
herramientas y `Ctrl+X` copia el mensaje relevante del asistente. En el modo de pantalla
completa, las acciones de navegación de la transcripción pueden tener prioridad sobre las
del editor que usan la misma tecla. Es una razón para consultar `/hotkeys` cuando una tecla
conocida se comporta de forma diferente.

## Gentle Shell agrega una paleta seleccionada

Gentle Shell tiene su propia paleta de comandos:

```text
/gentle:commands
```

De forma predeterminada, **Alt+K** la abre. La paleta está seleccionada en vez de ser una
lista sin procesar de todos los comandos registrados. Agrupa las entradas disponibles bajo
Configuration, Session, Diagnostics y Skills, y busca por etiqueta legible, nombre de
comando o descripción. Una entrada aparece solo cuando está seleccionada y registrada.

Esto es diferente del menú `/` de Pi. El menú de Pi busca todos los comandos disponibles
actualmente en la sesión; la paleta de Gentle Shell es una superficie del espacio de trabajo
seleccionada intencionalmente. Usá el primero para descubrir comandos de sesión generales y
el segundo para llegar rápidamente a controles comunes de Gentle Shell. El atajo de la
paleta se puede reasignar con `GENTLE_PI_COMMANDS_KEY`; configurarlo en `off` la
deshabilita.

## Gentle Changes vuelve visible el estado de Git

Abrí la vista completa de Changes con:

```text
/gentle:changes
```

El atajo predeterminado es **Alt+G**. Muestra el estado actual de Git frente a `HEAD`,
incluidos los archivos sin seguimiento, para el repositorio de la sesión y los worktrees de
subagentes relevantes. Es una vista basada en Git, no una afirmación de que el agente hizo
cada edición: también aparecen cambios de tu editor, comandos de shell u otras herramientas.

La vista de dos paneles agrupa los roots a la izquierda y muestra un diff seleccionado a la
derecha. `j`/`k` o las teclas de flecha navegan; **F** alterna un modo de lectura de solo
diff; `o` o Enter abre el archivo real en el editor configurado; y `q` o Escape cierra. El
visor lee los diffs de forma diferida y tiene un límite explícito para un diff seleccionado,
así que un diff demasiado grande se ofrece al editor en lugar de renderizarse sin límite.

La idea clave es el alcance. Un cambio confirmado desaparece de la vista Changes porque Git
ya no lo informa como no confirmado. Un worktree eliminado desaparece porque su directorio
ya no existe. La vista responde “¿qué no está confirmado acá?”; no “¿qué hizo el agente
para siempre?”.

## Gentle Agents mantiene observable el trabajo delegado

Gentle Agents es una vista separada para el trabajo de subagentes. Su tarjeta en vivo se
mantiene sobre el editor, y `/gentle:agents` o **Alt+A** abre una superposición de terminal
completa. La superposición conserva hilos de tareas, modelo, tokens, costo, tiempo
transcurrido, resultados e historial. Los resultados en segundo plano vuelven como tarjetas
que inician un nuevo turno; el padre no necesita consultar para descubrirlos.

Esto hace legible la delegación, pero no transfiere la responsabilidad. Cada subagente es su
propio proceso hijo de Pi, y la sesión padre sigue siendo el lugar donde se coordinan el
alcance, la evidencia y las próximas acciones. La lección posterior **Delegación** explica
los roles y límites; acá, usá la vista para ver qué se está ejecutando realmente en lugar de
adivinar desde una terminal silenciosa.

## Configurá sin confundir configuración con comportamiento

Pi te permite cambiar keybindings en `keybindings.json`; Gentle Shell te permite reasignar
varios atajos del espacio de trabajo mediante variables de entorno con nombre. Ambas son
elecciones de interfaz. No modifican el bucle subyacente del agente de Pi, el estado de Git
ni la necesidad de verificar el comportamiento.

Cuando una terminal se ve mal, empezá por `/hotkeys`, `/settings` y el modo actual. Cuando
falta una funcionalidad del espacio de trabajo, usá el menú de comandos o la paleta para ver
qué está registrado en vez de asumir que todos los paquetes están cargados.

## Errores comunes

- **Tratar la paleta como la lista completa de comandos de Pi.** Está seleccionada.
- **Suponer que un diff visible atribuye cambios al agente.** Changes refleja el estado de Git.
- **Usar notas de atajos antiguas en lugar de `/hotkeys`.** Los bindings son configurables.
- **Usar navegación solo con mouse.** El modo normal de terminal deja la entrada del mouse a
  la terminal, así que cada flujo de trabajo necesita una ruta de teclado.
- **Suponer que una tarjeta cerrada de Agents significa que el trabajo nunca se ejecutó.**
  Inspeccioná la vista de tareas y el estado de la sesión cuando necesites historial.

## Probalo

Ejecutá `/hotkeys` y encontrá el binding para selección de modelo o expansión de salida de
herramientas. Después abrí `/gentle:commands` y buscá un comando registrado del espacio de
trabajo. Abrí `/gentle:changes` en un repositorio con un cambio inofensivo sin confirmar, e
identificá qué comparación muestra el diff. Cerrá cada vista con la ruta de teclado que se
muestra en lugar de depender del mouse.
