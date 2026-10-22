---
title: "Cuestionario y verificación de configuración"
description: "Prueba un cuestionario y confirma tu comando local de gentle-shell."
module: "Demo"
---

# Prueba un cuestionario y una verificación real

Este curso demo local ahora muestra los dos tipos de interacción que hacen que
una lección sea activa. Primero, tu agente hace una pregunta breve. Úsala como
una conversación: responde con tus propias palabras y pide una explicación si
la respuesta no es clara. La pregunta de esta lección trata sobre el comando que
imprime la versión instalada de gentle-shell.

Luego viene una verificación de configuración real. En una terminal, ejecuta:

```sh
gentle-shell --version
```

Una verificación exitosa imprime una cadena de versión. Tu agente debe esperar
a que ejecutes el comando y confirmes esa salida, en lugar de asumir que tu
configuración está lista. Si el comando no imprime una versión, detente aquí e
investiga con tu agente.

La verificación solo lee la versión del programa instalado; no cambia tu
máquina. Este es un **curso demo local**, así que puedes repetir con seguridad
el cuestionario y el comando mientras exploras cómo funciona la tutoría.
