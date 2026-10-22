---
title: "Modelos y proveedores"
description: "Elegí una conexión de modelo, un método de autenticación y un nivel de razonamiento sin confundir suscripciones con API keys."
module: "Primeros pasos"
---

# Modelos y proveedores

“Usar un modelo” resume varias decisiones separadas: qué servicio recibe la solicitud, qué
ID de modelo usa, cómo se autentica Pi y cuánto razonamiento admite el modelo seleccionado.
Separar esas decisiones evita una clase costosa de errores de configuración: proporcionar
una API key a una ruta de suscripción, esperar que un inicio de sesión OAuth habilite un
modelo solo de API o elegir un nombre de modelo sin saber qué proveedor lo posee.

## Proveedor, modelo y credencial son cosas diferentes

Un **proveedor** es la conexión de Pi a un servicio de modelos. Un **modelo** es un modelo
específico ofrecido a través de ese proveedor. Pi hace referencia al par como
`provider/model`, por ejemplo en `/model [provider/model]` o en la forma
`--model provider/id` de la CLI.

Un proveedor también define cómo puede autenticarse Pi. La mayoría de los proveedores
alojados admiten uno o ambos de estos métodos:

- inicio de sesión de navegador o flujo de dispositivo respaldado por OAuth;
- una API key.

Ejecutá `/login [provider]` para ver los métodos que la versión actual de Pi admite para ese
proveedor. Pi puede guardar la credencial resultante en su configuración privada de agente,
o una API key puede provenir de una variable de entorno configurada antes de que Pi se
inicie. Las variables de entorno son útiles en CI u otro entorno donde Pi no debería
escribir una credencial en disco.

Pi resuelve las credenciales en un orden que empieza con una `--api-key` de ejecución,
luego una credencial guardada, después una `apiKey` en `models.json`, y finalmente las
variables de entorno del proveedor o las credenciales de cloud ambientales. Por eso la
disponibilidad de un modelo puede cambiar entre terminales: el proceso debe recibir
realmente la credencial necesaria.

## Seleccioná un modelo y un nivel de razonamiento

El flujo interactivo cotidiano es sencillo:

```text
/login
/model
/thinking
```

`/model` busca modelos cuyos proveedores tienen autenticación utilizable. Presionar
`Ctrl+S` en el selector guarda la selección como predeterminada para las sesiones nuevas.
`/thinking` elige el nivel de razonamiento del modelo actual, y Pi limita las opciones a los
niveles que admite el modelo seleccionado. `Shift+Tab` recorre los niveles compatibles;
`Ctrl+S` en el selector de razonamiento guarda un nivel de inicio.

Una sesión registra cambios de modelo y de nivel de razonamiento. Reanudarla restaura esas
elecciones sin cambiar los valores predeterminados para las sesiones nuevas. Esa distinción
es útil cuando una investigación enfocada necesita un modelo diferente pero no debería
cambiar silenciosamente el trabajo futuro.

La CLI ofrece las mismas ideas de forma no interactiva:

```bash
pi --model provider/model-id
pi --thinking high
pi --model model-id:high
```

El vocabulario documentado de niveles de razonamiento es `off`, `minimal`, `low`, `medium`,
`high`, `xhigh` y `max`, pero un modelo dado puede exponer solo un subconjunto. Más
razonamiento es una capacidad y elección específica del modelo, no una promesa de que cada
proveedor interprete cada etiqueta de forma idéntica.

## Rutas de suscripción y rutas de API key

Una suscripción y una API key son rutas diferentes de pago y autenticación. La documentación
de modelos de Pi recomienda iniciar sesión mediante `/login` cuando tenés una suscripción
compatible, y usar `/login` o una variable de entorno cuando tenés una API key de proveedor.

Para las opciones relacionadas con OpenAI, el nombre del proveedor importa. La ayuda de
línea de comandos de Pi muestra un ejemplo de bearer token para `openai-codex`:

```bash
pi auth print-bearer-token --provider openai-codex
```

También documenta `OPENAI_API_KEY` como la variable de entorno de API key para el proveedor
`openai`. Así que usá el proveedor asociado al acceso que realmente tenés: una ruta de
inicio de sesión/bearer token de `openai-codex` para su acceso de proveedor de estilo
suscripción, y la ruta `openai` cuando usás una API key de OpenAI. No supongas que un inicio
de sesión de cuenta es intercambiable con una API key, ni que los nombres de proveedores son
alias cosméticos.

Esta lección se mantiene intencionalmente genérica. Los catálogos de proveedores, los
modelos disponibles, los precios y los derechos de acceso pueden cambiar. Dejá que `/login`
y `/model` muestren lo que tu Pi en ejecución puede usar realmente en vez de copiar un nombre
de modelo de la terminal de otra persona.

