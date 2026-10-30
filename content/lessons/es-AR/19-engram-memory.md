---
title: "Memoria de Engram"
description: "Usá memoria persistente opcional para preservar contexto verificado entre sesiones de Pi."
module: "Memoria y habilidades"
---

# Memoria de Engram

Una conversación es útil mientras está abierta, pero un esfuerzo de desarrollo real
a menudo dura más que una conversación. Una terminal se cierra, una sesión se
compacta o un nuevo agente necesita continuar el trabajo sin redescubrir cada
decisión. La memoria persistente aborda ese problema de continuidad: le da a un
agente un lugar para conservar hechos pequeños, reutilizables y verificados, y
progreso recuperable entre sesiones de Pi.

Primero, mantené claro el límite. **gentle-pi no proporciona memoria persistente
por sí solo.** Una instalación empaquetada de Gentle Shell ya trae Engram. En Pi,
Engram lo proporciona el paquete complementario opcional `gentle-engram`, que se
instala en un inicio de Pi con:

```bash
pi install npm:gentle-engram
```

Si faltan las herramientas de memoria, averiguá por qué antes de instalar nada.
Un Gentle Shell empaquetado (el que instala el instalador web) comparte el
servidor global de Engram en `127.0.0.1:7437`, el mismo
que usan los hooks de otros agentes. Cuando no hay nadie escuchando ahí y su núcleo
de Engram fijado está verificado, Shell lo inicia como un `engram serve` desacoplado,
así que en ese caso normal nunca iniciás el servidor vos mismo. Un almacén existente
no desactiva la memoria por sí solo, sin importar quién lo creó. Shell desactiva la
memoria para ese inicio, con un aviso, cuando no hay nadie escuchando y falta el núcleo
incluido o no está verificado, no puede verificar un servidor que escucha (por ejemplo,
uno más viejo o protegido con token), el servidor nunca informa que está listo, o el
almacén proviene de un esquema de Engram más nuevo; en el caso de esquema más nuevo no
inicia ningún servidor. También desactiva la memoria cuando se establece `ENGRAM_BIN`, `ENGRAM_URL`,
`ENGRAM_PORT`, `ENGRAM_SOCKET`, `ENGRAM_DATA_DIR`, `ENGRAM_DATABASE_URL`,
`ENGRAM_SERVER_MODE` o una `ENGRAM_STARTUP_POLICY` no válida; Shell nunca sondea ni
inicia un servidor para esas selecciones explícitas. Shell nunca detiene ni reemplaza
un servidor que está escuchando, así que tenés que actualizar y reiniciar vos un
servidor global más viejo, y un almacén con esquema más nuevo requiere que inicies
vos mismo el servidor más nuevo. Fijate primero qué home usa la sesión y leé ese aviso.

La presencia de ese comando no prueba que la memoria esté activa en una sesión en
particular. Mirá las herramientas disponibles de la sesión antes de depender de
ella. Cuando las herramientas de memoria están activas, el agente puede guardar
decisiones, correcciones de bugs, descubrimientos, indicaciones de la persona
usuaria y resúmenes de sesión para sesiones posteriores. Cuando no están activas,
los archivos comunes y la sesión actual siguen siendo la evidencia disponible. Por
eso la memoria debería mejorar un flujo de trabajo, no convertirse en un requisito
no documentado para terminar trabajo rutinario.

## La memoria complementa la evidencia del repositorio

Engram es más valioso cuando preserva *significado*, no una copia de todo lo que
pasó. Una observación guardada útil es una conclusión concisa y verificada: qué
cambió, por qué era necesario, dónde se aplica y cualquier caso límite importante.
Es un mal lugar para volcados de código fuente sin procesar, conclusiones
especulativas, credenciales o datos personales. El guardado debería seguir siendo
comprensible al leerlo semanas después y debería señalar la fuente de verdad: un
documento de tarea, una ruta del repositorio, el resultado de una prueba u otra
evidencia actual.

Esta distinción importa porque la memoria y un repositorio tienen trabajos
diferentes. Git y los archivos vuelven inspeccionable la implementación. El
documento de funcionalidad ODD registra el trabajo acordado actual. La memoria
ayuda a un agente a encontrar ese trabajo y conservar un relato compacto y buscable
de él. No debe reemplazar silenciosamente un archivo, inventar un estado actual a
partir de una nota vieja ni autorizar un cambio más amplio.

Para trabajo ODD grande, el par duradero es explícito deliberadamente:

1. el documento de funcionalidad local, como `odd/tasks/<feature-name>.md`; y
2. un espejo de Engram bajo el tema con alcance de proyecto
   `odd/<feature-name>/tasks`.

