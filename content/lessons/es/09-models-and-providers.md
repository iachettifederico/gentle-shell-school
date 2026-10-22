---
title: "Modelos y proveedores"
description: "Elige una conexión de modelo, un método de autenticación y un nivel de razonamiento sin confundir suscripciones con claves de API."
module: "Fundamentos"
---

# Modelos y proveedores

“Usar un modelo” condensa varias decisiones separadas: qué servicio recibe la solicitud, qué
ID de modelo usa, cómo se autentica Pi y cuánto razonamiento admite el modelo seleccionado.
Separar esas decisiones evita una clase costosa de errores de configuración: proporcionar una
clave de API a una ruta de suscripción, esperar que un inicio de sesión OAuth desbloquee un
modelo solo de API o elegir un nombre de modelo sin saber qué proveedor le pertenece.

## Proveedor, modelo y credencial son cosas distintas

Un **proveedor** es la conexión de Pi a un servicio de modelos. Un **modelo** es un modelo
específico ofrecido a través de ese proveedor. Pi hace referencia al par como
`provider/model`, por ejemplo en `/model [provider/model]` o en la forma de CLI
`--model provider/id`.

Un proveedor también define cómo puede autenticarse Pi. La mayoría de los proveedores
alojados admiten uno o ambos de estos métodos:

- inicio de sesión mediante navegador o flujo de dispositivo respaldado por OAuth;
- una clave de API.

Ejecuta `/login [provider]` para ver los métodos que la versión actual de Pi admite para ese
proveedor. Pi puede almacenar la credencial resultante en su configuración privada del agente,
o una clave de API puede provenir de una variable de entorno establecida antes de que Pi se
inicie. Las variables de entorno son útiles en CI u otro entorno donde Pi no debería escribir
una credencial en disco.

Pi resuelve las credenciales en un orden que comienza con un `--api-key` de tiempo de
ejecución, después una credencial almacenada, luego una `apiKey` en `models.json` y finalmente
las variables de entorno del proveedor o las credenciales de nube ambientales. Por eso la
disponibilidad de un modelo puede cambiar entre terminales: el proceso debe recibir realmente
la credencial necesaria.

## Selecciona un modelo y nivel de razonamiento

El flujo interactivo cotidiano es sencillo:

```text
/login
/model
/thinking
```

`/model` busca modelos cuyos proveedores tienen autenticación utilizable. Presionar `Ctrl+S`
en el selector guarda la selección como predeterminada para sesiones nuevas. `/thinking` elige
el nivel de razonamiento del modelo actual, y Pi limita las opciones a los niveles que admite
el modelo seleccionado. `Shift+Tab` alterna los niveles compatibles; `Ctrl+S` en el selector
de razonamiento guarda un nivel de inicio.

Una sesión registra los cambios de modelo y nivel de razonamiento. Reanudarla restaura esas
elecciones sin cambiar los valores predeterminados para sesiones nuevas. Esa distinción es útil
cuando una investigación enfocada necesita un modelo diferente pero no debería cambiar
silenciosamente el trabajo futuro.

La CLI ofrece las mismas ideas de forma no interactiva:

```bash
pi --model provider/model-id
pi --thinking high
pi --model model-id:high
```

El vocabulario documentado de nivel de razonamiento es `off`, `minimal`, `low`, `medium`,
`high`, `xhigh` y `max`, pero un modelo dado puede exponer solo un subconjunto. Más
razonamiento es una capacidad y elección específicas del modelo, no una promesa de que cada
proveedor interprete cada etiqueta de manera idéntica.

## Rutas de suscripción y rutas de clave de API

Una suscripción y una clave de API son rutas de pago y autenticación distintas. La
documentación de modelos de Pi recomienda iniciar sesión mediante `/login` cuando tienes una
suscripción compatible, y usar `/login` o una variable de entorno cuando tienes una clave de
API de proveedor.

Para las opciones relacionadas con OpenAI, importa el nombre del proveedor. La ayuda de línea
de comandos de Pi muestra un ejemplo de token bearer para `openai-codex`:

```bash
pi auth print-bearer-token --provider openai-codex
```

Por separado documenta `OPENAI_API_KEY` como la variable de entorno de clave de API para el
proveedor `openai`. Por lo tanto, usa el proveedor asociado al acceso que realmente tienes: una
ruta de inicio de sesión/token bearer de `openai-codex` para su acceso de proveedor de estilo
suscripción, y la ruta `openai` cuando usas una clave de API de OpenAI. No supongas que un
inicio de sesión de cuenta sea intercambiable con una clave de API, ni que los nombres de
proveedores sean alias cosméticos.

Esta lección se mantiene intencionalmente genérica. Los catálogos de proveedores, modelos
disponibles, precios y derechos de acceso pueden cambiar. Deja que `/login` y `/model`
muestren lo que tu Pi en ejecución realmente puede usar en lugar de copiar un nombre de modelo
de la terminal de otra persona.

