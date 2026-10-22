---
title: "Trabajo en segundo plano"
description: "Ejecuta y observa trabajo de larga duración sin desperdiciar turnos consultándolo."
module: "Delegación"
---

# Trabajo en segundo plano

Algunos comandos útiles tardan más que un turno de agente: una suite de pruebas, una compilación,
un servidor o un observador que emite actualizaciones significativas con el tiempo. Esperar mal es
sorprendentemente costoso. Si un agente duerme repetidamente y pregunta “¿ya terminó?”, consume
turnos sin aprender nada. Si se bloquea en un comando que debería seguir ejecutándose, no puede
responder al siguiente evento útil.

Gentle Shell proporciona dos mecanismos relacionados para esta situación:
`bash_background` y `monitor`. Ambos trasladan la espera al tiempo de ejecución, donde la
finalización o la salida pueden entregarse de vuelta a la sesión principal. No hacen que un
comando sea inocuo, autorizado o correcto. Los requisitos de alcance y permiso del comando aún
importan. Ejecutar en segundo plano es una estrategia de espera, no una exención de seguridad.

## Una finalización frente a un flujo

Usa **`bash_background`** cuando el evento importante es que un comando termina.
Inicia el comando en segundo plano y despierta al agente una vez cuando el
comando sale. Esto se ajusta al trabajo delimitado, como una ejecución larga de pruebas o una
compilación: la sesión principal puede continuar con trabajo no superpuesto y luego recibe el
resultado del trabajo completado, en lugar de dedicar turnos a revisar un archivo de estado.

Usa **`monitor`** cuando las líneas de salida de un comando de larga duración son en sí mismas
importantes. Un monitor convierte cada línea de salida en un evento. Es adecuado para un proceso
cuyo flujo le indica al agente algo sobre lo que actuar mientras se ejecuta, en lugar de simplemente
producir un resultado final de salida. La diferencia es semántica: la ejecución en segundo plano
pregunta “avísame cuando esto termine”; la supervisión pregunta “avísame a medida que llegue salida
significativa”.

Elegir el equivocado crea ruido o demora. Supervisar una compilación silenciosa ofrece poco
beneficio porque puede no haber una línea útil hasta la finalización. Tratar un observador como un
trabajo en segundo plano de una sola vez pierde la razón por la que lo iniciaste: su
salida continua. Parte de la decisión que necesitas tomar y luego elige la forma de evento que la
proporciona.

## Los eventos reemplazan la consulta

El mecanismo clave es la entrega. La salida de un trabajo en segundo plano, o los eventos de línea
y de detención de un monitor, esperan al enrutador de entrega principal. El tiempo de ejecución
reenvía la finalización como un mensaje de sesión. Si la sesión principal está inactiva, ese mensaje
puede iniciar un nuevo turno; si está ocupada, la entrega espera un límite de turno apropiado. Los
eventos de un monitor que esperan detrás de trabajo ocupado pueden combinarse por monitor, para que
una acumulación no se convierta en una secuencia ilimitada de interrupciones.

Por eso “dormir y luego consultar” es un error. El trabajo ya tiene una vía de notificación.
Consultar consume contexto y turnos sin agregar una fuente nueva de verdad. El mismo principio se
aplica a los subagentes en segundo plano: bajo la política de segundo plano, la sesión principal
conserva el identificador de tarea, termina el turno una vez que ha iniciado trabajo no superpuesto y
espera el mensaje de resultado en lugar de consultar repetidamente el estado de la tarea. Un
subagente termina solo cuando se estabiliza, no simplemente cuando un proceso hijo sale por primera
vez; el tiempo de ejecución aún puede realizar trabajo de seguimiento.

La espera impulsada por eventos también deja clara la responsabilidad. La sesión principal recibe
la información y elige la respuesta. Un monitor nunca le da a su comando el derecho de editar
archivos adicionales, publicar un resultado o tomar una decisión de producto.

## Inspecciona trabajos en el espacio de trabajo

Abre el inspector de trabajos de la sesión con:

```text
/gentle:jobs
```

Muestra los trabajos en segundo plano con el trabajo en ejecución primero y los trabajos más nuevos
primero dentro de cada grupo. La vista incluye estado, comando y final de la salida. En una terminal
estrecha, `Tab` abre los detalles. `s` detiene el trabajo en ejecución seleccionado y `q`
cierra el modal. Los trabajos completados permanecen disponibles para inspección, mientras que el
panel de estado muestra una sección Jobs solo mientras los trabajos están activos. Cuando el panel
está oculto o no está disponible en un diseño compacto, la barra muestra en su lugar la cantidad en
ejecución.

Esos detalles son deliberadamente características de observabilidad. Un comando que se ha puesto
en segundo plano no debería volverse invisible. Antes de actuar sobre una finalización, inspecciona
el resultado: una notificación de salida indica que el proceso terminó; por sí sola no demuestra
que las pruebas pasaron ni que la salida significa lo que esperabas.

## Condiciones de detención y límites de sesión

Una sesión es dueña de sus trabajos. Al cerrar una sesión, los trabajos no sobreviven a la sesión.
Cómo se informa una detención depende de quién detiene el trabajo: un trabajo que el agente detiene
con `job_stop` no envía aviso, mientras que un trabajo que detienes desde `/gentle:jobs` se
informa al agente como detenido por el usuario. Esto evita que un comando olvidado aparezca más
tarde como trabajo realizado por una sesión diferente. En el inspector, detener un trabajo activo es
una acción explícita, no un efecto secundario implícito de cerrar la vista.

Algunos contextos de ejecución no pueden recibir un resultado futuro. El tiempo de ejecución de
subagentes, por ejemplo, rechaza subagentes en segundo plano en modos de una sola ejecución como `pi -p`
y `pi --mode json`, porque esos modos salen antes de que una sesión principal pueda
recibir el resultado. En esos contextos, elige un modo que tenga una sesión principal capaz de
recibir eventos en vez de asumir que “segundo plano” es significativo de manera universal.

## Errores comunes

No uses un `sleep` de shell como bucle de espera. No consultes repetidamente el estado de trabajos o
subagentes solo porque una tarea está en cola o ejecutándose. No inicies el mismo trabajo de nuevo
porque aún no ha terminado. Y no confundas la finalización de un comando con la verificación:
interpreta su resultado de salida y luego realiza la comprobación enfocada que requiera la tarea.

También evita usar un monitor como sustituto de una condición de finalización definida.
Si ninguna línea de salida cambiaría tu decisión, un monitor agrega un flujo que no puedes usar. A
la inversa, no ocultes un flujo de diagnóstico significativo detrás de una espera de una sola vez
cuando líneas oportunas podrían orientar la siguiente etapa.

## Pruébalo

Abre `/gentle:jobs` e inspecciona la sesión sin cambiar nada. Luego elige un comando conocido de
larga duración y responde dos preguntas antes de ejecutarlo en trabajo real: ¿sería suficiente un
resultado de finalización, o cada línea de salida afectaría tu siguiente acción? Elige
`bash_background` para el primer caso y `monitor` para el segundo. Finalmente, indica qué resultado
tendrías que inspeccionar antes de considerar el trabajo exitoso.
