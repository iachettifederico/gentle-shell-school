---
title: "Extensiones y paquetes"
description: "Agrega comportamiento ejecutable confiable a Pi y distribuye juntos recursos relacionados."
module: "Usuario avanzado"
---

# Extensiones y paquetes

Los prompts y las habilidades cambian lo que se le dice al modelo. Las extensiones
cambian lo que Pi puede hacer. Ese límite es la primera decisión de diseño: elige
instrucciones para un flujo de trabajo repetible guiado por personas, pero elige una
extensión cuando el flujo de trabajo necesite comportamiento ejecutable: herramientas,
comandos de barra, manejadores de eventos, proveedores, estado de sesión o interfaz de
usuario de terminal.

Una extensión es un módulo TypeScript o JavaScript que se ejecuta dentro del proceso de
Pi. Eso es potente y deliberadamente no informal: tiene los mismos permisos del
sistema operativo que Pi y puede inspeccionar prompts, llamadas a herramientas,
archivos, credenciales e historial de sesiones. Carga únicamente código fuente en el
que confíes. Un paquete puede agrupar extensiones con habilidades, plantillas, temas y
dependencias de tiempo de ejecución, así que también es territorio de revisión de
código y no solo una preferencia de estilo.

Esta lección se basa en **Skills** y **Writing skills**. Conserva la guía reutilizable
en una habilidad cuando no sea necesario ejecutar código. Usa una plantilla de prompt
para un comando de barra reutilizable que se expanda a texto. Recurre a una extensión
solo después de poder nombrar la capacidad de tiempo de ejecución que las instrucciones
no pueden proporcionar.

## El modelo de extensiones

Una extensión exporta una fábrica predeterminada que recibe `ExtensionAPI`. La fábrica
registra capacidades para ese tiempo de ejecución. Una pequeña extensión de comando
puede registrar un comando de barra; otra podría registrar una herramienta invocable
por el modelo o un manejador de eventos. Pi puede cargar directamente un archivo local
TypeScript con `pi --extension
./hello.ts`; `jiti` significa que el archivo local no necesita un paso de compilación
separado.

Elige cuidadosamente un límite de ciclo de vida. La fábrica puede registrar cosas, pero
no debería iniciar procesos, sockets, temporizadores ni observadores de larga duración:
Pi puede cargar una extensión sin iniciar una sesión. Inicia los recursos de sesión
desde `session_start` o solo cuando un comando/herramienta los requiera, y libéralos
desde un manejador `session_shutdown` idempotente. La recarga reemplaza el tiempo de
ejecución, así que el código posterior a `await ctx.reload()` no debe reutilizar el
estado del tiempo de ejecución anterior.

Pi expone varios puntos de integración:

- `pi.registerTool()` agrega una operación que el modelo puede llamar.
- `pi.registerCommand()` agrega un comando `/`.
- `pi.on()` observa o transforma el comportamiento del ciclo de vida.
- `pi.registerProvider()` agrega un proveedor de modelos.
- `pi.registerMcpServer()` agrega un servidor para la sesión actual.
- `pi.appendEntry()` conserva datos de sesión sin contexto.

Las herramientas necesitan un nombre, una descripción orientada al modelo, un esquema
de parámetros TypeBox y una función `execute()`. Un resultado tiene contenido orientado
al modelo más detalles opcionales para la representación o reconstrucción. Las llamadas
a herramientas de un mensaje de asistente pueden ejecutarse en paralelo, así que no
supongas que otra llamada hermana ha terminado. Si las mutaciones de archivos comparten
estado, protege toda la operación de lectura-modificación-escritura con la cola de
mutación de archivos de Pi.

La exposición de herramientas es otro mecanismo importante. Las herramientas `direct`
se declaran al modelo. Las herramientas `codemode` se pueden llamar desde scripts, pero
no se declaran directamente. Las herramientas `deferred` se encuentran mediante
búsqueda, y las `hidden` se registran pero son inaccesibles. Esto permite un conjunto de
capacidades amplio sin convertir cada prompt en un catálogo de herramientas. No es por
sí mismo un límite de seguridad; los permisos siguen perteneciendo al flujo de
herramientas.

