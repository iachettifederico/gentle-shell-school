---
title: "Coordinación de múltiples sesiones"
description: "Coordiná sesiones activas de orquestador sin confundir los metadatos con autoridad."
module: "Usuario avanzado"
---

# Coordinación de múltiples sesiones

Una segunda sesión de agente puede ser útil mucho antes de editar algo. Podés tener una
sesión que investiga una falla, otra que prepara una revisión y una tercera que trabaja en
otro repositorio. El problema difícil no es abrir esas sesiones; es saber si el trabajo
cercano importa sin fingir que los nombres, las ventanas o un estado antiguo implican
permiso.

Gentle Shell trata esto como **metadatos de coordinación**. Una sesión puede publicar un
asunto reconocible, una pequeña instantánea curada de progreso y una clasificación de
trabajo acotada. Otras sesiones pueden listar o buscar ese material publicado, luego
consultarlo o enviar un mensaje enfocado cuando queda una pregunta real. Esto mantiene la
coordinación más económica que copiar transcripciones y más segura que asumir que un par
que parece activo es dueño de un archivo.

Esta lección amplía **Subagentes**, no es un reemplazo. Una tarea hija tiene un padre y
una entrega declarada. Una sesión par es un orquestador que se ejecuta de manera
independiente. Sus metadatos públicos son descriptivos, no una instrucción, concesión,
bloqueo, recibo de revisión ni prueba de que puede recibir tu mensaje.

## Empezá con un asunto

Antes de delegar o coordinar trabajo que sea más que una pequeña tarea directa, llamá a
`orchestrator_session_id` con un `subject` breve y no sensible. La herramienta devuelve
un ID de enrutamiento estable, un alias de tarea actual, un alias de tarea inicial y un
nombre de sesión humano. Los alias hacen comprensible una lista de pares; el ID estable es
lo que identifica a una persona destinataria para una operación enfocada.

Un asunto es deliberadamente limitado. Se normaliza y acota, y no debe contener un prompt
ni un secreto. Declararlo puede establecer un nombre de sesión de Pi solo cuando ese nombre
canónico está vacío, por lo que se preserva un cambio de nombre posterior hecho por una
persona humana. El primer asunto explícito sigue siendo el alias inicial en esa rama; una
declaración posterior actualiza el alias actual. Ninguno de los alias se convierte en una
identidad ni en una decisión de control de acceso.

Publicá solo lo que otra sesión necesita para evitar una colisión o hacer una mejor
pregunta. La misma llamada puede llevar un pequeño objeto `state` con `objective`,
`progress`, `decisions` y `blockers`. También puede llevar trabajo clasificado explícito,
como un área, tema, etiquetas y referencias de issue o PR calificadas por repositorio.
Tratala como un reemplazo, no un parche: incluí cada campo que deba seguir siendo público.
Al terminar, publicá el resultado y el próximo alcance, o retirá el estado en vez de dejar
que una tarea terminada parezca activa.

No pongas historial privado, credenciales, prompts en bruto ni instrucciones internas en
estos metadatos. La implementación almacena un registro personalizado limitado y sin
contexto para la rama activa; no extrae tu transcripción para fabricar un informe de estado.
Esa distinción protege tanto la privacidad como el significado.

## Primero descubrí, inferí con prudencia

`orchestrator_list` sin argumentos lista los pares. Es útil para ver orquestadores
recientes del mismo perfil y sus etiquetas de visualización, contexto de espacio de trabajo
y resúmenes acotados de tareas hijas sin terminar. Una sesión también puede solicitar una
búsqueda de trabajo clasificado con un filtro explícito. Los filtros pueden combinar área,
tema, etiqueta, texto literal, una referencia tipada exacta o la raíz de repositorio
registrada.

El resultado tiene un significado negativo importante. La presencia reciente es una
ventana de latido, no una prueba de disponibilidad. Un espacio de trabajo registrado es un
hecho de inicio, no una identidad canónica de repositorio ni un bloqueo de escritor
exclusivo. Las páginas omitidas, desconocidas, sin clasificar y pendientes significan que
la lista no es exhaustiva. Una posible superposición de área o etiqueta es solo una
posible superposición; no establece una dependencia ni un permiso.

Esa prudencia es el mecanismo que hace segura una lista. En vez de inventar propiedad
global a partir de un panel conveniente, hace visible la incertidumbre. Si necesitás
contexto exacto de un par listado, conservá el ID de sesión estable completo que devuelve
la herramienta. No selecciones un par por un ID de visualización recortado ni por un alias.

## Consultá y luego enviá un mensaje solo cuando sea necesario

`orchestrator_consult` tiene dos vías. La vía de metadatos predeterminada lee la
instantánea publicada de la persona destinataria. No despierta a quien es dueño de la
sesión, no lanza un ayudante, no hace una llamada a un modelo ni lee transcripciones
privadas. Devuelve una instantánea separada y acotada, con marcas de tiempo históricas e
incertidumbres explícitas. Usala primero para preguntas como “¿qué trabajo publicó esta
sesión?” o “¿qué alcance de repositorio registró?”.

La vía de razonamiento es intencionalmente diferente. Le hace a un modelo configurado una
pregunta acotada y de solo lectura sobre una instantánea pública curada. Como cuesta
dinero, una UI interactiva debe obtener permiso por el costo del modelo; los contextos sin
interacción fallan de forma cerrada. Su respuesta es consejo, no una respuesta de quien es
dueño, autoridad ni consentimiento. La prosa de un modelo no puede conceder un permiso que
la persona dueña original no publicó.

Cuando ninguna vía responde tu pregunta, enviá un mensaje enfocado mediante las
herramientas de coordinación con el ID estable del par y una razón concreta. Un mensaje en
cola significa solo que está en cola, no que se entregó o se leyó. No conviertas la falta
de respuesta en evidencia de que el par está inactivo o de que sus archivos están
disponibles para que los cambies.

## Una secuencia práctica

Imaginá que dos sesiones tocan autenticación. Primero, dale a la tuya un asunto: “Revisar
el comportamiento de reintento de inicio de sesión”. Publicá un objetivo y un bloqueo si
hay uno. Listá pares. Si otra sesión tiene un tema de Auth posiblemente superpuesto, leé
sus metadatos publicados. Si dice que está cambiando la misma regla de validación, enviále
un mensaje a quien es dueño con la decisión enfocada que necesitás. Si no dice nada útil,
deja visible la incertidumbre y coordiná con la persona dueña en vez de afirmar que el área
está cubierta.

Este enfoque es más económico que pedir repetidamente a un agente que resuma todo su
contexto, y evita la falla opuesta: que un vago “alguien se está encargando” se convierta
en un conflicto silencioso.

## Errores comunes

- Usar un alias de visualización como si fuera una identidad estable de destinatario.
- Publicar secretos o razonamiento privado extenso en un campo de estado.
- Tratar un latido reciente como prueba de entrega, propiedad o un bloqueo de Git.
- Llamar al razonamiento con costo cuando los metadatos publicados ya responden la
  pregunta.
- Avisar automáticamente o inferir que ningún resultado de búsqueda significa que no existe
  trabajo relacionado.

## Probalo

Declará un asunto breve para tu tarea actual no sensible. Listá pares y leé los campos de
cobertura e incertidumbres, no solo las filas coincidentes. Si un par parece relacionado,
consultá sus metadatos y anotá un hecho que realmente publicó y algo que el resultado
todavía no puede probar. Ese es el límite que permite coordinar múltiples sesiones sin
perder el control humano.
