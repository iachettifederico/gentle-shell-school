# Exploration handoff

`src/index.js:1` reads the configured greeting and `src/index.js:4` wires it to
the formatter. `src/format.js:2` owns the output shape, while `src/config.js:1`
provides the current greeting.

Next, add behavior tests around the formatter before changing the greeting.