## Dónde se cargan las extensiones

El directorio del agente convencionalmente contiene `extensions/`; un proyecto de
confianza puede contener `.pi/extensions/`. La configuración también puede listar rutas
de extensiones. Los recursos de usuario y de proyecto tienen implicaciones diferentes:
la configuración del proyecto se carga solo después de que se concede confianza al
proyecto. Revisa las declaraciones del proyecto antes de conceder esa confianza porque
sus extensiones ejecutan código.

Gentle Shell mismo es un ejemplo de un paquete construido con extensiones. Su conjunto
incluye capacidades de presentación y flujo de trabajo como Gentle Agents, Gentle Todo,
Gentle Stats, un registro de proveedor NaN, preguntas y elecciones, compatibilidad con
estado y notificaciones, y un banner de inicio. La lección importante no es memorizar
esos nombres de archivo. Es reconocer que un producto puede componer muchas pequeñas
integraciones de tiempo de ejecución mientras Pi sigue siendo el proceso anfitrión.

## Empaqueta una personalización coherente

Un paquete Pi es un directorio común o paquete npm que puede distribuir extensiones,
habilidades, plantillas de prompt y temas juntos. Un diseño convencional usa
`extensions/`, `skills/`, `prompts/` y `themes/`. Como alternativa, la clave `pi` en
`package.json` nombra explícitamente rutas de recursos y patrones glob. Usa un paquete
cuando los recursos pertenezcan juntos o deban compartirse mediante npm o git; no crees
uno solo para contener un único archivo Markdown personal.

Instala fuentes con Pi en lugar de con un comando general de administrador de paquetes:

```bash
pi install npm:@example/pi-tools@1.0.0
pi install git:github.com/example/pi-tools@v1
pi install ./local-package
pi list
```

Una instalación normal es personal y escribe en la configuración del agente. Agrega
`--local` (o `-l`) para declararla en `.pi/settings.json`; esa declaración instala y
carga solo después de la confianza del proyecto. `pi remove <source>` elimina una fuente
configurada, y `pi update --extensions` reconcilia las instalaciones de paquetes. Una
especificación npm versionada, etiqueta Git o commit queda fijado, lo que hace más
reproducible la fuente que revisaste.

Las dependencias de paquete merecen la misma disciplina de límites. Las bibliotecas de
tiempo de ejecución importadas por extensiones pertenecen a `dependencies`. Los paquetes
anfitriones de Pi pertenecen a `peerDependencies` con un rango `"*"`, no a dependencias,
porque una copia anfitriona agrupada puede crear clases y registros duplicados. Los
paquetes locales no son instalados ni modificados por Pi, por lo que su árbol de
dependencias sigue siendo responsabilidad de quien los crea.

La configuración puede limitar un paquete a extensiones, habilidades, prompts o temas
seleccionados. Omitir un tipo de recurso carga lo que permite el paquete; una matriz
vacía no carga nada de ese tipo. Estos filtros solo limitan el manifiesto propio de un
paquete; no pueden exponer un recurso no declarado.

## Errores comunes

- Tratar una extensión como configuración inofensiva en lugar de código ejecutable.
- Iniciar un observador en la fábrica de extensiones y filtrarlo entre recargas.
- Poner una biblioteca Pi proporcionada por el anfitrión en `dependencies`.
- Declarar un paquete de proyecto sin considerar que la confianza condiciona su carga.
- Reimplementar como código un flujo de trabajo solo de texto cuando basta una habilidad
  o plantilla.

## Pruébalo

Ejecuta `pi list` para inspeccionar los paquetes configurados sin cambiarlos. Luego
inspecciona las carpetas de recursos del directorio de tu agente e identifica una
personalización como habilidad, plantilla, tema o extensión. Explica qué capacidad
ejecutable, si existe alguna, hace necesaria la elección de extensión. Esa explicación
es más valiosa que instalar un paquete de demostración que no pretendes mantener.
