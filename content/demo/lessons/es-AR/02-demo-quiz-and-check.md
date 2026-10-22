---
title: "Cuestionario y comprobación de configuración"
description: "Probá un cuestionario y confirmá tu comando local de gentle-shell."
module: "Demo"
---

# Probá un cuestionario y una comprobación real

Este curso de demostración local ahora muestra los dos tipos de interacción que
hacen activa a una lección. Primero, tu agente te hace una pregunta breve. Usala
como una conversación: respondé con tus propias palabras y pedí una explicación si
la respuesta no está clara. La pregunta de esta lección trata sobre el comando que
muestra la versión instalada de gentle-shell.

Después viene una comprobación de configuración real. En una terminal, ejecutá:

```sh
gentle-shell --version
```

Una comprobación exitosa muestra una cadena de versión. Tu agente debería esperar
a que ejecutes el comando y confirmes esa salida, en lugar de asumir que tu
configuración está lista. Si el comando no muestra una versión, detenete acá e
investigalo con tu agente.

La comprobación solo lee la versión del programa instalado; no cambia tu
máquina. Este es un **curso de demostración local**, así que podés repetir con
seguridad el cuestionario y el comando mientras explorás cómo funciona la tutoría.
