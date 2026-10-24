---
title: "Personalización"
description: "Personaliza Pi y Gentle Shell deliberadamente mientras preservas límites claros de configuración."
module: "Usuario avanzado"
---

# Personalización

Un entorno de programación debe adaptarse a tu atención, no exigirte que memorices una
colección privada de interruptores. La distinción útil no es «configuración
frente a ausencia de configuración»; es **qué capa es propietaria de una preferencia,
dónde se carga y si puede ejecutar comportamiento**. Eso te permite hacer una terminal
más legible sin convertir accidentalmente un checkout de proyecto en una fuente de
instrucciones o código sin revisar.

Pi tiene configuración de nivel de usuario en su directorio de agente, normalmente
`~/.pi/agent`, y configuración de proyecto en `.pi` debajo del directorio de trabajo.
La configuración de proyecto se carga después de otorgar confianza al proyecto. La
excepción es `sessionDir`, que Pi lee temprano para poder encontrar sesiones. Los
archivos de contexto como `AGENTS.md` son diferentes nuevamente: Pi los descubre desde
el directorio del agente, el directorio de trabajo y los directorios padre, y ese
descubrimiento no requiere confianza del proyecto.

## Configuración: elige un alcance antes que un valor

`<agent-dir>/settings.json` contiene preferencias de nivel de usuario, valores
predeterminados, rutas de recursos y declaraciones de paquetes. `.pi/settings.json`
contiene sus equivalentes de nivel de proyecto. La configuración de proyecto reemplaza
la del directorio del agente, mientras que las listas de recursos se combinan. Agrega la
URL del esquema de configuración publicado de Pi a un archivo de configuración cuando
quieras validación y finalización del editor.

Usa `/settings` para preferencias interactivas habituales. La configuración editada
manualmente, los keybindings, las instrucciones y los recursos necesitan `/reload` en
una sesión activa. La referencia de configuración agrupa las opciones en modelo y
thinking, interacción, herramientas, sesiones y contexto, visualización, red, shell,
recursos y comportamiento de actualización. La agrupación importa: un `theme` es una
opción de visualización, mientras que `defaultTools` controla qué conjunto de
herramientas integradas comienza activo.

Por ejemplo, `defaultTools` usa nombres sencillos para reemplazar valores predeterminados
y `+name` o `-name` para ajustar una selección heredada. Una lista de proyecto que
contiene solo entradas de más y menos ajusta la selección de usuario; una que contiene
un nombre sencillo la reemplaza. Eso permite que un proyecto habilite `codemode` junto
a las herramientas habituales sin inventar silenciosamente un nuevo conjunto base.

La configuración no es automáticamente inofensiva. Las rutas de recursos pueden cargar
extensiones, skills, prompts o themes; los paquetes pueden incluir extensiones
ejecutables. Mantén las preferencias personales como personales e inspecciona un
proyecto desconocido antes de confiar en él.

## Themes: presentación con un formato estricto

Los themes controlan los colores de Pi en modo interactivo y en las exportaciones HTML.
El theme predeterminado `system` obtiene los colores del primer plano, el fondo y la
paleta ANSI de la terminal, y se adapta a los cambios claro/oscuro. Pi también incluye
`dark` y `light`. Selecciona un theme en `/settings`, o usa `--use-theme` para una
invocación sin guardarlo.

Un theme JSON personalizado habitualmente se encuentra en `<agent-dir>/themes/my-theme.json`.
Su `name` lo identifica; `system` y los nombres que contienen `/` están reservados. El
archivo puede definir `vars`, asignar `colors` basados en roles y, opcionalmente,
especificar colores para la exportación HTML. Los objetos de theme son estrictos: los
campos de nivel superior y los tokens de color desconocidos se rechazan. Coloca valores
personalizados reutilizables en `vars`, no claves de color improvisadas.

Un theme de usuario cuyo nombre corresponde a su archivo se recarga en caliente cuando
está activo. Para un theme de otra fuente, usa `/reload` después de un cambio. Los
themes de proyecto en `.pi/themes/` están sujetos a la confianza del proyecto, al igual
que otros recursos de proyecto. Un theme cambia la apariencia de la información; no
cambia la política ni la autoridad de herramientas del agente.

## Prompt templates: texto reutilizable, no código

