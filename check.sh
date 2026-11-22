#!/bin/bash
# Starts `next dev`, requests the two routes in turn and prints how many times the dev
# server logged the Server HMR conflict, then the evidence on disk.
set -u
PORT=${PORT:-3000}
LOG=dev.log
rm -rf .next
npx next dev --port "$PORT" > "$LOG" 2>&1 &
PID=$!
trap 'pkill -TERM -P "$PID" 2>/dev/null; kill -TERM "$PID" 2>/dev/null' EXIT

for _ in $(seq 1 120); do grep -q "Ready in" "$LOG" && break; sleep 1; done

for path in / /other / /other; do
  code=$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:$PORT$path")
  sleep 5
  echo "GET $path -> $code, conflict lines so far: $(grep -c 'conflicting effects' "$LOG")"
done

echo
grep -m1 'conflicting effects' "$LOG"
echo
echo "The async loader chunk of each route (same bytes, different names):"
for f in .next/dev/static/chunks/\[root-of-the-server\]__*._.js; do
  grep -q 'async loader' "$f" && echo "  $(cksum < "$f" | cut -d' ' -f1)  $f"
done
echo
echo "The chunk lists that name one of them (the entry's list has one path for both routes):"
grep -l 'TURBOPACK_CHUNK_LISTS' .next/dev/static/chunks/*.js | while IFS= read -r f; do
  echo "  $f -> $(grep -o 'static/chunks/\[root-of-the-server\][^"]*' "$f" | tr '\n' ' ')"
done
