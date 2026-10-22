---
title: "Coordinación entre sesiones"
description: "Coordina las sesiones activas del orquestador sin confundir los metadatos con la autoridad."
module: "Usuario avanzado"
---

# Coordinación entre sesiones

Una segunda sesión de agente puede ser útil mucho antes de que edite algo. Puedes
tener una sesión investigando un fallo, otra preparando una revisión y una tercera
trabajando en otro repositorio. El problema difícil no es abrir esas sesiones; es
aprender si el trabajo cercano importa sin fingir que los nombres, las ventanas o un
estado anterior implican permiso.

Gentle Shell trata esto como **metadatos de coordinación**. Una sesión puede publicar
un asunto reconocible, una pequeña instantánea de progreso seleccionada y una
clasificación de trabajo acotada. Otras sesiones pueden listar o buscar ese material
publicado, luego consultarlo o enviar un mensaje específico cuando quede una pregunta
real. Esto hace que la coordinación sea menos costosa que copiar transcripciones y más
segura que asumir que un par que parece activo es propietario de un archivo.

Esta lección amplía **Subagents**, no lo reemplaza. Una tarea secundaria tiene un
progenitor y una entrega declarada. Una sesión par es un orquestador que se ejecuta de
forma independiente. Sus metadatos públicos son descriptivos, no una instrucción,
concesión, bloqueo, comprobante de revisión ni prueba de que pueda recibir tu mensaje.

## Empieza con un asunto

Antes de delegar o coordinar trabajo que sea más que una pequeña tarea directa, llama a
`orchestrator_session_id` con un `subject` corto y no sensible. La herramienta
devuelve un ID de enrutamiento estable, un alias de tarea actual, un alias de tarea
inicial y un nombre de sesión humano. Los alias hacen comprensible una lista de pares;
el ID estable es lo que identifica a un destinatario para una operación específica.

Un asunto está limitado deliberadamente. Se normaliza y acota, y no debe contener un
prompt ni un secreto. Declararlo puede establecer un nombre de sesión de Pi solo cuando
ese nombre canónico está vacío, por lo que se conserva un cambio de nombre humano
posterior. El primer asunto explícito permanece como el alias inicial en esa rama; una
declaración posterior actualiza el alias actual. Ninguno de los alias se convierte en
una identidad ni en una decisión de control de acceso.

Publica solo lo que otra sesión necesita para evitar una colisión o hacer una mejor
pregunta. La misma llamada puede llevar un pequeño objeto `state` con `objective`,
`progress`, `decisions` y `blockers`. También puede llevar trabajo clasificado de
forma explícita, como un área, tema, etiquetas y referencias de issue o PR calificadas
por repositorio. Trata esto como un reemplazo, no como un parche: incluye cada campo
que deba permanecer público. Al completarlo, publica el resultado y el siguiente
alcance, o retira el estado en lugar de dejar una tarea completada con apariencia de
estar activa.

No pongas historial privado, credenciales, prompts sin procesar ni instrucciones
internas en estos metadatos. La implementación almacena un registro personalizado,
acotado y sin contexto para la rama activa; no explora tu transcripción para fabricar
un informe de estado. Esa distinción protege tanto la privacidad como el significado.

## Descubre primero, infiere con prudencia

`orchestrator_list` sin argumentos enumera pares. Es útil para ver orquestadores
recientes del mismo perfil y sus etiquetas de visualización, contexto de espacio de
trabajo y resúmenes acotados de tareas secundarias sin terminar. Una sesión también
puede solicitar una búsqueda de trabajo clasificado con un filtro explícito. Los
filtros pueden combinar área, tema, etiqueta, texto literal, una referencia tipada
exacta o una raíz de repositorio registrada.

El resultado tiene un significado negativo importante. La presencia reciente es una
ventana de latido, no una prueba de accesibilidad. Un espacio de trabajo registrado es
un hecho de inicio, no una identidad canónica de repositorio ni un bloqueo de escritor
exclusivo. Las páginas omitidas, desconocidas, sin clasificar y pendientes significan
que la lista no es exhaustiva. Una posible superposición de área o etiqueta es solo
una posible superposición; no establece una dependencia ni un permiso.

Esa moderación es el mecanismo que hace que sea seguro usar una lista. En vez de
inventar propiedad global a partir de un panel conveniente, hace visible la
incertidumbre. Si necesitas contexto exacto de un par listado, conserva el ID de sesión
estable completo que devuelve la herramienta. No selecciones un par por un ID de
visualización recortado ni por un alias.

## Consulta y luego envía mensajes solo cuando sea necesario

`orchestrator_consult` tiene dos vías. La vía de metadatos predeterminada lee la
instantánea publicada del destinatario. No despierta al propietario, inicia un
ayudante, hace una llamada al modelo ni lee transcripciones privadas. Devuelve una
instantánea separada y acotada con marcas de tiempo históricas y elementos
desconocidos explícitos. Úsala primero para preguntas como “¿qué trabajo publicó esta
sesión?” o “¿qué alcance de repositorio registró?”

La vía de razonamiento es deliberadamente diferente. Hace a un modelo configurado una
pregunta acotada y de solo lectura sobre una instantánea pública seleccionada. Como
cuesta dinero, una interfaz de usuario interactiva debe obtener permiso para el costo
del modelo; los contextos sin interfaz fallan de forma cerrada. Su respuesta es un
consejo, no una respuesta del propietario, autoridad ni consentimiento. La prosa de un
modelo no puede conceder un permiso que el propietario original no publicó.

Cuando ninguna vía responde tu pregunta, envía un mensaje específico mediante las
herramientas de coordinación con el ID estable del par y un motivo concreto. Un mensaje
en cola solo significa que está en cola, no que fue entregado ni leído. No conviertas la
falta de respuesta en evidencia de que el par está inactivo o de que sus archivos están
disponibles para que los cambies.

## Una secuencia práctica

Imagina que dos sesiones tocan la autenticación. Primero, dale a la tuya un asunto:
“Revisar el comportamiento de reintento de inicio de sesión”. Publica un objetivo y un
bloqueador si existe uno. Lista los pares. Si otro tiene un tema Auth que posiblemente
se superpone, lee sus metadatos publicados. Si dice que está cambiando la misma regla de
validación, envía un mensaje al propietario con la decisión específica que necesitas.
Si no dice nada útil, mantén visible la incertidumbre y coordina con la persona
propietaria en lugar de adjudicarte el área.

Este enfoque cuesta menos que pedir repetidamente a un agente que resuma todo su
contexto, y evita el fallo opuesto: que un vago “alguien se está encargando” se
convierta en un conflicto silencioso.

## Errores comunes

- Usar un alias de visualización como si fuera una identidad estable de destinatario.
- Publicar secretos o razonamiento privado extenso en un campo de estado.
- Tratar un latido reciente como prueba de entrega, propiedad o un bloqueo de Git.
- Llamar al razonamiento con costo cuando los metadatos publicados ya responden la
  pregunta.
- Avisar automáticamente o inferir que ningún resultado de búsqueda significa que no
  existe trabajo relacionado.

## Pruébalo

Declara un asunto corto para tu tarea actual no sensible. Lista los pares y lee los
campos de cobertura y desconocidos, no solo las filas coincidentes. Si un par parece
relacionado, consulta sus metadatos y anota un hecho que realmente publicó y una cosa
que el resultado aún no puede probar. Ese es el límite que permite que varias sesiones
se coordinen sin perder el control humano.
