---
title: "MCP y codemode"
description: "Conectá servidores de herramientas externos y componé trabajo acotado con herramientas mediante scripts."
module: "Usuario avanzado"
---

# MCP y codemode

Un agente se vuelve más útil cuando puede llegar a los sistemas donde sucede el
trabajo: documentación, rastreadores de issues, un explorador de bases de datos o
un servicio de repositorio local. Pero “más herramientas” también implica más
descripciones en contexto, más credenciales que proteger y más oportunidades de
hacer una llamada con consecuencias. Pi aborda esas preocupaciones con dos
mecanismos complementarios: MCP conecta servidores externos, y codemode compone
llamadas a herramientas mientras devuelve solo el resultado útil al modelo de
lenguaje.

Usá esta lección después de **Extensions and packages**. Una extensión puede
registrar un servidor o herramienta MCP, pero MCP es una conexión estandarizada y
una superficie de herramientas. No confundas la declaración de un servidor MCP con
permiso para usar cada capacidad que expone.

## MCP: conectá un servidor y luego inspeccionalo

Pi se conecta a servidores Model Context Protocol mediante **stdio** o **streamable
HTTP**. Un servidor local tiene un comando y un arreglo de argumentos; no es una
cadena de comando de shell. Un servidor remoto tiene una URL. El transporte SSE
heredado se rechaza.

Por ejemplo, la CLI puede crear una entrada stdio de nivel de usuario,
inspeccionarla e iniciar Pi:

```bash
pi mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem .
pi mcp list
pi
```

Se puede agregar una entrada remota con una URL y una referencia de variable de
entorno de token bearer:

```bash
pi mcp add docs --url https://example.com/mcp --bearer-token-env-var DOCS_TOKEN
```

Esas son operaciones de configuración, no invocaciones de herramientas. Los
servidores de nivel de usuario viven en `~/.pi/agent/mcp.json`; los servidores de
proyecto viven en `.pi/mcp.json` y se cargan solo después de la confianza del
proyecto. Una entrada de proyecto con el mismo nombre reemplaza la entrada de nivel
de usuario. Una entrada de proyecto que contiene solo `enabled`, `exposure` o
`toolExposure` en cambio sobrescribe solo esas propiedades mientras conserva el
comando, URL, entorno, headers y autenticación de nivel de usuario.

Esa superposición permite que un proyecto de confianza deshabilite un servidor
personal sin copiar su configuración secreta. Mantené los servidores personales y
los servidores con credenciales en el archivo de nivel de usuario. Revisá una
configuración MCP de proyecto antes de confiar en ella: un servidor stdio es un
programa ejecutable, y un servidor remoto puede exponer acciones al modelo.

Dentro de Pi, `/mcp` lista el estado, origen, exposición y cantidad de herramientas
del servidor. Puede reconectar, habilitar o deshabilitar, y administrar flujos de
inicio de sesión compatibles. Fuera de una sesión, `pi mcp list` conecta los
servidores habilitados e informa errores; sale con valor distinto de cero si una
entrada no es válida o un servidor habilitado no se conecta. Ejecutá `/reload`
después de cambiar un servidor fuera de una sesión activa.

## La exposición es diseño de contexto y seguridad

Las herramientas MCP se llaman `mcp__<server>__<tool>`, pero los nombres por sí
solos no deciden cuánto del conjunto de herramientas aparece en el prompt. La
exposición de un servidor determina la ruta:

- `codemode` es el valor predeterminado: los scripts pueden llamar las herramientas,
  mientras el modelo no ve cada declaración.
- `deferred` vuelve las herramientas descubribles mediante `tool_search` para uso
  directo.
- `direct` declara las herramientas al modelo y también permite llamadas de codemode.
- `hidden` las deja registradas pero inalcanzables.

`toolExposure` puede sobrescribir eso por herramienta del servidor con nombres o
patrones exactos. Esto mantiene directa una herramienta pequeña y frecuente de solo
lectura mientras un conjunto grande o con consecuencias sigue siendo descubrible
bajo demanda. Cada llamada MCP aún pasa por la tubería de herramientas de Pi,
incluyendo las puertas de permisos de extensiones. La exposición hace que una
herramienta sea alcanzable; no evita la aprobación.

