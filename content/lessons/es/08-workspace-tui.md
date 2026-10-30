---
title: "El espacio de trabajo y la UI de terminal"
description: "Navega por el espacio de trabajo de terminal de Pi y Gentle Shell sin confundir las vistas con automatización oculta."
module: "Fundamentos"
---

# El espacio de trabajo y la UI de terminal

Un agente de programación debe poder inspeccionarse mientras trabaja. Pi proporciona la
interfaz de conversación de terminal; Gentle Shell agrega vistas de espacio de trabajo
alrededor de la misma sesión de Pi. Estas interfaces mejoran la visibilidad y la navegación,
pero no hacen que el trabajo ocurra por sí solas. Aún lees comandos, inspeccionas diffs y
tomas decisiones sobre el repositorio.

## Aprende primero la superficie de Pi

La terminal interactiva de Pi tiene una transcripción, un editor e información de estado. La
transcripción muestra prompts, respuestas, llamadas a herramientas, resultados y errores. El
editor es donde escribes el siguiente prompt. El pie informa la carpeta de trabajo, sesión,
modelo, uso de contexto y el uso y costo acumulados.

Vale la pena aprender unos controles directos antes de cualquier atajo personalizado del
espacio de trabajo:

- **Enter** envía un prompt; **Shift+Enter** inserta un salto de línea.
- **Ctrl+G** abre un prompt más largo en el editor externo configurado.
- Escribe **`@`** para buscar un archivo que agregar a un prompt; **Tab** completa una ruta.
- **Ctrl+O** expande o contrae la salida de herramientas.
- **Ctrl+T** muestra u oculta bloques de razonamiento.
- **Escape** detiene la tarea actual.
- **Alt+Enter** pone en cola trabajo de seguimiento, y **Alt+Up** restaura los mensajes en
  cola al editor.

Pi tiene dos modos de visualización. El modo de pantalla completa mantiene fijos el editor y
el área de estado mientras la transcripción se desplaza dentro de la terminal; el modo regular
usa el desplazamiento normal de la terminal. Elige un modo con `/settings` o la opción
`--tui-mode`. El comportamiento del mouse y algunos atajos dependen del soporte de la
terminal, así que no dependas de la interacción con puntero sin una alternativa de teclado.

## Los comandos se pueden descubrir, no son una prueba de memoria

Escribe `/` en el editor para buscar los comandos disponibles en la sesión actual. El menú es
autoritativo porque las extensiones, plantillas de prompts y habilidades pueden agregar
comandos. Los comandos integrados de sesión de Pi incluyen `/new`, `/resume`, `/tree`,
`/fork`, `/clone` y `/compact`; los comandos de modelo incluyen `/model`, `/thinking`,
`/login` y `/settings`.

Ejecuta `/hotkeys` para ver los atajos de teclado activos en la sesión actual. Esto es mejor
que asumir valores predeterminados, porque las asociaciones de teclas pueden cambiarse en el
archivo `keybindings.json` del directorio del agente. Después de editar ese archivo, `/reload`
lo aplica a la sesión activa.

Los valores predeterminados ilustran el patrón: `Ctrl+L` abre el selector de modelo,
`Shift+Tab` alterna un nivel de razonamiento compatible, `Ctrl+O` expande la salida de
herramientas y `Ctrl+X` copia el mensaje relevante del asistente. En el modo de pantalla
completa, las acciones de navegación de la transcripción pueden tener precedencia sobre las
del editor que usan la misma tecla. Esa es una razón para consultar `/hotkeys` cuando una tecla
conocida se comporta de manera distinta.

## Gentle Shell agrega una paleta seleccionada

Gentle Shell tiene su propia paleta de comandos:

```text
/gentle:commands
```

De forma predeterminada, **Alt+K** la abre. La paleta está seleccionada en lugar de ser una
lista sin filtrar de cada comando registrado. Agrupa las entradas disponibles en
Configuration, Session, Diagnostics y Skills, y busca por etiqueta legible, nombre de comando
o descripción. Una entrada aparece solo cuando está seleccionada y registrada.

Esto es diferente del menú `/` de Pi. El menú de Pi busca todos los comandos actualmente
disponibles en la sesión; la paleta de Gentle Shell es una superficie de espacio de trabajo
seleccionada intencionalmente. Usa el primero para descubrir comandos generales de sesión y el
segundo para acceder rápidamente a controles comunes de Gentle Shell. El atajo de la paleta
puede reasignarse con `GENTLE_PI_COMMANDS_KEY`; establecerlo en `off` lo desactiva.

## Gentle Changes hace visible el estado de Git

Abre la vista completa de Changes con:

```text
/gentle:changes
```

El atajo predeterminado es **Alt+G**. Muestra el estado actual de Git frente a `HEAD`,
incluidos los archivos sin seguimiento, para el repositorio de la sesión y los worktrees de
subagentes relevantes. Esta es una vista basada en Git, no una afirmación de que el agente
hizo cada edición: también aparecen los cambios de tu editor, comandos de shell u otras
herramientas.

