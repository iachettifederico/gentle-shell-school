---
title: "Perfiles y enrutamiento de modelos"
description: "Asigna modelos deliberadamente al orquestador y a los roles enfocados."
module: "Delegación"
---

# Perfiles y enrutamiento de modelos

La elección de un modelo es parte de un plan de trabajo. Afecta el costo, la latencia y la
calidad del razonamiento disponible para un trabajo particular. La pregunta útil no es “¿qué
modelo es mejor?”. Es “¿qué capacidad necesita este rol y cuál es la ruta menos costosa que aún la
proporciona?”. Gentle Shell hace explícita esa pregunta mediante perfiles y enrutamiento por
agente, en lugar de dejar silenciosamente que cada ayudante herede un valor predeterminado
accidental.

Los identificadores de modelos usan el formato `provider/model`. El proveedor no es cosmético:
identifica la ruta usada para obtener el modelo. Cuando uses modelos OpenAI en estos ejemplos,
usa el proveedor `openai-codex` en lugar de solo `openai`.
Por ejemplo, un identificador con una forma válida es:

```text
openai-codex/<model>
```

`<model>` es un marcador de posición, no una recomendación ni un valor copiado de la
configuración de otra persona. Los modelos que realmente puedes seleccionar dependen de los
proveedores y credenciales disponibles en tu instalación. No infieras que un modelo nombrado en un
ejemplo de configuración esté disponible para ti.

## Límite de tiempo de ejecución consciente del contexto

El tiempo de ejecución dimensiona el respaldo de contexto de la sesión padre a
partir de su modelo resuelto: `min(150k tokens, 0.15 × context window)`. Puedes
configurarlo con `GENTLE_PI_CONTEXT_BACKSTOP_TOKENS` y
`GENTLE_PI_CONTEXT_BACKSTOP_FRACTION`. Así, la capacidad de contexto del modelo
es una entrada operativa para el enrutamiento, en vez de una razón para adivinar
cuándo una sesión larga debe delegar su siguiente unidad delimitada.

## Dos controles de enrutamiento relacionados

Gentle Shell describe los perfiles con nombre como una forma de enrutar atómicamente al
orquestador: un perfil puede elegir juntos el modelo y el esfuerzo del orquestador.
Lo hace de forma independiente de los roles incluidos y de revisión. El perfil activo está
vinculado a la sesión principal, y el enrutamiento se aplica por sesión. Un repositorio puede fijar
un perfil para que sus subagentes dejen de seguir el perfil activo globalmente. La interfaz de
perfiles muestra el enrutamiento efectivo que el tiempo de ejecución está usando, lo cual es más
útil que adivinar a partir de un archivo de configuración antiguo.

El enrutamiento por agente es complementario. La configuración de subagentes tiene un mapa
`model_profiles` cuyas claves son nombres de agentes y cuyos valores pueden contener un
identificador `model`. Su *forma* puede representarse sin revelar las decisiones personales de
nadie:

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
mecanismo: el rol con nombre es el objetivo de enrutamiento estable, mientras que la cadena del
modelo es la elección calificada por proveedor. Mantén separadas la configuración y las
credenciales; un perfil de modelo no es un lugar para publicar tokens ni detalles privados de
cuentas.

## Enruta por rol, no por prestigio

El explorador, el trabajador y el verificador realizan trabajos diferentes. Un explorador condensa
la investigación de solo lectura en evidencia e incertidumbre. Un trabajador lee una especificación
delimitada, edita superficies autorizadas y verifica el resultado. Un verificador realiza una
comprobación independiente de solo lectura. Darles a los tres la misma ruta costosa puede
desperdiciar presupuesto cuando la exploración es rutinaria; darles a los tres la ruta más barata
puede perjudicar una implementación o revisión difícil.

Por lo tanto, un plan consciente del costo comienza con el modo de fallo del rol. La lectura
intensiva y el mapeo rutinario a menudo pueden usar un modelo más económico o respaldado por una
suscripción cuando puede producir de forma confiable un mapa respaldado por evidencia. La escritura
intensiva necesita suficiente capacidad para seguir requisitos detallados, preservar convenciones
locales y autoverificarse. La verificación independiente necesita suficiente cuidado para cuestionar
las suposiciones de un trabajador; no debe seleccionarse simplemente porque es el mismo modelo que
escribió el cambio.

