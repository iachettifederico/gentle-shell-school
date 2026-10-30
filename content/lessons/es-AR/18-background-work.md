---
title: "Trabajo en segundo plano"
description: "Ejecutá y observá trabajo de larga duración sin desperdiciar turnos consultándolo."
module: "Delegación"
---

# Trabajo en segundo plano

Algunos comandos útiles tardan más que un turno de agente: una suite de pruebas,
una compilación, un servidor o un observador que emite actualizaciones
significativas con el tiempo. Esperar mal es sorprendentemente costoso. Si un
agente duerme repetidamente y pregunta “¿ya terminó?”, consume turnos sin aprender
nada. Si bloquea en un comando que debería seguir ejecutándose, no puede responder
al próximo evento útil.

Gentle Shell proporciona dos mecanismos relacionados para esta situación:
`bash_background` y `monitor`. Ambos trasladan la espera al tiempo de ejecución,
donde la finalización o la salida pueden entregarse de vuelta a la sesión padre. No
vuelven a un comando inocuo, autorizado ni correcto. Los requisitos de alcance y
permiso del comando siguen importando. Poner en segundo plano es una estrategia de
espera, no una exención de seguridad.

## Una finalización frente a un flujo

Usá **`bash_background`** cuando el evento importante es que un comando termina.
Inicia el comando en segundo plano y despierta al agente una vez cuando el comando
sale. Esto sirve para trabajo acotado, como una ejecución larga de pruebas o una
compilación: el padre puede continuar con trabajo que no se superponga y luego
recibe el resultado del trabajo completado, en lugar de gastar turnos revisando un
archivo de estado.

Usá **`monitor`** cuando las líneas de salida de un comando de larga duración son
importantes en sí mismas. Un monitor convierte cada línea de salida en un evento.
Es apropiado para un proceso cuyo flujo le dice al agente algo sobre lo que puede
actuar mientras se ejecuta, en vez de limitarse a producir un resultado final de
salida. La diferencia es semántica: la ejecución en segundo plano pregunta
“avisame cuando esto termine”; el monitoreo pregunta “avisame cuando llegue una
salida significativa”.

Elegir el incorrecto crea ruido o demora. Monitorear una compilación silenciosa
ofrece poco beneficio porque puede que no haya ninguna línea útil hasta que termine.
Tratar un observador como un trabajo de segundo plano de una sola vez pierde la
razón por la que lo iniciaste: su salida continua. Partí de la decisión que
necesitás tomar y luego elegí la forma de evento que la proporciona.

## Los eventos reemplazan la consulta

El mecanismo clave es la entrega. La salida de un trabajo en segundo plano, o los
eventos de línea y de detención de un monitor, esperan al enrutador de entrega del
padre. El tiempo de ejecución reenvía la finalización como un mensaje de sesión. Si
el padre está inactivo, ese mensaje puede iniciar un nuevo turno; si está ocupado,
la entrega espera un límite de turno apropiado. Los eventos de monitor que esperan
detrás de trabajo ocupado pueden agruparse por monitor, para que una acumulación no
se convierta en una secuencia ilimitada de interrupciones.

Por eso “dormir y luego consultar” es un error. El trabajo ya tiene una ruta de
notificación. Consultar consume contexto y turnos sin agregar ninguna fuente nueva
de verdad. El mismo principio se aplica a los subagentes en segundo plano: bajo la
política de segundo plano, el padre conserva el identificador de tarea, termina el
turno una vez que lanzó trabajo que no se superpone y espera el mensaje de resultado
en lugar de consultar repetidamente el estado de la tarea. Un subagente termina
solo cuando se asienta, no meramente cuando un proceso hijo sale por primera vez; el
tiempo de ejecución puede todavía realizar trabajo de seguimiento.

La espera dirigida por eventos también deja clara la responsabilidad. La sesión
padre recibe la información y elige la respuesta. Un monitor nunca le da a su
comando el derecho de editar archivos adicionales, publicar un resultado o tomar
una decisión de producto.

## Inspeccioná trabajos en el espacio de trabajo

Abrí el inspector de trabajos de la sesión con:

```text
/gentle:jobs
```

Muestra los trabajos en segundo plano con el trabajo en ejecución primero y los
trabajos más nuevos primero dentro de cada grupo. La vista incluye estado, comando
y cola de salida. En una terminal angosta, `Tab` abre detalles. `s` detiene el
trabajo en ejecución seleccionado y `q` cierra el modal. Los trabajos completados
siguen disponibles ahí para inspección. El pie muestra `⧗ N jobs` mientras algún
trabajo corre. En pantalla completa con 140 columnas o más, los trabajos en
ejecución también tienen su propia tarjeta plegable `⧗ Jobs` en el riel, una fila
por trabajo con su tiempo transcurrido, el más nuevo primero. Los trabajos
terminados quedan en esa tarjeta 60 segundos con su resultado (`✓` salida limpia,
`✗` falla, `–` detenido) y después la tarjeta se vacía sola. `ctrl+shift+j` o un
clic en su encabezado la contrae.

Esos detalles son deliberadamente funciones de observabilidad. Un comando que se
puso en segundo plano no debería volverse invisible. Antes de actuar sobre una
finalización, inspeccioná el resultado: una notificación de salida dice que el
proceso terminó; por sí sola no demuestra que las pruebas pasaron ni que la salida
significa lo que esperabas.

## Condiciones de detención y límites de sesión

Una sesión es dueña de sus trabajos. Al cerrarse la sesión, los trabajos no la
sobreviven. La forma en que se informa una detención depende de quién detiene el
trabajo: un trabajo que el agente detiene con `job_stop` no envía aviso, mientras
que un trabajo que vos detenés desde `/gentle:jobs` se informa al agente como
detenido por la persona usuaria. Esto evita que un comando olvidado aparezca más
tarde como trabajo realizado por una sesión diferente. En el inspector, detener un
trabajo activo es una acción explícita, en vez de un efecto secundario implícito de
cerrar la vista.

Algunos contextos de ejecución no pueden recibir un resultado futuro. El tiempo de
ejecución de subagentes, por ejemplo, rechaza subagentes en segundo plano en modos
de ejecución única como `pi -p` y `pi --mode json`, porque esos modos salen antes
de que una sesión padre pueda recibir el resultado. En esos contextos, elegí un modo
que tenga un padre capaz de recibir eventos, en vez de asumir que “en segundo plano”
tiene significado universal.

## Errores frecuentes

No uses un `sleep` de shell como un bucle de espera. No consultes repetidamente el
estado de un trabajo o subagente solo porque una tarea está en cola o ejecutándose.
No lances el mismo trabajo otra vez porque todavía no terminó. Y no confundas la
finalización de un comando con verificación: interpretá su resultado de salida y
luego realizá la comprobación enfocada que requiera la tarea.

También evitá usar un monitor como sustituto de una condición de finalización
definida. Si ninguna línea de salida cambiaría tu decisión, un monitor agrega un
flujo que no podés usar. A la inversa, no ocultes un flujo de diagnóstico
significativo detrás de una espera de una sola vez cuando las líneas oportunas
podrían guiar el siguiente paso.

## Probalo

Abrí `/gentle:jobs` e inspeccioná la sesión sin cambiar nada. Luego elegí un comando
de larga duración que conozcas y respondé dos preguntas antes de ejecutarlo en
trabajo real: ¿un único resultado de finalización sería suficiente, o cada línea de
salida afectaría tu próxima acción? Elegí `bash_background` para el primer caso y
`monitor` para el segundo. Por último, indicá qué resultado necesitarías
inspeccionar antes de considerar exitoso el trabajo.
