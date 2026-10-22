---
title: "Personalización"
description: "Personalizá Pi y Gentle Shell deliberadamente mientras preservás límites claros de configuración."
module: "Usuario avanzado"
---

# Personalización

Un entorno de programación debería adaptarse a tu atención, no exigirte memorizar
una colección privada de interruptores. La distinción útil no es “configuración
versus ninguna configuración”; es **qué capa es dueña de una preferencia, dónde se
carga y si puede ejecutar comportamiento**. Eso te permite hacer una terminal más
legible sin convertir accidentalmente un checkout de proyecto en una fuente de
instrucciones o código sin revisar.

Pi tiene configuración de nivel de usuario en su directorio de agente, normalmente
`~/.pi/agent`, y configuración de proyecto en `.pi` debajo del directorio de trabajo.
La configuración de proyecto se carga después de otorgar confianza al proyecto. La
excepción es `sessionDir`, que Pi lee temprano para poder encontrar sesiones. Los
archivos de contexto como `AGENTS.md` son diferentes otra vez: Pi los descubre desde
el directorio del agente, el directorio de trabajo y los directorios padre, y ese
descubrimiento no requiere confianza del proyecto.

## Configuración: elegí un alcance antes que un valor

`<agent-dir>/settings.json` contiene preferencias de nivel de usuario, valores
predeterminados, rutas de recursos y declaraciones de paquetes. `.pi/settings.json`
contiene sus equivalentes de nivel de proyecto. La configuración de proyecto
sobrescribe la del directorio de agente, mientras las listas de recursos se combinan.
Agregá la URL del esquema de configuración publicado de Pi a un archivo de
configuración cuando quieras validación y completado del editor.

Usá `/settings` para preferencias interactivas habituales. La configuración editada
manualmente, los keybindings, las instrucciones y los recursos necesitan `/reload`
en una sesión activa. La referencia de configuración agrupa opciones en modelo y
thinking, interacción, herramientas, sesiones y contexto, visualización, red, shell,
recursos y comportamiento de actualización. La agrupación importa: un `theme` es una
elección de visualización, mientras `defaultTools` controla qué conjunto de
herramientas incorporadas comienza activo.

Por ejemplo, `defaultTools` usa nombres simples para reemplazar valores predeterminados
y `+name` o `-name` para ajustar una selección heredada. Una lista de proyecto que
contiene solo entradas más y menos ajusta la selección de usuario; una con un nombre
simple la reemplaza. Eso permite que un proyecto habilite `codemode` junto a las
herramientas comunes sin inventar silenciosamente un nuevo conjunto base.

La configuración no es automáticamente inofensiva. Las rutas de recursos pueden
cargar extensiones, skills, prompts o themes; los paquetes pueden incluir extensiones
ejecutables. Mantené las preferencias personales como personales, e inspeccioná un
proyecto desconocido antes de confiar en él.

## Themes: presentación con un formato estricto

Los themes controlan los colores de Pi en modo interactivo y exportaciones HTML. El
theme predeterminado `system` deriva colores del primer plano, fondo y paleta ANSI de
la terminal, y se adapta a cambios claro/oscuro. Pi también incluye `dark` y `light`.
Seleccioná un theme en `/settings`, o usá `--use-theme` para una invocación sin
guardarlo.

Un theme JSON personalizado convencionalmente vive en
`<agent-dir>/themes/my-theme.json`. Su `name` lo identifica; `system` y los nombres
que contienen `/` están reservados. El archivo puede definir `vars`, asignar `colors`
basados en roles y especificar opcionalmente colores de exportación HTML. Los objetos
de theme son estrictos: se rechazan campos de nivel superior y tokens de color
desconocidos. Poné valores personalizados reutilizables en `vars`, no claves de color
improvisadas.

Un theme de usuario nombrado según su archivo se recarga en caliente cuando está
activo. Para un theme de otra fuente, usá `/reload` después de un cambio. Los themes
de proyecto en `.pi/themes/` están sujetos a la confianza del proyecto, igual que
otros recursos de proyecto. Un theme altera cómo se ve la información; no altera la
política ni la autoridad de herramientas del agente.

