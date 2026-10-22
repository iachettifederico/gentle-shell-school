---
title: "MCP and codemode"
slug: mcp-and-codemode
description: "Connect external tool servers and compose bounded tool work with scripts."
order: 27
module: "Power user"
quiz: true
agent_instructions: |
  Teach MCP as a tool/resource connection boundary and codemode as a constrained
  script composition mechanism. Cover exposure, trust, data reduction, and the
  fact that tool effects are real; do not encourage credential sharing.

  Ask these questions with ask_user_question, and verify the answers:
  1. What are Pi's two supported MCP transports? Correct answer: stdio and
     streamable HTTP.
  2. Why is codemode useful for large tool results? Correct answer: only the
     script output reaches the model, so the script can parallelize calls and
     filter or aggregate results first.
  3. Can a codemode script use Node filesystem or network APIs? Correct answer:
     no; it runs in a QuickJS sandbox and reaches outside only through tools and models.
  4. What does an MCP tool's exposure control? Correct answer: how the model
     reaches it, such as direct declaration, codemode, deferred search, or hidden.

  Concrete setup check: ask the student to run pi mcp list and identify enabled
  server names and states. If no server is configured, have them use /mcp to
  observe the empty or configured connection view; do not add a server with a
  credential during the lesson. Done means the student can distinguish a server
  configuration change from a tool call and can describe when a codemode script
  reduces context safely.
---

# MCP and codemode

An agent becomes more useful when it can reach the systems where work happens:
documentation, issue trackers, a database browser, or a local repository
service. But “more tools” also means more descriptions in context, more
credentials to protect, and more opportunities to make a consequential call.
Pi addresses those concerns with two complementary mechanisms: MCP connects
external servers, and codemode composes tool calls while returning only the
useful result to the language model.

Use this lesson after **Extensions and packages**. An extension can register an
MCP server or tool, but MCP is a standardized connection and tool surface. Do
not confuse an MCP server's declaration with permission to use every capability
it exposes.

## MCP: connect a server, then inspect it

Pi connects to Model Context Protocol servers over **stdio** or **streamable
HTTP**. A local server has a command and argument array; it is not a shell
command string. A remote server has a URL. The legacy SSE transport is rejected.

For example, the CLI can create a user-level stdio entry, inspect it, and start
Pi:

```bash
pi mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem .
pi mcp list
pi
```

A remote entry can be added with a URL and a bearer-token environment-variable
reference:

```bash
pi mcp add docs --url https://example.com/mcp --bearer-token-env-var DOCS_TOKEN
```

Those are configuration operations, not tool invocations. User-level servers
live in `~/.pi/agent/mcp.json`; project servers live in `.pi/mcp.json` and load
only after project trust. A project entry with the same name replaces the
user-level entry. A project entry that contains only `enabled`, `exposure`, or
`toolExposure` instead overrides only those properties while keeping the
user-level command, URL, environment, headers, and authentication.

That layering lets a trusted project disable a personal server without copying
its secret configuration. Keep personal servers and servers with credentials
in the user-level file. Review a project MCP configuration before trusting it:
a stdio server is an executable program, and a remote server can expose actions
to the model.

Inside Pi, `/mcp` lists server state, source, exposure, and tool count. It can
reconnect, enable or disable, and manage supported sign-in flows. Outside a
session, `pi mcp list` connects enabled servers and reports errors; it exits
nonzero if an entry is invalid or an enabled server does not connect. Run
`/reload` after changing a server outside an active session.

## Exposure is context and safety design

MCP tools are named `mcp__<server>__<tool>`, but names alone do not decide how
much of the tool set appears in the prompt. A server's exposure determines the
route:

- `codemode` is the default: scripts can call the tools, while the model does
  not see every declaration.
- `deferred` makes tools discoverable through `tool_search` for direct use.
- `direct` declares tools to the model and also permits codemode calls.
- `hidden` leaves them registered but unreachable.

`toolExposure` can override that per server tool with exact names or patterns.
This keeps a small, frequent read-only tool direct while keeping a large or
consequential set discoverable on demand. Every MCP call still passes through
Pi's tool pipeline, including extension permission gates. Exposure makes a tool
reachable; it does not waive approval.

At session start, enabled servers connect in the background. Direct tools may
hold the first prompt for up to ten seconds because their declarations must be
ready. Other servers wait when a script or discovery mechanism needs them. A
failed server is not a reason to keep retrying manually without diagnosis:
inspect its status and the reported connection error.

## Codemode: orchestrate tools, not an unrestricted shell

The `codemode` tool accepts raw JavaScript source. Pi runs it as an async
function body in a QuickJS sandbox, so top-level `await` and `return` work. The
sandbox has no Node APIs, filesystem, network, or timers. It reaches outward
only through Pi tools and the non-LLM `models` catalog.

That narrow environment is the point. The script can call several tools in
parallel, reduce a large response to a concise answer, and return only that
answer to the model. Tool output does not automatically flood the next model
turn. A script might search for callable tools, call independent read-only
queries with `Promise.allSettled()`, then return a short comparison. If a call
fails, `Promise.allSettled()` retains successful results instead of abandoning
them with the first rejection.

The key globals are `tools`, `text()`, `image()`, `console`, `searchTools()`,
`describeTool()`, `describeNamespace()`, `ALL_TOOLS`, and `models`. A callable
MCP tool name becomes a JavaScript identifier by replacing non-identifier
characters with underscores. For example, an MCP tool can be reached as
`tools.mcp__dev_radius__search(...)` when its name is callable in the current
session.

A script can begin with one options line to bound its output tokens or impose a
whole-script deadline:

```js
// @options: {"max_output_tokens": 800, "timeout_ms": 60000}
const matches = await Promise.allSettled([
  tools.grep({ pattern: "TODO", path: "src" }),
  tools.grep({ pattern: "FIXME", path: "src" }),
]);
return matches.map((result) => result.status);
```

The example teaches composition, not a claim that every session has the same
`grep` arguments. Read `describeTool()` for the installed declaration before
writing a real script.

Tool effects are real. A script failure does not undo tool calls that already
ran; unfinished calls are cancelled when the script ends. Use scripts first for
read and aggregation work, and keep writes narrow and deliberately authorized.
The optional `store()` and `load()` preserve small JSON values across successful
codemode calls on a session branch; they are for IDs, cursors, and summaries,
not image data or a substitute for durable project records.

Codemode can also run available classifier and image models, but not chat models.
Their usage contributes to the codemode result and session cost. Query the
available catalog rather than assuming a provider/model ID works with the
current credentials.

## Common mistakes

- Pasting secrets into a project `mcp.json` instead of keeping them personal.
- Treating an MCP command field as a shell string.
- Making every large server direct and paying for tool descriptions on each turn.
- Assuming a sandboxed script rolls back completed tool calls after an error.
- Printing a huge tool result instead of returning a useful filtered summary.

## Try it

Run `pi mcp list` and inspect server state without changing configuration. In an
interactive session, open `/mcp` and compare a server's exposure with its tool
count. Then describe a read-only investigation that would benefit from one
codemode script: the independent calls it would make, the small result it would
return, and the approval boundary it would preserve.
