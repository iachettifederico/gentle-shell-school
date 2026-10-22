---
title: "MCP y codemode"
description: "Conecta servidores de herramientas externos y compone trabajo de herramientas acotado con scripts."
module: "Usuario avanzado"
---

# MCP y codemode

Un agente se vuelve más útil cuando puede llegar a los sistemas donde ocurre el trabajo:
documentación, rastreadores de issues, un explorador de bases de datos o un servicio de
repositorio local. Pero “más herramientas” también significa más descripciones en el
contexto, más credenciales que proteger y más oportunidades de hacer una llamada con
consecuencias. Pi aborda esas preocupaciones con dos mecanismos complementarios: MCP
conecta servidores externos y codemode compone llamadas a herramientas mientras
devuelve solo el resultado útil al modelo de lenguaje.

Usa esta lección después de **Extensions and packages**. Una extensión puede registrar
un servidor o herramienta MCP, pero MCP es una conexión estandarizada y una superficie
de herramientas. No confundas la declaración de un servidor MCP con el permiso para
usar cada capacidad que expone.

## MCP: conecta un servidor y luego inspecciónalo

Pi se conecta a servidores Model Context Protocol mediante **stdio** o **streamable
HTTP**. Un servidor local tiene un comando y una matriz de argumentos; no es una cadena
de comando de shell. Un servidor remoto tiene una URL. Se rechaza el transporte SSE
heredado.

Por ejemplo, la CLI puede crear una entrada stdio de nivel de usuario, inspeccionarla e
iniciar Pi:

```bash
pi mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem .
pi mcp list
pi
```

Se puede agregar una entrada remota con una URL y una referencia de variable de entorno
de token bearer:

```bash
pi mcp add docs --url https://example.com/mcp --bearer-token-env-var DOCS_TOKEN
```

Esas son operaciones de configuración, no invocaciones de herramientas. Los servidores
de nivel de usuario viven en `~/.pi/agent/mcp.json`; los servidores de proyecto viven en
`.pi/mcp.json` y se cargan solo después de la confianza del proyecto. Una entrada de
proyecto con el mismo nombre reemplaza la entrada de nivel de usuario. Una entrada de
proyecto que contiene solo `enabled`, `exposure` o `toolExposure` en cambio reemplaza
solo esas propiedades mientras conserva el comando, URL, entorno, encabezados y
autenticación de nivel de usuario.

Esa superposición permite que un proyecto de confianza desactive un servidor personal
sin copiar su configuración secreta. Mantén los servidores personales y los servidores
con credenciales en el archivo de nivel de usuario. Revisa una configuración MCP de
proyecto antes de confiar en ella: un servidor stdio es un programa ejecutable y un
servidor remoto puede exponer acciones al modelo.

Dentro de Pi, `/mcp` enumera el estado del servidor, origen, exposición y cantidad de
herramientas. Puede reconectar, habilitar o deshabilitar, y administrar flujos de inicio
de sesión compatibles. Fuera de una sesión, `pi mcp list` conecta servidores habilitados
e informa errores; sale con un valor distinto de cero si una entrada no es válida o un
servidor habilitado no se conecta. Ejecuta `/reload` después de cambiar un servidor
fuera de una sesión activa.

## La exposición es diseño de contexto y seguridad

Las herramientas MCP se llaman `mcp__<server>__<tool>`, pero los nombres por sí solos
no deciden cuánto del conjunto de herramientas aparece en el prompt. La exposición de
un servidor determina la ruta:

- `codemode` es el valor predeterminado: los scripts pueden llamar las herramientas,
  mientras que el modelo no ve cada declaración.
- `deferred` hace que las herramientas sean descubribles mediante `tool_search` para uso
  directo.
- `direct` declara herramientas al modelo y también permite llamadas de codemode.
- `hidden` las deja registradas pero inaccesibles.

`toolExposure` puede reemplazar eso por herramienta de servidor con nombres exactos o
patrones. Esto mantiene directa una herramienta de lectura frecuente y pequeña mientras
conserva un conjunto grande o con consecuencias detectable bajo demanda. Cada llamada
MCP sigue pasando por el flujo de herramientas de Pi, incluidas las puertas de permisos
de extensiones. La exposición hace que una herramienta sea accesible; no renuncia a la
aprobación.

