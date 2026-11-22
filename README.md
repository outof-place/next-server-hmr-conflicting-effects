# Server HMR: "conflicting effects for the same key" with a dynamic import in `instrumentation-client.ts`

Minimal reproduction for Next.js (Turbopack, `next dev`). Built from the
[reproduction template](https://github.com/vercel/next.js/tree/canary/examples/reproduction-template).

## The app

- `instrumentation-client.ts` dynamically imports `app/lazy.ts`.
- `app/lazy.ts` imports `react`.
- Two routes, `/` and `/other`, each with its own client component.

## Steps

```bash
npm install
npm run dev
```

Open `http://localhost:3000/`, then `http://localhost:3000/other`, then `/` again.
`./check.sh` does the same with `curl` and prints the evidence below.

## Current behavior

From the moment the second route has compiled, the dev server prints this on every request:

```
[Server HMR] Update failed, re-evaluating modules: [Error: conflicting effects for the same key (key length: 75 bytes)]
```

The key length is the length of the full path of
`.next/dev/static/chunks/_1anvha4rlo79g._.js`, the chunk list of the client entry, so the
number depends on where the repository is checked out. That path is the same for both
routes, but its content is not:

- The async loader of `app/lazy.ts` is emitted once per route under a different name,
  `static/chunks/[root-of-the-server]__<hash>._.js`. The two files are byte-identical.
- The entry's chunk list names the loader chunk of the route that was written last, so the
  file changes every time the other route is requested.

## Expected behavior

No Server HMR failure. The async loader of a module imported from
`instrumentation-client.ts` has one chunk name, whichever route is compiled.

## What makes it appear

- Remove `import { version } from "react"` from `app/lazy.ts`: no error, both routes share
  one loader chunk.
- Keep a single route: no error.

## Versions

`package.json` pins `16.5.0-canary.60`. The same app on other versions:

| next | Server HMR failures in 4 requests | loader chunk names across the two routes |
| --- | --- | --- |
| 16.4.6 | 0 | 1 |
| 16.5.0-canary.30 | 0 | 1 |
| 16.5.0-canary.31 | 3 | 2 |
| 16.5.0-canary.33 | 0 | 1 |
| 16.5.0-canary.34 | 3 | 2 |
| 16.5.0-canary.60 | 3 | 2 |
