---
title: "Las capas de Gentle Shell"
description: "Distinguí Pi, gentle-shell, gentle-pi, Gentle AI y los complementos opcionales."
module: "Primeros pasos"
---

# Las capas de Gentle Shell

Es fácil llamar “el agente” a cada parte de una configuración de agente. Ese
atajo vuelve más difícil resolver problemas: una pregunta sobre sesiones
guardadas, una sobre un panel de espacio de trabajo y otra sobre memoria
corresponden a componentes distintos. Gentle Shell está construido
deliberadamente en capas. Conocer el límite de cada una te ayuda a elegir el
comando correcto, entender qué cambia una configuración y evitar esperar que
una capacidad opcional sea universal.

## Empezá con Pi

**Pi** es el entorno de ejecución de agentes de IA en la terminal. Coordina las
solicitudes al modelo, la ejecución de herramientas, el ensamblaje de contexto y
el almacenamiento de sesiones. Lo ejecutás desde una carpeta de trabajo; esa
carpeta es la base para descubrir recursos del proyecto y agrupar sesiones
guardadas. El modelo no opera tu terminal directamente. Pi construye una
solicitud a partir del prompt del sistema, la rama activa de la conversación,
las herramientas y la configuración del modelo, y luego la envía al proveedor
seleccionado. Cuando una respuesta solicita una herramienta, Pi ejecuta la
llamada y registra su resultado.

Pi también brinda la experiencia interactiva básica: la transcripción de la
conversación, el editor, el pie, el menú de comandos con barra, el selector de
modelo, las sesiones guardadas y los atajos de teclado configurables. Sus
herramientas se ejecutan con los permisos del sistema operativo del proceso de
Pi. La confianza del proyecto determina si se cargan los recursos del proyecto;
no es un sandbox para llamadas a herramientas.

Esa separación importa. Si una sesión simple de `pi` puede elegir un modelo,
llamar una herramienta integrada y guardar una sesión, esas son capacidades de
Pi, no funciones que requieran Gentle Shell.

## Gentle Shell es el espacio de trabajo

**gentle-shell** es el espacio de trabajo para agentes de programación creado
para Pi. No es simplemente un tema de terminal. Su espacio de trabajo brinda a
una sesión de Pi maneras adicionales de observar y orientar el trabajo: una
barra de shell, los cambios actuales de Git, el uso del proveedor cuando Pi lo
expone y vistas para la orquestación nativa de agentes.

Por ejemplo, Gentle Changes puede mostrar el árbol de trabajo de Git frente a
`HEAD`, incluidos los archivos sin seguimiento, para el repositorio de la sesión
y los worktrees relevantes de subagentes. Gentle Agents da al trabajo paralelo
una tarjeta visible y una superposición en lugar de ocultarlo en el historial de
la terminal. Estas vistas observan el trabajo; no reemplazan Git, las sesiones
de Pi ni la necesidad de inspeccionar un cambio.

El comando `gentle-shell` también es un lanzador. En su forma independiente
inicia Pi con el paquete Gentle Shell cargado, sin instalar el paquete en tu
agente Pi existente ni editar el `settings.json` de ese agente. El home aislado
predeterminado es `~/.gentle-shell/agent`; en cambio, `gentle-shell --link`
reutiliza el home normal del agente Pi. Son elecciones deliberadamente
distintas: el aislamiento separa el home del agente, mientras que el enlace
reutiliza los inicios de sesión, modelos y chats existentes de Pi.

## gentle-pi es el paquete de integración

El paquete npm se llama actualmente **gentle-pi**, aunque el producto se llama
Gentle Shell. Es el paquete que integra la barra de shell, los cambios del
espacio de trabajo, el uso del proveedor donde Pi lo pone a disposición y las
vistas nativas de agentes en una sesión de Pi. Esta distinción de nombres
explica comandos como:

```bash
npm i -g gentle-pi
gentle-shell
```

El primer comando instala el paquete globalmente; el segundo inicia el espacio
de trabajo. Como alternativa, una instalación existente de Pi puede instalar el
paquete y luego ejecutar Pi con él. Son caminos de instalación, no bucles de
agente que compiten: Pi sigue siendo el entorno de ejecución en ambos casos.

## Gentle AI y los complementos

**Gentle AI** es una herramienta de flujo de trabajo relacionada, no otro nombre
para Pi. Gentle Shell puede usarla para aprovisionar paquetes complementarios y
recursos administrados para un home. El comando `gentle-ai` tiene sus propios
comandos, como `install`, `sync`, `doctor` y `skill-registry refresh`. Una sesión
normal de Pi no se convierte en un espacio de trabajo de Gentle Shell solo porque
el comando Gentle AI exista en la máquina.

Algunas capacidades son deliberadamente complementos opcionales.
`gentle-engram` proporciona memoria persistente; `pi-web-access`, `pi-lens` y
`pi-intercom` también figuran como complementos opcionales. En particular, la
memoria persistente **no** viene incluida con `gentle-pi`. Una lección posterior
de este curso trata su flujo de trabajo. Por ahora, el modelo mental seguro es:
no supongas que una extensión está presente solo porque otra instalación la
tiene.

## Por qué los límites ahorran tiempo

Cuando algo sale mal, ubicá primero la capa:

- Un modelo no puede autenticarse o una sesión no se reanuda: empezá con Pi.
- Querés inspeccionar un diff activo o una tarea delegada en el espacio de
  trabajo: usá las vistas de Gentle Shell.
- Estás eligiendo entre un estado de agente aislado o enlazado: usá el
  comportamiento del lanzador `gentle-shell`.
- Necesitás una acción de configuración o sincronización del ecosistema: mirá
  Gentle AI.
- Necesitás memoria durable entre sesiones: verificá que el complemento de
  memoria opcional esté instalado y disponible.

Esto también mantiene moderadas las afirmaciones sobre la configuración. Un
paquete cargado en un home de agente no necesariamente está cargado en otro. Un
complemento no es un derecho adquirido. Y un espacio de trabajo pulido no hace
que la ejecución de herramientas esté aislada en un sandbox.

## Errores comunes

- **Llamar a gentle-shell un reemplazo de Pi.** Está creado para y se ejecuta
  con Pi; Pi proporciona el bucle de agente y los mecanismos de sesión.
- **Tratar `gentle-pi` y `gentle-shell` como productos sin relación.** El
  primero es el nombre actual del paquete; el segundo es el espacio de trabajo y
  lanzador orientado al usuario.
- **Suponer que todas las instalaciones tienen memoria.** La memoria persistente
  es opcional.
- **Confundir un home enlazado con una copia.** `--link` reutiliza el home de Pi;
  no crea un almacén de credenciales separado.

## Probalo

Ejecutá `gentle-shell --version`. Después, describí el resultado en una oración
para cada punto: qué capa hará la próxima solicitud al modelo, qué capa brinda
el espacio de trabajo y qué capacidad tendrías que verificar antes de depender
de memoria persistente. Ese vocabulario hará que las siguientes lecciones de
configuración sean mucho más claras.