El espejo incluye el documento actual completo y su localizador relativo al
repositorio, en lugar de un mensaje de finalización vago. El documento local se
escribe primero. Luego, el espejo se actualiza mediante la herramienta disponible
de guardado de memoria, y ambas escrituras se vuelven a leer. No son una transacción
atómica, por lo que una escritura de archivo exitosa no prueba que la escritura de
memoria también haya tenido éxito.

Una `topic_key` da a las observaciones relacionadas una identidad estable. En el
patrón ODD, el tema de la funcionalidad mantiene asociadas con esa funcionalidad
las copias sucesivas de una funcionalidad, en vez de mezclarlas con trabajo no
relacionado. El registro de habilidades ofrece otro ejemplo documentado: usa la
clave estable `skill-registry` cuando hay memoria disponible. Un tema estable es
una ayuda para la recuperación, no permiso para sobrescribir un registro no
relacionado.

## Una secuencia de recuperación, no una suposición

Cuando se reanuda una funcionalidad interrumpida, no empieces por la entrada de
memoria que parezca más nueva. Eso puede revivir una suposición obsoleta u omitir
una actualización local. El orden de recuperación documentado es:

1. usá `mem_context` para establecer el contexto de memoria relevante;
2. usá `mem_search` con alcance de proyecto y funcionalidad;
3. recuperá la observación guardada completa con `mem_get_observation`;
4. leé el documento de funcionalidad real; y después
5. reconciliá los requisitos, el código actual y la prueba registrada antes de
   continuar con la siguiente tarea sin terminar.

El orden coloca la evidencia actual e inspeccionable del proyecto junto al contexto
recuperado. Si el archivo local y el espejo no coinciden, preservá ambas versiones
y exponé el conflicto real en vez de elegir según una marca de tiempo. Un espejo
faltante no es permiso para sobrescribir el archivo que sobrevivió. Del mismo modo,
un servicio Engram no disponible no bloquea trabajo seguro no relacionado: conservá
el progreso local, indicá que el espejo está pendiente y resincronizá más tarde en
vez de afirmar que tuvo éxito.

`mem_session_summary` tiene un propósito diferente pero relacionado. Un resumen de
sesión registra una entrega concisa al final de una sesión: el objetivo, las
restricciones, los descubrimientos, el trabajo completado, los siguientes pasos y
los archivos relevantes. Reduce el costo de retomar una conversación más tarde,
mientras que el documento de tarea sigue siendo el plan estructurado para una
funcionalidad grande. Esto complementa la lección **Sesiones** de Pi: Pi puede
compactar el contexto conversacional, mientras que la memoria persistente está
pensada para sobrevivir entre sesiones cuando el complemento opcional está
disponible.

## Guardá selectivamente y con alcance

Una buena regla es guardar una observación después de un evento significativo y
verificado: una corrección de bug, una decisión de diseño, un descubrimiento no
obvio de la base de código, un cambio de configuración o una convención de proyecto
reutilizable. Guardá conclusiones, no una transcripción. Por ejemplo, una migración
completada de un documento de funcionalidad podría representarse como una
observación compacta vinculada a su proyecto y tema, no como cada resultado de
herramienta que llevó a ella.

El límite de permisos sigue siendo importante. Las instrucciones explícitas de no
guardar o no persistir prevalecen. El tratamiento documentado del modo Auto para la
memoria vinculada a tareas también excluye secretos, eliminación, mantenimiento,
escrituras personales, globales o entre proyectos, y sobrescrituras de claves de
tema no relacionadas. En ese modo, una escritura de memoria de proyecto que cumple
los requisitos necesita un proyecto actual resuelto correctamente y un guardado o
resumen de sesión posterior que proporcione el mismo proyecto y directorio de
trabajo. Un nombre de proyecto autoafirmado no es suficiente.

## Probalo

En una sesión donde las herramientas de memoria estén visibles, pedile al agente que
nombre—sin imprimir—las herramientas de memoria disponibles. Luego describí un
hecho real y no sensible que te gustaría que conociera una sesión futura, como una
convención de proyecto confirmada. Explicá su alcance de proyecto y tema estable
antes de guardar nada. Por último, imaginá que el servicio de memoria no está
disponible: anotá qué queda en el repositorio y qué debería marcarse como pendiente.

El objetivo no es guardar más. Es hacer más fácil de recuperar la próxima acción
segura: ubicar el trabajo correcto, verificarlo contra el repositorio y continuar
sin confundir contexto recordado con prueba.