Un archivo Markdown en `<agent-dir>/prompts/` se convierte en un comando de barra. Su
nombre de archivo es el nombre del comando, y el frontmatter opcional proporciona una
descripción y una pista de argumento. Por ejemplo, `review.md` crea `/review`; `$1`,
`$@` y las sustituciones predeterminadas colocan los argumentos de comando entre
comillas en el texto antes de que el agente lo vea.

Los templates son adecuados para prompts estables, como una lista de verificación de
revisión. No agregan comportamiento ejecutable. Los templates de proyecto también están
controlados por la confianza del proyecto porque su contenido puede indicar a un modelo
que ejecute programas. Al elegir entre esto y una extensión, vuelve a **Extensions and
packages**: la reutilización de texto es un template; el comportamiento en tiempo de
ejecución es una extensión.

## El panel Customize de Gentle Shell

`/gentle:customize` reúne los controles visuales y del espacio de trabajo de Gentle
Shell. Puede ajustar la calidad de la animación, el banner de inicio, el logo de texto y
su color, y un theme de Pi instalado. También controla la ubicación y densidad del
estado, la visibilidad de cambios, agentes, TODO, uso/costo y detalles del modelo. Los
cambios de layout se aplican de inmediato; los cambios de banner aparecen en el próximo
inicio.

El panel también presenta una preferencia global explícita de Vim para el editor de
prompts. Los editores no compatibles conservan la edición habitual aunque la preferencia
guardada esté activada. Los perfiles visuales pueden guardar y aplicar un theme instalado
seleccionado, banner, animación y layout. No incluyen Vim; eso evita confundir la
semántica de edición con la apariencia visual.

### El audio es intencional y local

Las notificaciones de audio están desactivadas de forma predeterminada. En
`/gentle:customize` → Notifications, el interruptor global, el silencio del proceso y
los grupos de tipo éxito/error/atención están en una tarjeta; las anulaciones por evento
se agrupan bajo Advanced. Silenciar o deshabilitar descarta eventos pendientes, y al
reanudar no se reproducen de nuevo. Solo el propietario principal de TUI reproduce
audio: los procesos secundarios, el modo print/JSON y RPC son silenciosos.

El panel puede usar tonos integrados o una ruta local absoluta literal a un archivo WAV, OGG o
FLAC (como máximo 2 MiB y 10 segundos; qué formatos se reproducen depende del backend de audio de
tu plataforma). No
acepta URLs, rutas relativas, `~`, expansión de entorno, comandos ni ejecutables de
reproductor configurables. Esto convierte la selección de sonido en una elección de
archivo local, no en un ejecutor de comandos encubierto. Las preferencias de audio son
independientes de los perfiles visuales y del restablecimiento visual.

### El historial merece el mismo cuidado

La captura del historial de prompts también está desactivada de forma predeterminada
porque los prompts pueden contener secretos. Actívala o desactívala desde la categoría
History de `/gentle:customize`; el cambio se aplica desde el siguiente prompt. Un valor
de entorno explícito `GENTLE_PI_HISTORY_CAPTURE` anula la preferencia guardada para esa
sesión o script.

El historial capturado es JSONL local de texto sin formato, no está cifrado y puede
contener prompts literalmente. Desactivar la captura detiene las nuevas escrituras, pero
no elimina lo que ya se almacenó. Por eso, una preferencia de historial es una decisión
de privacidad, no solo un interruptor de conveniencia.

## Errores comunes

- Editar una configuración de proyecto antes de comprobar si es confiable y quién la
  heredará.
- Llamar a un theme un mecanismo de política o asumir que cambia los permisos.
- Usar un template donde se necesita una extensión, o una extensión donde la reutilización
  de texto es suficiente.
- Habilitar el historial sin considerar que los prompts entregados pueden ser sensibles.
- Esperar que un perfil visual capture cada preferencia no visual.

## Pruébalo

Abre `/gentle:customize` e inspecciona una opción de layout o visualización sin
cambiarla. Luego inspecciona `/settings` e identifica el theme activo. Elige una
preferencia pequeña y reversible para cambiar, observa si se aplica inmediatamente o
después de recargar/iniciar y registra qué alcance es propietario de ella. Así la
personalización sigue siendo una herramienta de claridad en lugar de un segundo sistema
accidental.
