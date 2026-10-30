---
title: "Perfiles y enrutamiento de modelos"
description: "Asigná modelos deliberadamente al orquestador y a roles enfocados."
module: "Delegación"
---

# Perfiles y enrutamiento de modelos

Elegir un modelo es parte de un plan de trabajo. Afecta el costo, la latencia y
la calidad del razonamiento disponible para una tarea en particular. La pregunta
útil no es “¿qué modelo es mejor?”. Es “¿qué capacidad necesita este rol y cuál
es la ruta menos costosa que todavía la proporciona?”. Gentle Shell hace explícita
esa pregunta mediante perfiles y enrutamiento por agente, en vez de dejar
silenciosamente que cada ayudante herede un valor predeterminado accidental.

Los identificadores de modelos usan el formato `provider/model`. El proveedor no
es algo cosmético: identifica la ruta utilizada para obtener el modelo. Cuando
uses modelos OpenAI en estos ejemplos, usá el proveedor `openai-codex` en lugar
de `openai` sin prefijo. Por ejemplo, un identificador con una forma válida es:

```text
openai-codex/<model>
```

`<model>` es un marcador de posición, no una recomendación ni un valor copiado
de la configuración de otra persona. Los modelos que realmente podés seleccionar
dependen de los proveedores y las credenciales disponibles en tu instalación. No
deduzcas que un modelo nombrado en un ejemplo de configuración está disponible
para vos.

## Límite de tiempo de ejecución según el contexto

El tiempo de ejecución dimensiona el respaldo de contexto de la sesión padre a
partir de su modelo resuelto: `min(150k tokens, 0.15 × context window)`. Podés
configurarlo con `GENTLE_PI_CONTEXT_BACKSTOP_TOKENS` y
`GENTLE_PI_CONTEXT_BACKSTOP_FRACTION`. Así, la capacidad de contexto del modelo
es una entrada operativa para la asignación, en vez de una razón para adivinar
cuándo una sesión larga debe delegar su próxima unidad acotada.

## Dos controles de enrutamiento relacionados

Gentle Shell describe los perfiles con nombre como una forma de enrutar el
orquestador de manera atómica: un perfil puede elegir juntos el modelo y el
esfuerzo del orquestador. Lo hace de forma independiente de los roles empaquetados
y de revisión. El perfil activo está vinculado a la sesión padre, y el enrutamiento
se aplica por sesión. Un repositorio puede fijar un perfil para que sus subagentes
dejen de seguir el perfil activo globalmente. La interfaz de perfiles muestra el
enrutamiento efectivo que utiliza el tiempo de ejecución, lo cual es más útil que
adivinar a partir de un archivo de configuración viejo.

El enrutamiento por agente es complementario. La configuración de subagentes tiene
un mapa `model_profiles` cuyas claves son nombres de agentes y cuyos valores
pueden contener un identificador `model`. Su *forma* puede representarse sin
exponer las elecciones personales de nadie:

```json
{
  "model_profiles": {
    "gentle-ai-explore": { "model": "provider/reading-model" },
    "gentle-ai-worker": { "model": "provider/writing-model" },
    "gentle-ai-verify": { "model": "provider/review-model" }
  }
}
```

Este es un ejemplo genérico, no un catálogo de modelos instalados. Enseña el
mecanismo: el rol con nombre es el destino de enrutamiento estable, mientras que
la cadena del modelo es la elección calificada por proveedor. Mantené separadas la
configuración y las credenciales; un perfil de modelo no es un lugar para publicar
tokens ni detalles privados de una cuenta.

## Enrutá por rol, no por prestigio

El explorador, el worker y el verificador hacen trabajos distintos. Un explorador
condensa investigación de solo lectura en evidencia e incertidumbre. Un worker lee
una especificación acotada, edita superficies autorizadas y comprueba el resultado.
Un verificador realiza una comprobación independiente de solo lectura. Darles a los
tres la misma ruta costosa puede desperdiciar presupuesto cuando la exploración es
rutinaria; darles a los tres la ruta más barata puede debilitar una implementación
o revisión difícil.

Por eso, un plan consciente del costo comienza por el modo de fallo del rol. Las
lecturas intensas y el mapeo rutinario a menudo pueden usar un modelo más barato o
respaldado por suscripción cuando puede producir de manera confiable un mapa basado
en evidencia. La escritura intensiva necesita capacidad suficiente para seguir
requisitos detallados, preservar convenciones locales y verificarse a sí misma. La
verificación independiente necesita cuidado suficiente para cuestionar las
suposiciones de quien escribe; no debería seleccionarse solamente porque es el
mismo modelo que realizó el cambio.

Eso es una compensación, no una jerarquía universal. Un cambio acotado y conocido
puede no necesitar delegación ni una ruta adicional. Un cambio de alto riesgo puede
justificar un verificador independiente más capaz. El padre todavía elige primero
la topología: el costo del modelo nunca crea permiso para delegar, y un modelo
barato nunca vuelve segura una tarea vaga.