La vista de dos paneles agrupa las raíces a la izquierda y muestra un diff seleccionado a la
derecha. `j`/`k` o las teclas de flecha navegan; **F** alterna un modo de lectura solo de diff;
`o` o Enter abre el archivo real en el editor configurado; y `q` o Escape cierra. El visor lee
los diffs de forma diferida y tiene un límite explícito para un diff seleccionado, por lo que
un diff demasiado grande se ofrece al editor en lugar de renderizarse sin límite.

La idea clave es el alcance. Un cambio confirmado desaparece de la vista Changes porque Git
ya no lo informa como no confirmado. Un worktree eliminado desaparece porque su directorio ya
no está. La vista responde “¿qué no está confirmado aquí?”, no “¿qué hizo el agente para
siempre?”.

## Gentle Agents mantiene observable el trabajo delegado

Gentle Agents es una vista separada para el trabajo de subagentes. Mientras se muestra el
rail de pantalla completa, su tarjeta activa se mueve allí, que se desplaza en el orden
**Status → Jobs → Agents → TODO** (la tarjeta Status lleva el proyecto, un resumen de Changes y
los estados de otras extensiones; Jobs aparece solo mientras hay trabajos en ejecución o recién
terminados); sin el rail (pantalla completa estrecha o modo regular),
la tarjeta permanece encima del editor. `ctrl+shift+a` o un clic en el encabezado `▾ Collapse`
de la tarjeta la contrae, y `/gentle:agents` o **Alt+A** abre una superposición de terminal
completa. La superposición conserva hilos de tareas, modelo, tokens, costo, tiempo transcurrido,
resultados e historial. Los resultados en segundo plano regresan como tarjetas que inician un
nuevo turno; el padre no necesita sondear para descubrirlos.

Esto hace legible la delegación, pero no transfiere la responsabilidad. Cada subagente es su
propio proceso hijo de Pi, y la sesión padre sigue siendo el lugar donde se coordinan el
alcance, la evidencia y las siguientes acciones. La lección posterior **Delegación** explica
los roles y límites; aquí, usa la vista para ver qué está ejecutándose realmente en lugar de
adivinar a partir de una terminal silenciosa.

## Pega imágenes y usa otras herramientas de entrada

La tecla para pegar imágenes de Pi (`ctrl+v`, o `alt+v` en Windows) convierte una imagen del
portapapeles en un chip `[Image#N]` en el borrador en lugar de una ruta de archivo temporal. Una
pulsación de Backspace elimina el chip completo, y una franja encima del prompt muestra cada chip
con su formato, tamaño y una miniatura en terminales compatibles con imágenes. Si el modelo actual
no acepta imágenes, la franja te avisa antes de enviar.

Gentle Shell también tiene herramientas opcionales que se inician solo cuando las pides:

- `/gentle:design <brief>` hace que el modelo de la sesión escriba varias propuestas de diseño
  HTML en `design/<slug>/` y las abre en un lienzo local, donde puedes comentar cualquier elemento.
- `/gentle:voice` descarga una vez el dictado local, luego pega lo que dices en el borrador sin
  enviarlo; mantener Space en el editor activa pulsar para hablar.
- `/gentle:music [mood]` reproduce gentle-stream dentro de la shell en macOS y Linux (incluido
  WSL); en Windows nativo solo indica que todavía no está disponible. Un Gentle Shell incluido
  ofrece instalar el reproductor la primera vez.

## Configura sin confundir la configuración con el comportamiento

Pi te permite cambiar asociaciones de teclas en `keybindings.json`; Gentle Shell te permite
reasignar varios atajos del espacio de trabajo mediante variables de entorno con nombre. Ambos
son elecciones de interfaz. No alteran el ciclo subyacente del agente de Pi, el estado de Git
ni la necesidad de verificar el comportamiento.

Cuando una terminal se ve mal, comienza con `/hotkeys`, `/settings` y el modo actual. Cuando
falta una funcionalidad del espacio de trabajo, usa el menú de comandos o la paleta para ver
qué está registrado en lugar de suponer que todos los paquetes están cargados.

## Errores comunes

- **Tratar la paleta como la lista completa de comandos de Pi.** Está seleccionada.
- **Suponer que un diff visible es atribución al agente.** Changes refleja el estado de Git.
- **Usar notas de atajos antiguas en lugar de `/hotkeys`.** Las asociaciones son configurables.
- **Usar navegación solo con mouse.** El modo regular de terminal deja la entrada del mouse a
  la terminal, por lo que cada flujo necesita una ruta de teclado.
- **Suponer que una tarjeta cerrada de Agents significa que el trabajo nunca se ejecutó.**
  Inspecciona la vista de tareas y el estado de sesión cuando necesites historial.

## Pruébalo

Ejecuta `/hotkeys` y encuentra la asociación para la selección de modelo o la expansión de
salida de herramientas. Luego abre `/gentle:commands` y busca un comando de espacio de trabajo
registrado. Abre `/gentle:changes` en un repositorio con un cambio inocuo sin confirmar e
identifica qué comparación muestra el diff. Cierra cada vista con la ruta de teclado que
muestra, en lugar de depender del mouse.
