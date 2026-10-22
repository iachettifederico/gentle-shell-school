---
title: "Models and Providers"
slug: models-and-providers
description: "Choose a model connection, authentication method, and thinking level without confusing subscriptions with API keys."
order: 9
module: "Foundations"
quiz: true
agent_instructions: |
  Teach the distinction between a provider, a model, credentials, and thinking
  levels. Explain `/login`, `/model`, `/thinking`, and why available models
  depend on usable authentication. Contrast a subscription/OAuth provider such
  as openai-codex with an API-key provider such as openai in general terms.
  Cover the built-in NaN provider without claiming a student has access to it.

  Ask these questions with ask_user_question, including the correct answer:
  1. What does `/model` show by default?
     Correct answer: Models whose providers have usable authentication.
  2. Which command chooses the current model's supported reasoning level?
     Correct answer: `/thinking`.
  3. What is the safe generic distinction between openai-codex and openai in
     this setup?
     Correct answer: openai-codex uses its provider sign-in/bearer-token route,
     while openai is the API-key provider using OPENAI_API_KEY.
  4. How can Pi authenticate without writing an API key to auth.json?
     Correct answer: Set the provider's environment variable before starting Pi.

  Have the student run `/model` and `/thinking`, then identify their active
  provider/model and the levels the selected model offers. The lesson is done
  when they can explain why a provider's model might not appear and how they
  would choose the correct credential route.
---

# Models and Providers

“Use a model” compresses several separate decisions: which service receives the
request, which model ID it uses, how Pi authenticates, and how much reasoning
the selected model supports. Separating those decisions prevents a costly class
of setup mistakes: supplying an API key to a subscription route, expecting an
OAuth sign-in to unlock an API-only model, or choosing a model name without
knowing which provider owns it.

## Provider, model, and credential are different things

A **provider** is Pi’s connection to a model service. A **model** is a specific
model offered through that provider. Pi references the pair as
`provider/model`, for example in `/model [provider/model]` or the CLI’s
`--model provider/id` form.

A provider also defines how Pi can authenticate. Most hosted providers support
one or both of these methods:

- browser or device-flow sign-in backed by OAuth;
- an API key.

Run `/login [provider]` to see the methods the current Pi release supports for
that provider. Pi can store the resulting credential in its private agent
configuration, or an API key can come from an environment variable set before
Pi starts. Environment variables are useful in CI or another environment where
Pi should not write a credential to disk.

Pi resolves credentials in an order that begins with a runtime `--api-key`, then
a stored credential, then an `apiKey` in `models.json`, and finally provider
environment variables or ambient cloud credentials. This is why a model’s
availability can change between terminals: the process must actually receive the
needed credential.

## Select a model and thinking level

The everyday interactive flow is simple:

```text
/login
/model
/thinking
```

`/model` searches models whose providers have usable authentication. Pressing
`Ctrl+S` in the picker saves the selection as a default for new sessions.
`/thinking` chooses the current model’s reasoning level, and Pi limits the
choices to levels the selected model supports. `Shift+Tab` cycles supported
levels; `Ctrl+S` in the thinking selector saves a startup level.

A session records model and thinking-level changes. Resuming it restores those
choices without changing the defaults for new sessions. That distinction is
useful when a focused investigation needs a different model but should not
silently change future work.

The CLI offers the same ideas noninteractively:

```bash
pi --model provider/model-id
pi --thinking high
pi --model model-id:high
```

The documented thinking-level vocabulary is `off`, `minimal`, `low`, `medium`,
`high`, `xhigh`, and `max`, but a given model may expose only a subset. More
reasoning is a model-specific capability and choice, not a promise that every
provider interprets each label identically.

## Subscription routes and API-key routes

A subscription and an API key are different payment and authentication routes.
Pi’s model documentation recommends signing in through `/login` when you have a
supported subscription, and using `/login` or an environment variable when you
have a provider API key.