## Configurá sin perder el hilo

El patrón de configuración genérico de arriba es deliberadamente pequeño. Primero
elige roles. Luego decidí si un perfil de sesión o una fijación del repositorio
debe gobernar la sesión padre. Después, mapeá cada rol ayudante configurado a un
valor `provider/model` que hayas confirmado que está disponible. Por último, usá
la visualización de enrutamiento efectivo del tiempo de ejecución para verificar
qué sucederá realmente.

Los registros de perfiles de sesión admiten selecciones explícitas de modelo y
opciones de razonamiento. Una vinculación guardada es una instantánea: puede
contener entradas de modelo por rol como
`{"worker":{"model":"provider/model"}}`. El razonamiento válido tiene
precedencia sobre el campo `effort` más antiguo cuando aparecen ambos. El formato
del registro es un contrato de persistencia, no una invitación a editar manualmente
el historial de sesión; dejá que los controles admitidos hagan las selecciones.

Un agente empaquetado también puede declarar un modelo predeterminado en su
definición. La configuración de enrutamiento permite que el perfil elegido por la
persona usuaria reemplace el carácter accidental de ese valor predeterminado. El
resultado es predecible: el rol sigue siendo reconocible, mientras que la elección
del modelo sigue siendo tuya.

## Una sola pantalla de modelos: `/gentle:profiles`

```text
/gentle:profiles
```

abre la pantalla de modelos en el perfil que resuelve este repositorio: una
tabla, con tus perfiles como pestañas arriba. Reemplaza al retirado
`/gentle:models`. Los símbolos de las pestañas muestran dónde rige un perfil: `◉`
esta sesión, `★` el predeterminado para sesiones nuevas, `⌂` este repositorio.
Si salís de una pestaña con ediciones sin guardar, primero te pregunta: **Save and
switch**, **Discard** o **Stay**.

La tabla es el enrutamiento de ese perfil. El orquestador es la primera fila y
después vienen los agentes; `enter` elige un modelo y `e` elige un esfuerzo entre
los niveles que ese modelo admite. Cambiar todos los agentes a la vez con el
encabezado `Model ▾` o `Effort ▾` nunca toca la fila del orquestador.

Tres botones deciden dónde se aplica el perfil, y son el centro de esta lección:

- **Use in this session** (`u`) vincula el perfil solo a esta sesión de Pi y
  cambia su orquestador. No escribe enrutamiento compartido, valores
  predeterminados ni fijaciones, pero las ediciones pendientes de la tabla se
  guardan primero en el perfil, como haría **Save**.
- **Make default** (`d`) lo vuelve el predeterminado para sesiones nuevas con una
  aplicación global protegida (confirmación del diff, reversión). Dentro de un
  repositorio fijado a un perfil, vuelve a fijar ese repositorio en vez de mover
  el enrutamiento global.
- **Save** (`s` o `ctrl+s`) escribe lo que ves en el perfil, nada más.

El menú del perfil (`▾` en la pestaña activa, o `m`) tiene **Rename**,
**Duplicate**, **Use in this repo** (la fijación local del clon) y **Delete**;
**+ New** (`n`) copia el perfil actual, captura lo que está corriendo o arranca
vacío. Las operaciones de archivo son subcomandos: `/gentle:profiles export
<name>`, `import` y `publish <name>` (la declaración compartida del repositorio),
más `export-routing` y `restore-routing` para el archivo de enrutamiento global.

## Errores frecuentes

El primer error es omitir el prefijo del proveedor. `model-name` por sí solo no
dice qué ruta de proveedor debe servirlo. El segundo es usar `openai` sin prefijo
cuando la ruta prevista es `openai-codex/<model>`. El tercero es copiar el
`subagents.json` de otra persona textualmente. Puede codificar modelos no
disponibles o preferencias privadas y no enseña la decisión detrás de las
elecciones.

El cuarto es equiparar “más barato” con “seguro”. Los ahorros provienen de hacer
coincidir el modelo con trabajo acotado, evitar delegación innecesaria y mantener
precisas las entregas. No provienen de debilitar la revisión independiente ni de
cambiar silenciosamente la política de enrutamiento de un repositorio.

## Probalo

Abrí tus controles de perfil o modelo y anotá la ruta efectiva que se muestra para
la sesión padre. Después, hacé un plan en papel para una funcionalidad hipotética:
identificá una tarea de exploración con mucha lectura, una tarea de escritura y una
tarea de verificación. Para cada una, escribí una ruta genérica `provider/model` y
una oración que explique por qué su costo y capacidad se ajustan al rol. Reemplazá
los marcadores de posición solo después de haber confirmado qué pone a disposición
tu propia instalación.