Eso es una compensación, no una jerarquía universal. Un cambio limitado y conocido puede no
necesitar delegación ni una ruta adicional. Un cambio de alto riesgo puede justificar un
verificador independiente más potente. La sesión principal sigue eligiendo primero la topología: el
costo del modelo nunca crea permiso para delegar, y un modelo económico nunca hace segura una tarea
vaga.

## Configura sin perder el hilo

El patrón de configuración genérico anterior es intencionalmente pequeño. Primero elige los
roles. Luego decide si un perfil de sesión o una fijación de repositorio debe gobernar la sesión
principal. Después asigna a cada rol de ayudante configurado un valor `provider/model` que hayas
confirmado que está disponible. Finalmente, usa la pantalla de enrutamiento efectivo del tiempo de
ejecución para verificar lo que realmente ocurrirá.

Los registros de perfiles de sesión admiten selecciones explícitas de modelos y opciones de
razonamiento. Una vinculación guardada es una instantánea: puede contener entradas de modelos de
rol como `{"worker":{"model":"provider/model"}}`. El razonamiento válido tiene precedencia
sobre el campo antiguo `effort` cuando aparecen ambos. El formato del registro es un contrato de
persistencia, no una invitación a editar manualmente el historial de sesiones; deja que los
controles compatibles realicen las selecciones.

Un agente incluido también puede declarar un modelo predeterminado en su definición. La
configuración de enrutamiento permite que el perfil seleccionado por el usuario anule el carácter
accidental de ese valor predeterminado. El resultado es predecible: el rol sigue siendo reconocible
mientras la elección del modelo sigue siendo tuya.

## Elige el orquestador del perfil en `/gentle:models`

`/gentle:models` asigna el enrutamiento global de modelo y esfuerzo a los agentes, y tiene una
fila explícita `orchestrator`. Esa fila selecciona el modelo y el esfuerzo de razonamiento que
`u` guardará en el perfil actual. Su primer valor es la entrada guardada del perfil objetivo, o
**leave untouched** cuando ese perfil no tiene clave `orchestrator`. Elegir **leave untouched**
(o pulsar `i` en la fila) no guarda ninguna clave `orchestrator`. Cambiar la fila nunca cambia la
sesión activa, y **Set all agents** nunca la modifica.

Las dos teclas de guardado realizan trabajos distintos. `ctrl+s` guarda solo el enrutamiento de
agentes: no actualiza un perfil ni aplica el orquestador elegido. `u` guarda el mismo enrutamiento
de agentes y luego lo captura, junto con la elección explícita de orquestador, en el perfil actual.
Ninguna tecla cambia los valores predeterminados del orquestador en `settings.json` ni el modelo y
esfuerzo activos.

## Errores comunes

El primer error es omitir el prefijo del proveedor. `model-name` por sí solo no indica qué ruta de
proveedor debe servirlo. El segundo es usar solo `openai` cuando la ruta prevista es
`openai-codex/<model>`. El tercero es copiar el `subagents.json` de otra persona literalmente.
Puede codificar modelos no disponibles o preferencias privadas y no enseña la decisión detrás de
las elecciones.

El cuarto es equiparar “más barato” con “seguro”. Los ahorros provienen de ajustar el modelo al
trabajo delimitado, evitar delegación innecesaria y mantener las entregas precisas. No provienen de
debilitar la revisión independiente ni de cambiar silenciosamente la política de enrutamiento de un
repositorio.

## Pruébalo

Abre tus controles de perfil o modelo y anota la ruta efectiva mostrada para la sesión principal.
Después, haz un plan en papel para una funcionalidad hipotética: identifica una tarea de exploración
con mucha lectura, una tarea de escritura y una tarea de verificación. Para cada una, escribe una
ruta genérica `provider/model` y una oración que explique por qué su costo y capacidad se ajustan al
rol. Reemplaza los marcadores de posición solo después de haber confirmado lo que tu propia
instalación pone a disposición.
