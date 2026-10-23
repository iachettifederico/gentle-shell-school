---
title: "Bienvenida"
description: "Conocé Gentle Shell School y cómo cualquier agente de programación puede iniciar tu curso."
module: "Primeros pasos"
---

Te damos la bienvenida a **Gentle Shell School**, un curso gratuito y a tu
ritmo para aprender gentle-shell: el entorno para agentes de programación
construido sobre Pi.

## Cómo funciona este curso

Cada lección tiene dos audiencias:

- **Vos** leés la lección acá, en el sitio web.
- **Tu agente** lee la misma lección mediante la API del curso. Cada lección
  incluye instrucciones que le indican al agente cómo se ve el resultado
  "terminado" y cómo comprobarlo.

Cualquier agente de programación puede iniciar el curso. Te explica cada tema,
hace preguntas de cuestionario cuando corresponde y verifica tu configuración
real antes de marcar una lección como completada. Si ese primer agente no es
gentle-shell, las dos lecciones siguientes te ayudan a instalar y abrir Gentle
Shell, y después transfieren el progreso de tu curso a su agente.

¿Ya usás gentle-shell? Si querés, podés instalar el paquete tutor del curso.
Agrega el comando `/school`, y la última lección muestra cómo sacarlo cuando
termines. Instalalo, reiniciá Gentle Shell y después usá `/school` para empezar
o continuar el curso:

```sh
gentle-shell install git:github.com/iachettifederico/gentle-shell-school
```

Usá `gentle-shell install`, no `pi install`: `pi install` escribe en el
directorio predeterminado de Pi (`~/.pi/agent`), que Gentle Shell no lee. En Pi
sin Gentle Shell, usá `pi install git:github.com/iachettifederico/gentle-shell-school`.

¿Encontraste un problema? Tu agente puede reportarlo como un issue de GitHub con
tu consentimiento, o podés usar el enlace "Reportar un problema".

## Empezá el curso

Pedile a cualquier agente de programación:

```text
Read {origin}/llms.txt and start the course.
```