## Catálogos, endpoints personalizados y disponibilidad

Pi comienza con un catálogo de modelos incluido y puede superponer datos más recientes del
catálogo desde pi.dev. Los datos de catálogo en caché siguen siendo utilizables sin conexión;
`pi update --models` fuerza una actualización. El catálogo es una descripción de modelos y
capacidades, no una prueba de que tu cuenta pueda llamar a cada uno.

Para un proveedor compatible, la primera pregunta de solución de problemas es si tiene
autenticación utilizable. Un modelo personalizado en `models.json` puede cargarse en la
configuración de Pi y, aun así, no estar disponible en `/model` hasta que Pi resuelva las
credenciales. Para endpoints compatibles, como implementaciones locales o mediante proxy,
`models.json` describe el endpoint del proveedor y la lista de modelos. Pi vuelve a cargar ese
archivo cuando se abre `/model`, y una entrada puede agregar o reemplazar un modelo con el
mismo ID en ese proveedor.

Usa en su lugar una extensión de proveedor cuando el servicio necesita un flujo personalizado
de streaming, descubrimiento de modelos o autenticación. Un archivo de configuración debe
describir compatibilidad verificada; no debe afirmar compatibilidad solo porque un endpoint usa
una etiqueta de API conocida.

## NaN: un proveedor integrado con su propia ruta

Gentle Shell incluye el proveedor propio `nan`; no necesita un paquete de proveedor separado.
Puedes proporcionar `NAN_API_KEY` antes de iniciar Pi o usar `/login` y elegir NaN (también
`/login nan`), y luego elegir un modelo con `/model`. Una clave almacenada tiene precedencia
sobre `NAN_API_KEY`.

El descubrimiento de modelos de NaN usa la respuesta de modelos autenticada cruzada con un
conjunto mantenido de IDs conocidos de modelos de chat. Antes de una actualización exitosa,
Gentle Shell documenta una lista alternativa sin conexión; después de una actualización
exitosa, la lista activa asociada a la clave, incluso si está vacía, es autoritativa. Trata al
selector como la respuesta para tu credencial, no a la alternativa como una garantía de acceso.

Algunos modelos NaN gestionan la profundidad de razonamiento por sí mismos. Para esos modelos,
el espacio de trabajo informa `effort: auto`, y elegir un nivel de razonamiento de Pi no cambia
su profundidad de razonamiento. Esto es un recordatorio útil de que la interfaz común de
razonamiento de Pi normaliza el control donde es posible, pero no elimina el comportamiento del
proveedor.

## Protege las credenciales y elige deliberadamente

Las credenciales en `auth.json` pueden ser claves de API o tokens OAuth. Mantén ese archivo
privado y no lo confirmes. La configuración del proyecto y las extensiones pueden ejecutarse
dentro del proceso de Pi después de que confías en un proyecto, así que no cargues la
configuración de un proyecto no confiable sin cuidado. Una variable de entorno evita escribir
una clave de API en ese archivo, pero aun así debe manejarse como un secreto en el entorno que
inicia Pi.

Elige la ruta confirmada más pequeña:

1. Identifica el proveedor y el modelo que necesitas.
2. Usa `/login` para ver las opciones de inicio de sesión compatibles de ese proveedor.
3. Usa una clave de API solo mediante la ruta de clave documentada por el proveedor.
4. Confirma la disponibilidad en `/model`.
5. Selecciona un nivel de razonamiento compatible en `/thinking`.

La próxima lección **Desarrollo Orgánico Impulsado** trata sobre cómo realizar trabajo una vez
seleccionado un modelo. No prescribe una elección personal de modelo.

## Errores comunes

- **Tratar un ID de modelo como globalmente único.** Incluye o verifica su proveedor.
- **Poner una clave de API en un flujo de suscripción/OAuth.** Elige la ruta que documenta el
  proveedor.
- **Suponer que una entrada de catálogo demuestra acceso.** La autenticación y el acceso de la
  cuenta todavía determinan la disponibilidad.
- **Suponer que cada nivel de razonamiento funciona para cada modelo.** Pi filtra los niveles
  según el soporte del modelo.
- **Compartir `auth.json` o sesiones exportadas sin cuidado.** Pueden contener credenciales u
  otra información confidencial de la conversación.

## Pruébalo

Abre `/model` e identifica los pares proveedor/modelo que realmente puedes seleccionar. Abre
`/thinking` y observa los niveles disponibles para el modelo actual. Luego di qué ruta de
credencial usarías para una conexión de suscripción de estilo `openai-codex` y cuál usarías
para una conexión de clave de API `openai`. Si falta un modelo, primero verifica la
autenticación del proveedor en lugar de adivinar un ID de modelo.