## Catálogos, endpoints personalizados y disponibilidad

Pi comienza con un catálogo de modelos incluido y puede superponer datos de catálogo más
nuevos desde pi.dev. Los datos de catálogo en caché siguen siendo utilizables sin conexión;
`pi update --models` fuerza una actualización. El catálogo es una descripción de modelos y
capacidades, no una prueba de que tu cuenta puede llamar a cada uno.

Para un proveedor compatible, la primera pregunta de resolución de problemas es si tiene
autenticación utilizable. Un modelo personalizado en `models.json` puede cargarse en la
configuración de Pi pero seguir sin estar disponible en `/model` hasta que Pi resuelva las
credenciales. Para endpoints compatibles, como despliegues locales o proxy, `models.json`
describe el endpoint del proveedor y la lista de modelos. Pi vuelve a cargar ese archivo al
abrir `/model`, y una entrada puede agregar o reemplazar un modelo con el mismo ID en ese
proveedor.

Usá una extensión de proveedor en su lugar cuando el servicio necesita un flujo personalizado
de streaming, descubrimiento de modelos o autenticación. Un archivo de configuración debería
describir compatibilidad verificada; no debería afirmar soporte solo porque un endpoint usa
una etiqueta de API conocida.

## NaN: un proveedor integrado con su propia ruta

Gentle Shell incluye el proveedor propio `nan`; no necesita un paquete de proveedor separado.
Podés proporcionar `NAN_API_KEY` antes de iniciar Pi o usar `/login` y elegir NaN (también
`/login nan`), después elegí un modelo con `/model`. Una key guardada tiene precedencia sobre
`NAN_API_KEY`.

El descubrimiento de modelos de NaN usa la respuesta autenticada de modelos cruzada con un
conjunto mantenido de IDs de modelos de chat conocidos. Antes de una actualización exitosa,
Gentle Shell documenta una lista de respaldo sin conexión; después de una actualización
exitosa, la lista en vivo limitada por key —incluso una vacía— es la fuente de verdad. Tratá
el selector como la respuesta para tu credencial, no el respaldo como garantía de derecho.

Algunos modelos NaN administran la profundidad de razonamiento por sí mismos. Para esos
modelos, el espacio de trabajo informa `effort: auto`, y elegir un nivel de razonamiento de
Pi no cambia su profundidad de razonamiento. Esto recuerda útilmente que la interfaz común
de razonamiento de Pi normaliza el control cuando es posible, pero no elimina el
comportamiento del proveedor.

## Protegé las credenciales y elegí deliberadamente

Las credenciales en `auth.json` pueden ser API keys o tokens OAuth. Mantené privado ese
archivo y no lo confirmes. La configuración del proyecto y las extensiones pueden ejecutarse
dentro del proceso de Pi después de que confiás en un proyecto, así que no cargues sin cuidado
configuración de proyecto no confiable. Una variable de entorno evita escribir una API key en
ese archivo, pero aun así debe tratarse como un secreto en el entorno que inicia Pi.

Elegí la ruta confirmada más pequeña:

1. Identificá el proveedor y el modelo que necesitás.
2. Usá `/login` para ver las opciones de inicio de sesión compatibles de ese proveedor.
3. Usá una API key solo mediante la ruta de key documentada por el proveedor.
4. Confirmá la disponibilidad en `/model`.
5. Seleccioná un nivel de razonamiento compatible en `/thinking`.

La próxima lección **Organic Driven Development** trata sobre cómo realizar el trabajo una
vez que se selecciona un modelo. No prescribe una elección personal de modelo.

## Errores comunes

- **Tratar un ID de modelo como globalmente único.** Incluí o verificá su proveedor.
- **Poner una API key en un flujo de suscripción/OAuth.** Elegí la ruta que documenta el
  proveedor.
- **Suponer que una entrada de catálogo prueba el acceso.** La autenticación y el acceso a la
  cuenta todavía determinan la disponibilidad.
- **Suponer que cada nivel de razonamiento sirve para cada modelo.** Pi filtra los niveles al
  soporte del modelo.
- **Compartir `auth.json` o sesiones exportadas sin cuidado.** Pueden contener credenciales u
  otra información sensible de conversación.

## Probalo

Abrí `/model` e identificá los pares proveedor/modelo que realmente podés seleccionar. Abrí
`/thinking` y anotá los niveles disponibles para el modelo actual. Después decí qué ruta de
credenciales usarías para una conexión de estilo suscripción de `openai-codex` y cuál usarías
para una conexión con API key de `openai`. Si falta un modelo, primero verificá la
autenticación del proveedor en vez de adivinar un ID de modelo.
