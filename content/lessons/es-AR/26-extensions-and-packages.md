---
title: "Extensiones y paquetes"
description: "Agregá comportamiento ejecutable de confianza a Pi y distribuí recursos relacionados en conjunto."
module: "Usuario avanzado"
---

# Extensiones y paquetes

Los prompts y las skills cambian lo que se le indica al modelo. Las extensiones
cambian lo que Pi puede hacer. Ese límite es la primera decisión de diseño: elegí
instrucciones para un flujo de trabajo repetible guiado por personas, pero elegí
una extensión cuando el flujo necesita comportamiento ejecutable: herramientas,
comandos de barra, controladores de eventos, providers, estado de sesión o una
interfaz de terminal.

Una extensión es un módulo TypeScript o JavaScript que se ejecuta dentro del
proceso de Pi. Es potente y deliberadamente no casual: tiene los mismos permisos
del sistema operativo que Pi y puede inspeccionar prompts, llamadas a herramientas,
archivos, credenciales e historial de sesión. Cargá solo código fuente en el que
confíes. Un paquete puede agrupar extensiones con skills, templates, themes y
dependencias de tiempo de ejecución, así que también es territorio de revisión de
código y no solo una preferencia de estilo.

Esta lección se basa en **Skills** y **Writing skills**. Mantené la guía reutilizable
en una skill cuando no sea necesario ejecutar código. Usá un prompt template para
un comando de barra reutilizable que se expande a texto. Recurrí a una extensión
solo después de poder nombrar la capacidad de tiempo de ejecución que las
instrucciones no pueden aportar.

## El modelo de extensiones

Una extensión exporta una factory predeterminada que recibe `ExtensionAPI`. La
factory registra capacidades para ese tiempo de ejecución. Una extensión de comando
pequeña puede registrar un comando de barra; otra podría registrar una herramienta
invocable por el modelo o un controlador de eventos. Pi puede cargar directamente
un archivo TypeScript local con `pi --extension ./hello.ts`; `jiti` significa que
el archivo local no necesita un paso de compilación separado.

Elegí cuidadosamente un límite de ciclo de vida. La factory puede registrar cosas,
pero no debería iniciar procesos, sockets, temporizadores ni watchers de larga vida:
Pi puede cargar una extensión sin iniciar una sesión. Iniciá recursos de sesión desde
`session_start` o solo cuando un comando/herramienta los requiera, y liberálos desde
un controlador idempotente `session_shutdown`. La recarga reemplaza el tiempo de
ejecución, así que el código después de `await ctx.reload()` no debe reutilizar estado
del tiempo de ejecución anterior.

Pi expone varios puntos de integración:

- `pi.registerTool()` agrega una operación que el modelo puede llamar.
- `pi.registerCommand()` agrega un comando `/`.
- `pi.on()` observa o transforma el comportamiento del ciclo de vida.
- `pi.registerProvider()` agrega un model provider.
- `pi.registerMcpServer()` agrega un servidor para la sesión actual.
- `pi.appendEntry()` persiste datos de sesión fuera del contexto.

Las herramientas necesitan un nombre, una descripción para el modelo, un esquema de
parámetros TypeBox y una función `execute()`. Un resultado tiene contenido para el
modelo más detalles opcionales para renderizado o reconstrucción. Las llamadas a
herramientas de un mensaje de asistente pueden ejecutarse en paralelo, así que no
supongas que otra llamada hermana ya terminó. Si las mutaciones de archivos comparten
estado, protegé toda la operación de leer-modificar-escribir con la cola de mutación
de archivos de Pi.

La exposición de herramientas es otro mecanismo importante. Las herramientas `direct`
se declaran al modelo. Las herramientas `codemode` son invocables desde scripts pero
no se declaran directamente. Las herramientas `deferred` se encuentran mediante
búsqueda, y las `hidden` están registradas pero son inalcanzables. Esto permite un
conjunto amplio de capacidades sin convertir cada prompt en un catálogo de
herramientas. No es un límite de seguridad por sí mismo; los permisos aún pertenecen
a la tubería de herramientas.

