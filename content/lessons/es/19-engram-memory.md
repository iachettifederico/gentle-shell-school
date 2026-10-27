---
title: "Memoria de Engram"
description: "Usa memoria persistente opcional para conservar contexto verificado entre sesiones de Pi."
module: "Memoria y habilidades"
---

# Memoria de Engram

Una conversación es útil mientras está abierta, pero un esfuerzo de desarrollo real a menudo
sobrevive a una conversación. Una terminal se cierra, una sesión se compacta o un nuevo
agente necesita continuar el trabajo sin volver a descubrir cada decisión. La memoria persistente
aborda ese problema de continuidad: le da a un agente un lugar donde conservar
hechos pequeños, reutilizables y verificados, y progreso recuperable entre sesiones de Pi.

Primero, mantén claro el límite. **gentle-pi no proporciona memoria persistente
por sí solo.** Una instalación incluida de Gentle Shell ya trae Engram. En Pi, Engram se
ofrece mediante el paquete complementario opcional `gentle-engram`, que se instala en un
directorio de inicio de Pi con:

```bash
pi install npm:gentle-engram
```

Si faltan las herramientas de memoria, averigua por qué antes de instalar nada. Gentle Shell
desactiva la memoria, con un aviso, cuando no puede verificar que un servidor de Engram en
ejecución o su almacén sean compatibles; en ese caso hay que actualizar y reiniciar el servidor
global de Engram más antiguo. Revisa primero qué home usa la sesión y lee ese aviso.

La presencia de ese comando no demuestra que la memoria esté activa en una sesión
específica. Revisa las herramientas disponibles de la sesión antes de depender de ella. Cuando las
herramientas de memoria están activas, el agente puede guardar decisiones, correcciones de errores, descubrimientos,
prompts de usuario y resúmenes de sesión para sesiones posteriores. Cuando no están
activas, los archivos ordinarios y la sesión actual siguen siendo la evidencia disponible.
Por eso la memoria debería mejorar un flujo de trabajo, no convertirse en un requisito no documentado
para terminar trabajo rutinario.

## La memoria complementa la evidencia del repositorio

Engram es más valioso cuando conserva *significado*, no una copia de todo lo
que ocurrió. Una observación guardada útil es una conclusión concisa y verificada:
qué cambió, por qué fue necesario, dónde aplica y cualquier caso límite
importante. Es un mal lugar para volcados de código sin procesar, conclusiones especulativas,
credenciales o datos personales. El guardado debería seguir siendo comprensible al leerlo
semanas después y debería señalar la fuente de verdad: un documento de tarea,
ruta del repositorio, resultado de prueba u otra evidencia actual.

Esta distinción importa porque la memoria y un repositorio tienen trabajos diferentes.
Git y los archivos hacen que la implementación sea inspeccionable. El documento de funcionalidad de ODD
registra el trabajo acordado actual. La memoria ayuda a un agente a encontrar ese trabajo y a llevar
adelante un relato compacto y consultable sobre él. No debe reemplazar silenciosamente un
archivo, inventar un estado actual a partir de una nota antigua ni autorizar un cambio más amplio.

Para trabajo grande de ODD, el par duradero es explícitamente deliberado:

1. el documento de funcionalidad local, como `odd/tasks/<feature-name>.md`; y
2. un espejo de Engram bajo el tema con alcance de proyecto
   `odd/<feature-name>/tasks`.

El espejo incluye el documento actual completo y su localizador relativo al repositorio,
en lugar de un mensaje de finalización impreciso. Primero se escribe el documento local. Luego el
espejo se actualiza mediante la herramienta de guardado de memoria disponible, y ambas escrituras
se leen de vuelta. No son una transacción atómica, por lo que una escritura de archivo exitosa no demuestra
que la escritura en memoria también haya tenido éxito.