Al iniciar la sesión, los servidores habilitados se conectan en segundo plano. Las
herramientas directas pueden retener el primer prompt hasta diez segundos porque sus
declaraciones deben estar listas. Otros servidores esperan cuando un script o mecanismo
de descubrimiento los necesita. Un servidor fallido no es motivo para seguir reintentando
manualmente sin diagnóstico: inspecciona su estado y el error de conexión informado.

## Codemode: orquesta herramientas, no una shell sin restricciones

La herramienta `codemode` acepta código fuente JavaScript sin procesar. Pi lo ejecuta
como un cuerpo de función asíncrona en un sandbox QuickJS, por lo que `await` y `return`
de nivel superior funcionan. El sandbox no tiene APIs de Node, sistema de archivos, red
ni temporizadores. Llega al exterior solo mediante herramientas Pi y el catálogo de
`models` que no son LLM.

Ese entorno estrecho es el objetivo. El script puede llamar varias herramientas en
paralelo, reducir una respuesta grande a una respuesta concisa y devolver solo esa
respuesta al modelo. La salida de la herramienta no inunda automáticamente el siguiente
turno del modelo. Un script podría buscar herramientas invocables, llamar consultas de
solo lectura independientes con `Promise.allSettled()` y luego devolver una comparación
breve. Si una llamada falla, `Promise.allSettled()` conserva los resultados exitosos en
vez de abandonarlos con el primer rechazo.

Las variables globales clave son `tools`, `text()`, `image()`, `console`,
`searchTools()`, `describeTool()`, `describeNamespace()`, `ALL_TOOLS` y `models`. El
nombre de una herramienta MCP invocable se convierte en un identificador JavaScript al
reemplazar caracteres no identificadores con guiones bajos. Por ejemplo, se puede llegar
a una herramienta MCP como `tools.mcp__dev_radius__search(...)` cuando su nombre es
invocable en la sesión actual.

Un script puede empezar con una línea de opciones para limitar sus tokens de salida o
imponer una fecha límite para todo el script:

```js
// @options: {"max_output_tokens": 800, "timeout_ms": 60000}
const matches = await Promise.allSettled([
  tools.grep({ pattern: "TODO", path: "src" }),
  tools.grep({ pattern: "FIXME", path: "src" }),
]);
return matches.map((result) => result.status);
```

El ejemplo enseña composición, no afirma que cada sesión tenga los mismos argumentos de
`grep`. Lee `describeTool()` para la declaración instalada antes de escribir un script
real.

Los efectos de las herramientas son reales. Un fallo de script no deshace las llamadas a
herramientas que ya se ejecutaron; las llamadas sin terminar se cancelan cuando el
script termina. Usa scripts primero para trabajo de lectura y agregación, y mantén las
escrituras acotadas y autorizadas deliberadamente. Los valores opcionales `store()` y
`load()` conservan pequeños valores JSON entre llamadas codemode exitosas en una rama de
sesión; son para IDs, cursores y resúmenes, no datos de imágenes ni un sustituto de
registros de proyecto duraderos.

Codemode también puede ejecutar modelos de clasificador e imagen disponibles, pero no
modelos de chat. Su uso contribuye al resultado de codemode y al costo de la sesión.
Consulta el catálogo disponible en lugar de asumir que un ID de proveedor/modelo funciona
con las credenciales actuales.

## Errores comunes

- Pegar secretos en un `mcp.json` de proyecto en lugar de mantenerlos personales.
- Tratar un campo de comando MCP como una cadena de shell.
- Hacer directo cada servidor grande y pagar por descripciones de herramientas en cada
  turno.
- Suponer que un script en sandbox revierte llamadas a herramientas completadas después
  de un error.
- Imprimir un resultado enorme de herramienta en lugar de devolver un resumen útil
  filtrado.

## Pruébalo

Ejecuta `pi mcp list` e inspecciona el estado del servidor sin cambiar la configuración.
En una sesión interactiva, abre `/mcp` y compara la exposición de un servidor con su
cantidad de herramientas. Luego describe una investigación de solo lectura que se
beneficiaría de un script codemode: las llamadas independientes que haría, el resultado
pequeño que devolvería y el límite de aprobación que preservaría.