## Dónde se cargan las extensiones

El directorio del agente convencionalmente contiene `extensions/`; un proyecto de
confianza puede contener `.pi/extensions/`. La configuración también puede listar
rutas de extensiones. Los recursos de usuario y proyecto tienen implicancias
distintas: la configuración de proyecto se carga solo después de otorgar confianza
al proyecto. Revisá las declaraciones del proyecto antes de conceder esa confianza
porque sus extensiones ejecutan código.

Gentle Shell es un ejemplo de un paquete construido con extensiones. Su paquete
incluye capacidades de presentación y flujo de trabajo como Gentle Agents, Gentle
Todo, Gentle Stats, un registro de provider NaN, preguntas y elecciones, soporte de
estado y notificaciones, y un banner de inicio. La lección importante no es memorizar
esos nombres de archivo. Es reconocer que un producto puede componer muchas
integraciones pequeñas de tiempo de ejecución mientras Pi sigue siendo el proceso
host.

## Empaquetá una personalización coherente

Un paquete de Pi es un directorio común o paquete npm que puede distribuir
extensiones, skills, prompt templates y themes juntos. Una estructura convencional
usa `extensions/`, `skills/`, `prompts/` y `themes/`. Como alternativa, la clave
`pi` en `package.json` nombra explícitamente rutas de recursos y patrones glob. Usá
un paquete cuando los recursos pertenezcan juntos o deban compartirse mediante npm o
git; no crees uno solo para guardar un único archivo Markdown personal.

Instalá fuentes con Pi en lugar de un comando general de gestor de paquetes:

```bash
pi install npm:@example/pi-tools@1.0.0
pi install git:github.com/example/pi-tools@v1
pi install ./local-package
pi list
```

Una instalación normal es personal y escribe en la configuración del agente. Agregá
`--local` (o `-l`) para declararlo en `.pi/settings.json`; esa declaración instala y
carga solo después de la confianza del proyecto. `pi remove <source>` elimina una
fuente configurada, y `pi update --extensions` reconcilia las instalaciones de
paquetes. Una especificación npm versionada, etiqueta Git o commit queda fijada, lo
que hace más reproducible la fuente que revisaste.

Las dependencias de paquetes merecen la misma disciplina de límites. Las bibliotecas
de tiempo de ejecución importadas por extensiones pertenecen a `dependencies`. Los
paquetes host de Pi pertenecen a `peerDependencies` con un rango `"*"`, no a las
dependencias, porque una copia host empaquetada puede crear clases y registros
duplicados. Pi no instala ni modifica paquetes locales, así que su árbol de
dependencias sigue siendo responsabilidad de quien lo creó.

La configuración puede limitar un paquete a extensiones, skills, prompts o themes
seleccionados. Omitir un tipo de recurso carga lo que permite el paquete; un arreglo
vacío no carga nada de ese tipo. Estos filtros solo restringen el manifiesto propio
de un paquete: no pueden exponer un recurso no declarado.

## Errores comunes

- Tratar una extensión como configuración inofensiva en lugar de código ejecutable.
- Iniciar un watcher en la factory de la extensión y filtrarlo entre recargas.
- Poner una biblioteca de Pi provista por el host en `dependencies`.
- Declarar un paquete de proyecto sin considerar que la confianza controla su carga.
- Reimplementar como código un flujo de trabajo solo de texto cuando alcanza una skill o template.

## Probalo

Ejecutá `pi list` para inspeccionar los paquetes configurados sin cambiarlos. Después
inspeccioná las carpetas de recursos de tu directorio de agente e identificá una
personalización como skill, template, theme o extensión. Explicá qué capacidad
ejecutable, si alguna, hace necesaria la elección de extensión. Esa explicación vale
más que instalar un paquete de demostración que no pensás mantener.
