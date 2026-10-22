---
title: "El bucle del agente"
description: "Entendé cómo Pi convierte tu mensaje en solicitudes al modelo, llamadas a herramientas y evidencia registrada."
module: "Primeros pasos"
---

# El bucle del agente

Un agente de terminal puede parecer una conversación continua, pero es una
secuencia de solicitudes al modelo y eventos registrados. Entender esa secuencia
explica por qué la salida de herramientas aparece en la transcripción, por qué
una solicitud a veces continúa después de una respuesta y por qué un mensaje que
escribís mientras el agente trabaja cambia el siguiente turno en vez de
interrumpir una herramienta a mitad de camino.

## El bucle empieza con contexto, no solo con tu última oración

Cuando enviás un mensaje, Pi lo agrega a la rama activa de la sesión. Luego Pi
construye una solicitud para el proveedor seleccionado a partir de cuatro
entradas principales:

1. el prompt del sistema,
2. el historial de la conversación de la rama activa,
3. las definiciones de herramientas disponibles y
4. la configuración actual del modelo.

El prompt del sistema tiene sus propias capas. Pi comienza con instrucciones
base y archivos de contexto descubiertos. También incluye definiciones de
herramientas y descripciones de habilidades. Las instrucciones completas de las
habilidades se cargan a demanda, mientras que las extensiones pueden agregar
instrucciones o transformar el contexto. Las plantillas de prompt expanden la
entrada del editor antes de que se convierta en un mensaje del usuario. Los
archivos seleccionados, las imágenes, el texto pegado y la salida de shell
también pueden convertirse en contenido del mensaje.

El resultado corrige útilmente una idea equivocada común: el modelo no ve tu
sistema de archivos automáticamente ni recibe todos los archivos de configuración
posibles simplemente porque existen. Recibe la solicitud ensamblada para la
sesión activa de Pi.

## Un turno: respuesta, herramientas y resultados

Pi envía esa solicitud a través del proveedor elegido. El proveedor transmite en
streaming una respuesta del asistente. Esa respuesta puede contener texto común,
llamadas a herramientas o ambos. Pi registra la respuesta. Para cada llamada a
una herramienta, Pi ejecuta la herramienta y registra el resultado. Esto completa
un turno.

Un flujo simplificado se ve así:

```text
your message
  -> Pi assembles request
  -> provider streams assistant response
  -> Pi records it
  -> Pi executes requested tools
  -> Pi records tool results
```

Los resultados de las herramientas son evidencia para el siguiente paso de
razonamiento del agente. Un resultado de `read` puede revelar código para
analizar; el resultado de un comando puede mostrar una prueba que falla; el
resultado de una edición puede confirmar que cambió el archivo previsto. Si los
resultados de herramientas o los mensajes en cola requieren otra solicitud al
modelo, Pi inicia otro turno. De lo contrario, la ejecución termina.

Por eso una solicitud como “inspeccioná este directorio y resumilo” puede
producir varias llamadas a herramientas visibles antes de la explicación final.
El agente no está trabajando en secreto entre mensajes; Pi recorre ciclos de
solicitudes, llamadas y resultados explícitos.

## La rama activa es el contexto de la conversación

Las sesiones son árboles, pero la rama activa proporciona el historial para la
siguiente solicitud al modelo. Pi convierte las entradas en esa ruta en mensajes
de usuario, asistente y resultado de herramienta compatibles con el modelo. La
ramificación y la compactación, cubiertas en **Sesiones y contexto**, por lo
tanto afectan lo que contiene la siguiente solicitud sin borrar el historial
crudo de la sesión.

Esto importa cuando cambiás de dirección. Un mensaje no es una instrucción
escrita directamente en la mente de un modelo; se convierte en una entrada de
sesión persistida y luego en parte de una solicitud posterior ensamblada desde la
rama activa. Cuando la rama cambia, también cambia el historial que proporciona.

## Orientar es distinto de hacer un seguimiento

Pi acepta nueva entrada mientras está trabajando, pero el momento cambia el
significado:

- Enviá con **Enter** para ajustar la tarea actual. El mensaje espera hasta que
  terminan la respuesta actual y sus llamadas a herramientas, y luego orienta la
  siguiente respuesta.
- Enviá con **Alt+Enter** para agregar trabajo después de la tarea actual. Esto
  pone en cola un seguimiento hasta que Pi termina el trabajo pendiente.
- Usá **Escape** para abortar la tarea actual. Los mensajes en cola vuelven al
  editor.
- Usá **Alt+Up** para devolver los mensajes en cola al editor sin esperar.

La referencia del bucle de agente describe el mismo límite: la orientación entra
después del turno actual del asistente; los seguimientos entran después de que el
agente termina el trabajo pendiente. Esto preserva una secuencia coherente de
resultados de herramientas. También te da una manera práctica de redirigir el
trabajo sin destruir el texto que preparaste.

## Las herramientas son capacidades, no un sandbox

El conjunto de herramientas integradas de Pi puede inspeccionar archivos,
ejecutar comandos, editar contenido y escribir archivos. Las extensiones pueden
registrar más herramientas. La disponibilidad de herramientas se envía al modelo
como definiciones, pero la ejecución ocurre localmente en el proceso de Pi.

Eso significa que dos hechos de seguridad son importantes:

- La confianza del proyecto controla si Pi carga la configuración y los recursos
  del proyecto antes de cargar los archivos de contexto.
- Las herramientas habilitadas usan los permisos del sistema operativo del
  proceso de Pi.

La confianza es valiosa, pero **no** aísla las herramientas en un sandbox.
Revisá los comandos y los archivos modificados, y usá un sandbox para trabajo no
confiable o sin supervisión. La capacidad del modelo de sugerir un comando no
hace que ese comando sea seguro para un repositorio o una máquina.

## Por qué los registros son parte del mecanismo

Pi registra las respuestas, llamadas y resultados del asistente en la sesión.
Esto permite reanudar el trabajo, reconstruir el contexto, inspeccionar la
transcripción y exportar una sesión. También explica por qué la transcripción
puede contener material sensible: los prompts, los argumentos de herramientas,
la salida de comandos, el contenido de archivos y las credenciales expuestas
durante la conversación pueden estar presentes. Revisala antes de compartirla o
exportarla.

El registro no es simplemente logging posterior. Pi usa la ruta activa registrada
para construir contexto posterior. En un sistema de agentes, el rastro es parte
de cómo se produce el siguiente paso.

## Errores comunes

- **Esperar que el modelo conozca un archivo sin una ruta de contexto o de
  herramienta.** Pi debe incluirlo en el contexto u obtenerlo mediante una
  herramienta.
- **Leer las llamadas a herramientas como salida decorativa.** Sus resultados a
  menudo determinan si comienza otro turno.
- **Tratar Enter y Alt+Enter como equivalentes mientras hay trabajo en
  ejecución.** Uno orienta; el otro programa un seguimiento.
- **Tratar la confianza como un sandbox.** No lo es.

## Probalo

Pedile a Pi una tarea de solo lectura e inofensiva, como listar un directorio
pequeño de documentación y explicar sus nombres de archivo. Mirá la
transcripción: identificá tu mensaje, la llamada a herramienta, su resultado y
la respuesta final. Después, imaginá que el resultado reveló un archivo
inesperado. Explicá por qué Pi necesitaría otra solicitud al modelo para decidir
qué hacer con esa evidencia.
