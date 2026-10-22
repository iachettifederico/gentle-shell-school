---
title: "Abre Gentle Shell"
description: "Inicia Gentle Shell y entrega el progreso de tu curso a su agente tutor."
module: "Primeros pasos"
---

# Abre Gentle Shell

Has confirmado que el iniciador `gentle-shell` está disponible. Ahora ábrelo y entrega
a su agente la única información que lleva tu curso adelante: tu ID anónimo de estudiante
de Gentle Shell School. El ID no es una cuenta ni un inicio de sesión. Es la clave de
progreso del curso, para que el nuevo agente tutor pueda leer lo que ya completaste.

## Inicia el espacio de trabajo

En una terminal, ejecuta:

```bash
gentle-shell
```

Esto abre Pi con el paquete de Gentle Shell cargado. El iniciador normalmente usa su
propio home de agente aislado, por lo que puede configurar su espacio de trabajo sin
editar un agente Pi existente. Espera hasta que la sesión interactiva esté lista antes
de pegar el prompt de entrega.

## Lleva tu progreso adelante

Tu tutor actual ya debería conocer tu ID de estudiante porque te inscribió. Pídele que
te muestre el ID si no lo tienes. Antes de salir de esta conversación, registra esta
lección como completada. Luego pega este prompt en la nueva sesión de Gentle Shell,
reemplazando `<id>` por tu ID de estudiante real:

```text
Read {origin}/llms.txt. My Gentle Shell School student ID is <id>. Continue the course.
```

El prompt proporciona al nuevo agente tanto las instrucciones del curso como tu clave
de progreso. Debería leer las instrucciones del curso, usar ese ID cuando solicite tus
instrucciones específicas de estudiante y continuar con la siguiente lección incompleta.

Opcionalmente, instala primero el paquete del tutor del curso en Gentle Shell. Convierte
las instrucciones del curso en una skill y añade el comando `/school`:

```sh
gentle-shell install git:github.com/iachettifederico/gentle-shell-school
```

Reinicia Gentle Shell y luego usa `/school` con el mismo prompt de entrega.

## Por qué importa el orden

No confíes en que el nuevo agente adivine qué ocurrió en esta conversación. El agente
anterior registra esta lección *antes* de la entrega, usando la API del curso con
`source: "agent"`. Esto hace que el registro de progreso sea independiente del historial
de chat de cualquiera de los agentes. Si cierras una terminal, cambias de modelo o
retomas más tarde, el mismo ID aún identifica el mismo progreso del curso.

Si el comando no inicia Gentle Shell, vuelve a **Instala Gentle Shell** y repite su
verificación de versión. Si Gentle Shell se abre pero el nuevo agente no continúa
correctamente, pega de nuevo el prompt de entrega con el mismo ID en lugar de crear una
nueva inscripción.

## Pruébalo

Haz que tu agente actual confirme que registró esta lección. Abre `gentle-shell`, pega
el prompt preparado con tu ID y deja que el nuevo agente continúe con **Las capas de
Gentle Shell**.