## Prompt templates: texto reutilizable, no código

Un archivo Markdown en `<agent-dir>/prompts/` se convierte en un comando de barra. Su
nombre de archivo es el nombre del comando, y el frontmatter opcional da una
descripción y una pista de argumento. Por ejemplo, `review.md` crea `/review`; `$1`,
`$@` y las sustituciones predeterminadas colocan los argumentos de comando entre
comillas en el texto antes de que el agente lo vea.

Los templates sirven para prompts estables como una lista de verificación de revisión.
No agregan comportamiento ejecutable. Los templates de proyecto también están
controlados por la confianza del proyecto porque su contenido puede indicar a un
modelo que ejecute programas. Al elegir entre esto y una extensión, volvé a
**Extensions and packages**: la reutilización de texto es un template; el
comportamiento de tiempo de ejecución es una extensión.

## El panel Customize de Gentle Shell

`/gentle:customize` reúne los controles visuales y de espacio de trabajo de Gentle
Shell. Puede ajustar la calidad de animación, el banner de inicio, logo de texto y
color, y un theme de Pi instalado. También controla la ubicación y densidad del
estado, visibilidad de cambios, agentes, TODO, uso/costo y detalles de modelo. Los
cambios de layout se aplican de inmediato; los cambios de banner aparecen en el
próximo inicio.

El panel también expone una preferencia global explícita de Vim para el editor de
prompts. Los editores no compatibles mantienen la edición común incluso si la
preferencia guardada está activada. Los perfiles visuales pueden guardar y aplicar un
theme instalado seleccionado, banner, animación y layout. No incluyen Vim; eso evita
confundir la semántica de edición con la apariencia visual.

### El audio es intencional y local

Las notificaciones de audio están desactivadas de forma predeterminada. En
`/gentle:customize` → Notifications, el interruptor global, silencio de proceso y los
grupos de tipos éxito/error/atención viven en una tarjeta; las sobrescrituras por
evento se pliegan bajo Advanced. Silenciar o deshabilitar descarta eventos pendientes,
y reanudar no los reproduce. Solo el propietario TUI primario reproduce audio: los
procesos hijo, modo print/JSON y RPC son silenciosos.

El panel puede usar tonos incorporados o una ruta literal absoluta a un WAV local. No
acepta URLs, rutas relativas, `~`, expansión de entorno, comandos ni ejecutables de
reproductor configurables. Esto hace de la selección de sonido una elección de archivo
local, no un ejecutor encubierto de comandos. Las preferencias de audio son separadas
de los perfiles visuales y del restablecimiento visual.

### El historial merece el mismo cuidado

La captura de historial de prompts también está desactivada de forma predeterminada
porque los prompts pueden contener secretos. Habilitala o deshabilitala desde la
categoría History de `/gentle:customize`; el cambio se aplica desde el próximo prompt.
Un valor de entorno explícito `GENTLE_PI_HISTORY_CAPTURE` sobrescribe la preferencia
guardada para esa sesión o script.

El historial capturado es JSONL local en texto plano, no está cifrado y puede contener
prompts textualmente. Desactivar la captura detiene las nuevas escrituras, pero no
elimina lo que ya se almacenó. Por eso una preferencia de historial es una decisión de
privacidad, no solo un interruptor de conveniencia.

## Errores comunes

- Editar una configuración de proyecto antes de comprobar si es confiable y quién la heredará.
- Llamar a un theme un mecanismo de política o asumir que cambia permisos.
- Usar un template donde se requiere una extensión, o una extensión donde alcanza reutilizar texto.
- Habilitar historial sin considerar que los prompts enviados pueden ser sensibles.
- Esperar que un perfil visual capture cada preferencia no visual.

## Probalo

Abrí `/gentle:customize` e inspeccioná una elección de layout o visualización sin
cambiarla. Luego inspeccioná `/settings` e identificá el theme activo. Elegí una
preferencia pequeña y reversible para cambiar, observá si se aplica de inmediato o
después de recargar/iniciar, y registrá qué alcance es dueño de ella. Así la
personalización sigue siendo una herramienta de claridad en lugar de un segundo
sistema accidental.
