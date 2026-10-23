---
title: "Abrí Gentle Shell"
description: "Iniciá Gentle Shell y entregale el progreso de tu curso a su agente tutor."
module: "Primeros pasos"
---

# Abrí Gentle Shell

Ya confirmaste que el lanzador `gentle-shell` está disponible. Ahora abrilo y
dale a su agente la única información que lleva tu curso hacia adelante: tu ID
anónimo de estudiante de Gentle Shell School. El ID no es una cuenta ni un
inicio de sesión. Es la clave de progreso del curso, para que el nuevo agente
tutor pueda leer lo que ya completaste.

## Iniciá el espacio de trabajo

En una terminal, ejecutá:

```bash
gentle-shell
```

Eso abre Pi con el paquete Gentle Shell cargado. El lanzador normalmente usa su
propio home de agente aislado, así que puede configurar su espacio de trabajo
sin editar un agente Pi existente. Esperá hasta que la sesión interactiva esté
lista antes de pegar el prompt de transferencia.

## Llevá tu progreso adelante

Tu tutor actual ya debería conocer tu ID de estudiante porque te inscribió.
Pedile que te muestre el ID si no lo tenés. Antes de salir de esta conversación,
registra esta lección como completada. Después pegá este prompt en la nueva
sesión de Gentle Shell, reemplazando `<id>` con tu ID real de estudiante:

```text
Read {origin}/llms.txt. My Gentle Shell School student ID is <id>. Continue the course.
```

El prompt le da al nuevo agente tanto las instrucciones del curso como tu clave
de progreso. Debe leer las instrucciones del curso, usar ese ID al solicitar tus
instrucciones específicas como estudiante y continuar en la siguiente lección
incompleta.

Opcionalmente, instalá primero el paquete tutor del curso en Gentle Shell.
Convierte las instrucciones del curso en una skill y agrega el comando
`/school`:

```sh
gentle-shell install git:github.com/iachettifederico/gentle-shell-school
```

Reiniciá Gentle Shell y luego usá `/school` con el mismo prompt de transferencia.
El paquete es opcional; cuando termines el curso, sacalo con
`gentle-shell remove git:github.com/iachettifederico/gentle-shell-school`.

## Por qué importa el orden

No confíes en que el nuevo agente adivine qué pasó en esta conversación. El
agente anterior registra esta lección *antes* de la transferencia, usando la API
del curso con `source: "agent"`. Eso hace que el registro de progreso sea
independiente del historial de chat de cualquiera de los agentes. Si cerrás una
terminal, cambiás de modelo o retomás más tarde, el mismo ID sigue identificando
el mismo progreso del curso.

Si el comando no inicia Gentle Shell, volvé a **Instalá Gentle Shell** y repetí
su comprobación de versión. Si Gentle Shell se abre pero el nuevo agente no
continúa correctamente, pegá otra vez el prompt de transferencia con el mismo
ID en lugar de crear una inscripción nueva.

## Probalo

Pedile a tu agente actual que confirme que registró esta lección. Abrí
`gentle-shell`, pegá el prompt preparado con tu ID y dejá que el nuevo agente
continúe con **Las capas de Gentle Shell**.
