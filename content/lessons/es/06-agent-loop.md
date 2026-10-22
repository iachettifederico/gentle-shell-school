---
title: "El bucle del agente"
description: "Comprende cómo Pi convierte tu mensaje en solicitudes al modelo, llamadas de herramientas y evidencia registrada."
module: "Fundamentos"
---

# El bucle del agente

Un agente de terminal puede parecer una conversación continua, pero es una secuencia de
solicitudes al modelo y eventos registrados. Comprender esa secuencia explica por qué la salida de
una herramienta aparece en la transcripción, por qué una solicitud a veces continúa después de
una respuesta y por qué un mensaje escrito mientras el agente trabaja cambia el siguiente turno
en lugar de interrumpir una herramienta a la mitad.

## El bucle comienza con contexto, no solo con tu última oración

Cuando envías un mensaje, Pi lo agrega a la rama activa de la sesión. Luego Pi crea una solicitud
para el proveedor seleccionado a partir de cuatro entradas principales:

1. el prompt del sistema,
2. el historial de conversación de la rama activa,
3. las definiciones de herramientas disponibles y
4. la configuración actual del modelo.

El prompt del sistema tiene sus propias capas. Pi comienza con instrucciones base y archivos de
contexto descubiertos. También contiene definiciones de herramientas y descripciones de skills.
Las instrucciones completas de los skills se cargan bajo demanda, mientras que las extensiones
pueden agregar instrucciones o transformar el contexto. Las plantillas de prompt expanden la
entrada del editor antes de que se convierta en un mensaje de usuario. Los archivos seleccionados,
imágenes, texto pegado y salida del shell también pueden convertirse en contenido del mensaje.

El resultado es una corrección útil a una idea equivocada común: el modelo no ve tu sistema de
archivos automáticamente y no recibe todos los archivos de configuración posibles solo porque
existen. Recibe la solicitud ensamblada para la sesión de Pi activa.

## Un turno: respuesta, herramientas, resultados

Pi envía esa solicitud mediante el proveedor elegido. El proveedor transmite una respuesta del
asistente. Esa respuesta puede contener texto normal, llamadas de herramientas o ambos. Pi
registra la respuesta. Para cada llamada de herramienta, Pi ejecuta la herramienta y registra el
resultado. Esto completa un turno.

Un flujo simplificado se ve así:

```text
your message
  -> Pi assembles request
  -> provider streams assistant response
  -> Pi records it
  -> Pi executes requested tools
  -> Pi records tool results
```

Los resultados de herramientas son evidencia para el siguiente paso de razonamiento del agente. Un
resultado de `read` puede revelar código para analizar; el resultado de un comando puede mostrar
una prueba fallida; el resultado de una edición puede confirmar que un archivo previsto cambió. Si
los resultados de herramientas o los mensajes en cola requieren otra solicitud al modelo, Pi inicia
otro turno. De lo contrario, la ejecución termina.

Por eso una solicitud como «inspecciona este directorio y haz un resumen» puede producir varias
llamadas de herramientas visibles antes de la explicación final. El agente no está trabajando en
secreto entre mensajes; Pi recorre solicitudes, llamadas y resultados explícitos.

## La rama activa es el contexto de la conversación

Las sesiones son árboles, pero la rama activa proporciona el historial para la siguiente solicitud
al modelo. Pi convierte las entradas de esa ruta en mensajes compatibles con el modelo de usuario,
asistente y resultado de herramienta. La ramificación y la compactación, cubiertas en **Sesiones y
contexto**, por lo tanto afectan lo que contiene la siguiente solicitud sin borrar el historial de
sesión sin procesar.

Esto importa cuando cambias de dirección. Un mensaje no es una instrucción escrita directamente en
la mente de un modelo; se convierte en una entrada persistente de sesión y luego en parte de una
solicitud posterior ensamblada a partir de la rama activa. Cuando la rama cambia, también cambia el
historial que proporciona.

## Dirigir es diferente de hacer seguimiento

Pi acepta nuevas entradas mientras está trabajando, pero el momento cambia el significado:

- Envía con **Enter** para ajustar la tarea actual. El mensaje espera hasta que terminen la
  respuesta actual y sus llamadas de herramientas, y luego guía la siguiente respuesta.
- Envía con **Alt+Enter** para agregar trabajo después de la tarea actual. Esto pone en cola un
  seguimiento hasta que Pi termine el trabajo pendiente.
- Usa **Escape** para abortar la tarea actual. Los mensajes en cola regresan al editor.
- Usa **Alt+Up** para devolver los mensajes en cola al editor sin esperar.

La referencia del bucle del agente describe el mismo límite: la dirección entra después del turno
actual del asistente; los seguimientos entran después de que el agente termina el trabajo pendiente.
Esto conserva una secuencia coherente de resultados de herramientas. También te brinda una forma
práctica de redirigir el trabajo sin destruir el texto que has preparado.

## Las herramientas son capacidades, no un sandbox

El conjunto integrado de herramientas de Pi puede inspeccionar archivos, ejecutar comandos, editar
contenido y escribir archivos. Las extensiones pueden registrar más herramientas. La disponibilidad
de herramientas se envía al modelo como definiciones, pero la ejecución ocurre localmente en el
proceso de Pi.

Eso significa que dos hechos de seguridad son importantes:

- La confianza del proyecto controla si Pi carga la configuración y los recursos del proyecto antes
  de cargar archivos de contexto.
- Las herramientas habilitadas usan los permisos del sistema operativo del proceso de Pi.

La confianza es valiosa, pero **no** aísla las herramientas en un sandbox. Revisa los comandos y
los archivos modificados, y usa un sandbox para trabajo no confiable o no supervisado. La capacidad
del modelo para sugerir un comando no hace que ese comando sea seguro para un repositorio o máquina.

## Por qué los registros son parte del mecanismo

Pi registra respuestas del asistente, llamadas y resultados en la sesión. Eso permite reanudar el
trabajo, reconstruir el contexto, inspeccionar la transcripción y exportar una sesión. También
explica por qué la transcripción puede contener material sensible: los prompts, argumentos de
herramientas, salida de comandos, contenido de archivos y credenciales expuestas durante la
conversación pueden estar presentes. Revísala antes de compartirla o exportarla.

El registro no es solo logging después de los hechos. Pi usa la ruta activa registrada para crear
contexto posterior. En un sistema de agentes, el rastro es parte de cómo se produce el siguiente
paso.

## Errores comunes

- **Esperar que el modelo conozca un archivo sin una ruta de contexto o herramienta.** Pi debe
  incluirlo en el contexto u obtenerlo mediante una herramienta.
- **Leer las llamadas de herramientas como salida decorativa.** Sus resultados a menudo determinan
  si comienza otro turno.
- **Tratar Enter y Alt+Enter como equivalentes mientras se ejecuta trabajo.** Uno dirige; el otro
  programa un seguimiento.
- **Tratar la confianza como un sandbox.** No lo es.

## Pruébalo

Pídele a Pi una tarea inofensiva de solo lectura, como listar un directorio pequeño de documentación
y explicar sus nombres de archivo. Observa la transcripción: identifica tu mensaje, la llamada de
herramienta, su resultado y la respuesta final. Luego imagina que el resultado reveló un archivo
inesperado. Explica por qué Pi necesitaría otra solicitud al modelo para decidir qué hacer con esa
evidencia.
