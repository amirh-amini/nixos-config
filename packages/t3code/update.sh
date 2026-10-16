#!/usr/bin/env bash
# Update t3code stable/nightly channels to upstream latest, all four packages:
#
#   ./update.sh              # bump both channels
#   ./update.sh stable       # only the stable channel
#   ./update.sh nightly      # only the nightly channel
#
# Channel discovery mirrors upstream publishing:
#   version  ← npm dist-tags of the `t3` package (latest / nightly); the
#              desktop AppImages carry the same versions as GitHub tags
#   desktop  ← release AppImage, hashed directly
#   cli      ← the npm launcher tarball (thin: bin/t3.js + dist/bin.mjs
#              that spawn the platform bundle's prebuilt executable) plus
#              the linux-x64 bundle tarball, both hashed directly. No npm
#              dependency resolution: the bundle ships its own node_modules
#              and npm cannot install it anyway (its bundled deps pin libc
#              variants that npm's platform check rejects — see default.nix)
#
# Rewrites default.nix; nothing else to touch.
# Afterwards:  nh os switch
set -euo pipefail
cd "$(dirname "$0")"

nix_file=default.nix
pkg=t3

prefetch() { # url → sri hash; hard-fails on download/parse errors
  local out
  out=$(nix store prefetch-file --json "$1") || {
    echo "prefetch failed: $1" >&2
    return 1
  }
  node -e 'const h=JSON.parse(process.argv[1]).hash;
    if (!h) { console.error("prefetch returned no hash"); process.exit(1); }
    console.log(h)' "$out"
}

channels="${*:-stable nightly}"

mapfile -t tags < <(curl -fsSL "https://registry.npmjs.org/-/package/$pkg/dist-tags" |
  node -e 'let d="";process.stdin.on("data",c=>d+=c).on("end",()=>{const t=JSON.parse(d);console.log(t.latest);console.log(t.nightly)})')
declare -A want=([stable]=${tags[0]} [nightly]=${tags[1]})

any_change=0
declare -A patch_json=()
for ch in $channels; do
  ver=${want[$ch]}
  cur=$(node -e "
    const s=require('fs').readFileSync('$nix_file','utf8');
    const b=s.slice(s.indexOf('t3code-desktop-$ch'));
    console.log(b.match(/version = \"([^\"]+)\";/)[1])")
  # an empty hash means a previous run was interrupted mid-patch — repair it
  cur_hash=$(node -e "
    const s=require('fs').readFileSync('$nix_file','utf8');
    const b=s.slice(s.indexOf('t3code-desktop-$ch'));
    console.log(b.match(/hash = \"([^\"]*)\";/)?.[1] ?? '')")
  if [[ "$ver" == "$cur" && -n "$cur_hash" ]]; then
    echo "t3 $ch already on latest: $ver"
    continue
  fi
  any_change=1
  echo "t3 $ch: $cur -> $ver"

  # plain assignments so a prefetch failure aborts the script (set -e);
  # inside "\$( )" argument positions bash would swallow it
  appimage_hash=$(prefetch "https://github.com/pingdotgg/t3code/releases/download/v$ver/T3-Code-$ver-x86_64.AppImage")
  tarball_hash=$(prefetch "https://registry.npmjs.org/$pkg/-/$pkg-$ver.tgz")
  bundle_hash=$(prefetch "https://registry.npmjs.org/@t3code/t3-linux-x64/-/t3-linux-x64-$ver.tgz")
  patch_json[$ch]=$(
    node -e 'console.log(JSON.stringify({
      [process.argv[1]]: {
        version: process.argv[2],
        hash: process.argv[3],
        srcHash: process.argv[4],
        bundleHash: process.argv[5],
      },
    }))' "$ch" "$ver" "$appimage_hash" "$tarball_hash" "$bundle_hash"
  )
done

if [[ $any_change == 0 ]]; then exit 0; fi

node -e '
const fs = require("fs");
const [file, patchesJson] = process.argv.slice(1);
let s = fs.readFileSync(file, "utf8");
const patches = JSON.parse(patchesJson);

// Block boundaries come from the attribute anchors: each `t3code-… = mk`
// block runs to the next anchor, the last to EOF. Never derive boundaries
// from indentation or brace patterns — when a terminator lookup misses,
// slice() silently runs to EOF and a first-match replacement patches the
// wrong package (that is how the stable cli once received the nightly
// tarball hash).
const re = /t3code-(desktop|cli)-(stable|nightly) = mk/g;
const anchors = [...s.matchAll(re)].map((m) => ({
  name: `${m[1]}-${m[2]}`,
  start: m.index,
}));
if (anchors.length !== 4) {
  throw new Error(`expected 4 package blocks, found ${anchors.length}`);
}
for (let i = 0; i < anchors.length; i++) {
  anchors[i].end = i + 1 < anchors.length ? anchors[i + 1].start : s.length;
}

// Keys each block type must receive. A miss here is a hard error, never a
// silent skip — a value that fails to land must abort the run, not vanish.
const required = { desktop: ["version", "hash"], cli: ["version", "srcHash", "bundleHash"] };

// Splice in reverse document order so earlier offsets survive the edits.
for (const { name, start, end } of [...anchors].sort((a, b) => b.start - a.start)) {
  const [kind, channel] = name.split("-");
  const p = patches[channel];
  if (!p) continue; // channel not being updated in this run
  let seg = s.slice(start, end);
  for (const key of required[kind]) {
    if (typeof p[key] !== "string" || p[key] === "") {
      throw new Error(`${name}: patch data missing "${key}"`);
    }
    const patched = seg.replace(new RegExp(`(${key} = )"[^"]*";`), `$1"${p[key]}";`);
    if (patched === seg) throw new Error(`${name}: required key "${key} = " not found`);
    seg = patched;
  }
  s = s.slice(0, start) + seg + s.slice(end);
}

// Integrity gate before writing: every freshly written value must occur
// exactly once in the file, and inside the block it was written to.
const marks = [...s.matchAll(re)];
const blockOf = (name) => {
  const i = marks.findIndex((m) => `${m[1]}-${m[2]}` === name);
  if (i < 0) throw new Error(`block missing after patch: ${name}`);
  const next = marks[i + 1];
  return s.slice(marks[i].index, next ? next.index : s.length);
};
for (const [channel, p] of Object.entries(patches)) {
  for (const [key, block] of [
    ["hash", `desktop-${channel}`],
    ["srcHash", `cli-${channel}`],
    ["bundleHash", `cli-${channel}`],
  ]) {
    const n = s.split(p[key]).length - 1;
    if (n !== 1) {
      throw new Error(`${block}: "${key}" value occurs ${n}x in file, expected exactly 1`);
    }
    if (!blockOf(block).includes(p[key])) {
      throw new Error(`${block}: "${key}" value landed outside its block`);
    }
  }
}

fs.writeFileSync(file, s);
' "$nix_file" "$(node -e '
const merged = {};
for (const j of process.argv.slice(1)) Object.assign(merged, JSON.parse(j));
console.log(JSON.stringify(merged));
' "${patch_json[@]}")"

echo "t3code.nix updated — now rebuild:"
echo "  nh os switch"
