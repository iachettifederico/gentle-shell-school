---
title: "Las capas de Gentle Shell"
description: "Distingue Pi, gentle-shell, gentle-pi, Gentle AI y los complementos opcionales."
module: "Fundamentos"
---

# Las capas de Gentle Shell

Es fácil llamar «el agente» a cada parte de una configuración de agente. Ese atajo hace
más difícil la resolución de problemas: una pregunta sobre sesiones guardadas, una pregunta
sobre un panel del espacio de trabajo y una pregunta sobre memoria corresponden a componentes
diferentes. Gentle Shell está diseñado deliberadamente en capas. Conocer el límite de cada una
te ayuda a elegir el comando correcto, comprender qué cambia una configuración y evitar esperar
que una capacidad opcional sea universal.

## Comienza con Pi

**Pi** es el tiempo de ejecución de agentes de IA en la terminal. Coordina solicitudes al
modelo, ejecución de herramientas, ensamblaje de contexto y almacenamiento de sesiones. Lo
ejecutas desde una carpeta de trabajo; esa carpeta es la base para descubrir recursos del
proyecto y agrupar sesiones guardadas. El modelo no opera directamente tu terminal. Pi crea una
solicitud a partir del prompt del sistema, la rama activa de la conversación, las herramientas y
la configuración del modelo, y luego la envía al proveedor seleccionado. Cuando una respuesta
solicita una herramienta, Pi ejecuta la llamada y registra su resultado.

Pi también proporciona la experiencia interactiva básica: la transcripción de la conversación,
el editor, el pie de página, el menú de comandos con barra, el selector de modelo, las sesiones
guardadas y las combinaciones de teclas configurables. Sus herramientas se ejecutan con los
permisos del sistema operativo del proceso de Pi. La confianza del proyecto determina si se
cargan los recursos del proyecto; no es un sandbox para llamadas de herramientas.

Esa separación es importante. Si una sesión simple de `pi` puede elegir un modelo, llamar una
herramienta integrada y guardar una sesión, esas son capacidades de Pi, no características que
requieran Gentle Shell.

## Gentle Shell es el espacio de trabajo

**gentle-shell** es el espacio de trabajo para agentes de programación diseñado para Pi. No es
solo un tema de terminal. Su espacio de trabajo brinda a una sesión de Pi formas adicionales de
observar y dirigir el trabajo: una barra de shell, cambios actuales de Git, uso del proveedor
cuando Pi lo expone y vistas para la orquestación nativa de agentes.

Por ejemplo, Gentle Changes puede mostrar el árbol de trabajo de Git frente a `HEAD`, incluidos
los archivos sin seguimiento, para el repositorio de la sesión y los worktrees relevantes de
subagentes. Gentle Agents brinda al trabajo paralelo una tarjeta visible y una superposición en
lugar de ocultarlo en el desplazamiento de la terminal. Estas vistas observan el trabajo; no
reemplazan Git, las sesiones de Pi ni la necesidad de inspeccionar un cambio.

El comando `gentle-shell` también es un iniciador. En su forma independiente inicia Pi con el
paquete Gentle Shell cargado, sin instalar el paquete en tu agente de Pi existente ni editar el
`settings.json` de ese agente. El home aislado predeterminado es `~/.gentle-shell/agent`;
`gentle-shell --link` en cambio reutiliza el home normal del agente de Pi. Son elecciones
deliberadamente distintas: el aislamiento separa el home del agente, mientras que la vinculación
reutiliza los inicios de sesión, modelos y chats existentes de Pi.

## gentle-pi es el paquete de integración

El paquete de npm actualmente se llama **gentle-pi**, aunque el producto se llama Gentle Shell.
Es el paquete que integra la barra de shell, los cambios del espacio de trabajo, el uso del
proveedor cuando Pi lo pone a disposición y las vistas nativas de agentes en una sesión de Pi.
Esta distinción de nombres explica comandos como:

```bash
npm i -g gentle-pi
gentle-shell
```

El primer comando instala el paquete globalmente; el segundo inicia el espacio de trabajo. Como
alternativa, una instalación existente de Pi puede instalar el paquete y luego ejecutar Pi con
él. Estas son rutas de instalación, no bucles de agentes en competencia: Pi sigue siendo el
tiempo de ejecución en ambos casos.

## Gentle AI y los complementos

**Gentle AI** es una herramienta de flujo de trabajo relacionada, no otro nombre para Pi. Gentle
Shell puede usarla para aprovisionar paquetes complementarios y recursos administrados para un
home. El comando `gentle-ai` tiene sus propios comandos como `install`, `sync`, `doctor` y
`skill-registry refresh`. Una sesión normal de Pi no se convierte en un espacio de trabajo de
Gentle Shell simplemente porque el comando Gentle AI existe en la máquina.

Algunas capacidades son deliberadamente complementos opcionales. `gentle-engram` proporciona
memoria persistente; `pi-web-access`, `pi-lens` y `pi-intercom` también se enumeran como
complementos opcionales. En particular, la memoria persistente **no** está incluida con
`gentle-pi`. Una lección sobre memoria más adelante en este curso cubre su flujo de trabajo. Por
ahora, el modelo mental seguro es: no supongas que una extensión está presente solo porque otra
instalación la tiene.

## Por qué los límites ahorran tiempo

Cuando algo sale mal, primero ubica la capa:

- Un modelo no puede autenticarse o una sesión no se reanuda: comienza con Pi.
- Quieres inspeccionar un diff activo o una tarea delegada en el espacio de trabajo: usa las
  vistas de Gentle Shell.
- Estás eligiendo entre estado de agente aislado o vinculado: usa el comportamiento del iniciador
  `gentle-shell`.
- Necesitas una acción de configuración o sincronización del ecosistema: consulta Gentle AI.
- Necesitas memoria duradera entre sesiones: verifica que el complemento de memoria opcional esté
  instalado y disponible.

Esto también mantiene moderadas las afirmaciones de configuración. Un paquete cargado en un home
de agente no necesariamente está cargado en otro. Un complemento no es un derecho adquirido. Y
un espacio de trabajo pulido no hace que la ejecución de herramientas esté aislada en un sandbox.

## Errores comunes

- **Llamar a gentle-shell un reemplazo de Pi.** Está diseñado para y se ejecuta con Pi; Pi
  proporciona el bucle del agente y los mecanismos de sesión.
- **Tratar `gentle-pi` y `gentle-shell` como productos no relacionados.** El primero es el
  nombre actual del paquete; el segundo es el espacio de trabajo e iniciador orientado al usuario.
- **Suponer que todas las instalaciones tienen memoria.** La memoria persistente es opcional.
- **Confundir un home vinculado con una copia.** `--link` reutiliza el home de Pi; no crea un
  almacén de credenciales separado.

## Pruébalo

Ejecuta `gentle-shell --version`. Luego describe el resultado en una oración para cada caso: qué
capa realizará la siguiente solicitud al modelo, qué capa proporciona el espacio de trabajo y qué
capacidad necesitarías verificar antes de depender de la memoria persistente. Ese vocabulario
hará mucho más claras las siguientes lecciones de configuración.