Al inicio de la sesión, los servidores habilitados se conectan en segundo plano. Las
herramientas directas pueden retener el primer prompt hasta diez segundos porque sus
declaraciones deben estar listas. Los otros servidores esperan hasta que un script o
mecanismo de descubrimiento los necesite. Un servidor fallido no es una razón para
seguir reintentando manualmente sin diagnóstico: inspeccioná su estado y el error de
conexión informado.

## Codemode: orquestá herramientas, no una shell sin restricciones

La herramienta `codemode` acepta código fuente JavaScript sin procesar. Pi lo ejecuta
como cuerpo de función async en un sandbox QuickJS, así que `await` y `return` de
nivel superior funcionan. El sandbox no tiene APIs de Node, sistema de archivos, red
ni temporizadores. Llega al exterior solo mediante herramientas de Pi y el catálogo
no LLM de `models`.

Ese entorno acotado es el objetivo. El script puede llamar varias herramientas en
paralelo, reducir una respuesta grande a una respuesta concisa y devolver solo esa
respuesta al modelo. La salida de herramientas no inunda automáticamente el próximo
turno del modelo. Un script podría buscar herramientas invocables, llamar consultas
de solo lectura independientes con `Promise.allSettled()`, y luego devolver una
comparación breve. Si una llamada falla, `Promise.allSettled()` conserva los
resultados exitosos en vez de abandonarlos con el primer rechazo.

Los globales clave son `tools`, `text()`, `image()`, `console`, `searchTools()`,
`describeTool()`, `describeNamespace()`, `ALL_TOOLS` y `models`. El nombre de una
herramienta MCP invocable se convierte en un identificador JavaScript reemplazando
caracteres que no son identificadores por guiones bajos. Por ejemplo, se puede llegar
a una herramienta MCP como `tools.mcp__dev_radius__search(...)` cuando su nombre es
invocable en la sesión actual.

Un script puede comenzar con una línea de opciones para limitar sus tokens de salida
o imponer un plazo para todo el script:

```js
// @options: {"max_output_tokens": 800, "timeout_ms": 60000}
const matches = await Promise.allSettled([
  tools.grep({ pattern: "TODO", path: "src" }),
  tools.grep({ pattern: "FIXME", path: "src" }),
]);
return matches.map((result) => result.status);
```

El ejemplo enseña composición, no afirma que cada sesión tenga los mismos argumentos
para `grep`. Leé `describeTool()` para la declaración instalada antes de escribir un
script real.

Los efectos de herramientas son reales. Un fallo del script no deshace las llamadas a
herramientas que ya se ejecutaron; las llamadas sin terminar se cancelan cuando el
script termina. Usá primero scripts para lectura y trabajo de agregación, y mantené
las escrituras acotadas y autorizadas deliberadamente. Los opcionales `store()` y
`load()` preservan valores JSON pequeños entre llamadas codemode exitosas en una rama
de sesión; sirven para IDs, cursores y resúmenes, no para datos de imagen ni como
sustituto de registros durables del proyecto.

Codemode también puede ejecutar modelos de clasificador e imagen disponibles, pero no
modelos de chat. Su uso contribuye al resultado de codemode y al costo de sesión.
Consultá el catálogo disponible en vez de suponer que un ID de provider/model funciona
con las credenciales actuales.

## Errores comunes

- Pegar secretos en un `mcp.json` de proyecto en lugar de mantenerlos personales.
- Tratar un campo de comando MCP como una cadena de shell.
- Hacer directo cada servidor grande y pagar las descripciones de herramientas en cada turno.
- Suponer que un script sandboxed revierte llamadas a herramientas completadas después de un error.
- Imprimir un resultado enorme de herramienta en vez de devolver un resumen filtrado útil.

## Probalo

Ejecutá `pi mcp list` e inspeccioná el estado del servidor sin cambiar la
configuración. En una sesión interactiva, abrí `/mcp` y compará la exposición de un
servidor con su cantidad de herramientas. Después describí una investigación de solo
lectura que se beneficiaría de un script codemode: las llamadas independientes que
haría, el resultado pequeño que devolvería y el límite de aprobación que preservaría.