For OpenAI-related choices, the provider name matters. The Pi command-line help
shows a bearer-token example for `openai-codex`:

```bash
pi auth print-bearer-token --provider openai-codex
```

It separately documents `OPENAI_API_KEY` as the API-key environment variable for
the `openai` provider. So use the provider attached to the access you actually
have: an `openai-codex` sign-in/bearer-token route for its subscription-style
provider access, and the `openai` route when you are using an OpenAI API key.
Do not assume an account sign-in is interchangeable with an API key, or that
provider names are cosmetic aliases.

This lesson intentionally stays generic. Provider catalogs, available models,
prices, and access rights can change. Let `/login` and `/model` show what your
running Pi can actually use rather than copying a model name from somebody
else’s terminal.

## Catalogs, custom endpoints, and availability

Pi starts with a bundled model catalog and can overlay newer catalog data from
pi.dev. Cached catalog data remains usable offline; `pi update --models` forces
a refresh. The catalog is a description of models and capabilities, not proof
that your account can call each one.

For a supported provider, the first troubleshooting question is whether it has
usable authentication. A custom model in `models.json` can load into Pi’s
configuration yet remain unavailable in `/model` until Pi resolves credentials.
For compatible endpoints such as local or proxy deployments, `models.json`
describes the provider endpoint and model list. Pi reloads that file when `/model`
opens, and an entry can add or replace a model with the same ID on that provider.

Use a provider extension instead when the service needs a custom streaming,
model-discovery, or authentication flow. A configuration file should describe
verified compatibility; it should not claim support merely because an endpoint
uses a familiar API label.

## NaN: a built-in provider with its own route

Gentle Shell includes the first-party `nan` provider; it needs no separate
provider package. You can supply `NAN_API_KEY` before starting Pi or use
`/login` and choose NaN (also `/login nan`), then choose a model with `/model`.
A stored key takes precedence over `NAN_API_KEY`.

NaN model discovery uses the authenticated model response intersected with a
maintained set of known chat model IDs. Before a successful refresh, Gentle
Shell documents an offline fallback list; after a successful refresh, the live
key-scoped list—including an empty one—is authoritative. Treat the selector as
the answer for your credential, not the fallback as a guarantee of entitlement.

Some NaN models manage reasoning depth themselves. For those models the workspace
reports `effort: auto`, and choosing a Pi thinking level does not change their
reasoning depth. This is a useful reminder that Pi’s common thinking interface
normalizes control where possible but does not erase provider behavior.

## Protect credentials and choose deliberately

Credentials in `auth.json` can be API keys or OAuth tokens. Keep that file
private and do not commit it. Project settings and extensions can execute inside
the Pi process after you trust a project, so do not load untrusted project
configuration casually. An environment variable avoids writing an API key to
that file, but it still must be handled as a secret in the environment that
starts Pi.

Choose the smallest confirmed route:

1. Identify the provider and model you need.
2. Use `/login` to see that provider’s supported sign-in options.
3. Use an API key only through the provider’s documented key route.
4. Confirm availability in `/model`.
5. Select a supported reasoning level in `/thinking`.

The upcoming lesson **Organic Driven Development** concerns how to conduct work
once a model is selected. It does not prescribe a personal model choice.

## Common mistakes

- **Treating a model ID as globally unique.** Include or verify its provider.
- **Putting an API key into a subscription/OAuth workflow.** Choose the route
  the provider documents.
- **Assuming a catalog entry proves access.** Authentication and account access
  still determine availability.
- **Assuming every thinking level works for every model.** Pi filters levels to
  model support.
- **Sharing `auth.json` or exported sessions casually.** They can contain
  credentials or other sensitive conversation material.

## Try it

Open `/model` and identify the provider/model pairs you can actually select.
Open `/thinking` and note the levels available for the current model. Then say
which credential route you would use for an `openai-codex` subscription-style
connection and which one you would use for an `openai` API-key connection. If a
model is missing, first check provider authentication instead of guessing a
model ID.