Una `topic_key` da a las observaciones relacionadas una identidad estable. En el patrón ODD,
el tema de la funcionalidad mantiene las copias sucesivas de una funcionalidad asociadas con esa
funcionalidad en lugar de mezclarlas con trabajo no relacionado. El registro de habilidades ofrece
otro ejemplo documentado: usa la clave estable `skill-registry` cuando la memoria está disponible.
Un tema estable es una ayuda de recuperación, no permiso para sobrescribir un registro no relacionado.

## Una secuencia de recuperación, no una suposición

Cuando se reanuda una funcionalidad interrumpida, no empieces desde la entrada de memoria que parezca
más reciente. Eso puede revivir una suposición obsoleta u omitir una actualización local.
El orden de recuperación documentado es:

1. usa `mem_context` para establecer el contexto de memoria relevante;
2. usa `mem_search` con alcance de proyecto y funcionalidad;
3. recupera la observación guardada completa con `mem_get_observation`;
4. lee el documento de funcionalidad real; luego
5. reconcilia los requisitos, el código actual y la prueba registrada antes de continuar
   con la siguiente tarea sin terminar.

El orden pone la evidencia actual e inspeccionable del proyecto junto al contexto recuperado.
Si el archivo local y el espejo no coinciden, conserva ambas versiones y presenta el conflicto
real en lugar de elegir según una marca de tiempo. Un espejo faltante no es permiso para sobrescribir el archivo
que sobrevivió. Del mismo modo, un servicio de Engram no disponible no bloquea trabajo seguro no relacionado:
conserva el progreso local, indica que el espejo está pendiente y vuelve a sincronizarlo después en lugar de afirmar que tuvo éxito.

`mem_session_summary` tiene un propósito diferente pero relacionado. Un resumen de sesión
registra una entrega concisa al final de una sesión: el objetivo, restricciones,
descubrimientos, trabajo completado, próximos pasos y archivos relevantes. Reduce el
costo de retomar una conversación después, mientras que el documento de tarea sigue siendo el
plan estructurado para una funcionalidad grande. Esto complementa la lección de **Sesiones** de Pi:
Pi puede compactar el contexto conversacional, mientras que la memoria persistente está destinada a
sobrevivir entre sesiones cuando el complemento opcional está disponible.

## Guarda selectivamente y con alcance

Una buena regla es guardar una observación después de un evento significativo y verificado: una corrección de error, una decisión de diseño, un descubrimiento no obvio del código base, un cambio de configuración o una convención de proyecto reutilizable. Guarda conclusiones, no una transcripción.
Por ejemplo, una migración completada de un documento de funcionalidad podría representarse
como una observación compacta vinculada a su proyecto y tema, no como cada resultado de herramienta
que llevó a ella.

El límite de permisos sigue siendo importante. Las instrucciones explícitas de no guardar o no persistir prevalecen. El tratamiento documentado del modo Auto para la memoria vinculada a tareas
también excluye secretos, eliminación, mantenimiento, escrituras personales/globales o entre proyectos, y sobrescrituras de claves de tema no relacionadas. En ese modo, una escritura de memoria de proyecto que califica necesita un proyecto actual resuelto correctamente y un guardado o resumen de sesión posterior que proporcione el mismo proyecto y directorio de trabajo.
Un nombre de proyecto declarado por sí solo no basta.

## Pruébalo

En una sesión donde las herramientas de memoria sean visibles, pídele al agente que nombre —sin imprimir— las
herramientas de memoria disponibles. Luego describe un hecho real y no sensible que quisieras que
una sesión futura supiera, como una convención de proyecto confirmada. Explica su
alcance de proyecto y tema estable antes de guardar nada. Finalmente, imagina que el servicio de
memoria no está disponible: anota qué permanece en el repositorio y qué debería marcarse como pendiente.

El objetivo no es guardar más. Es hacer más fácil recuperar la próxima acción segura:
localizar el trabajo correcto, verificarlo frente al repositorio y continuar
sin confundir el contexto recordado con una prueba.
