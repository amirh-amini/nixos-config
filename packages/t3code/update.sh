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
#   cli      ← npm tarball hash + the shared vendored manifest/lockfile:
#              package.json is the newest release's manifest with monorepo
#              override keys ("pkg>pkg") stripped, lock regenerated with
#              `npm install --package-lock-only`, npmDepsHash computed with
#              prefetch-npm-deps (exactly what buildNpmPackage expects — no
#              build-retry loop needed)
#
# Rewrites default.nix (+ vendored files when they change); nothing else to touch.
# Afterwards:  nh os switch
set -euo pipefail
cd "$(dirname "$0")"

nix_file=default.nix
data_dir=.
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
  patch_json[$ch]=$(
    node -e 'console.log(JSON.stringify({
      [process.argv[1]]: {
        version: process.argv[2],
        hash: process.argv[3],
        srcHash: process.argv[4],
      },
    }))' "$ch" "$ver" "$appimage_hash" "$tarball_hash"
  )
done

if [[ $any_change == 0 ]]; then exit 0; fi

# The vendored manifest+lockfile serve BOTH cli builds, so they are always
# cut from upstream's newest release (the nightly — its dependency set is a
# superset of stable's): strip monorepo override keys, resolve a fresh lock,
# hash the dep cache.
ver=${want[nightly]}

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl -fsSL "https://registry.npmjs.org/$pkg/-/$pkg-$ver.tgz" | tar xz -C "$work"

node -e '
const fs = require("fs");
const p = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
const clean = o => {
  if (Array.isArray(o)) return o.map(clean);
  if (o && typeof o === "object") {
    const r = {};
    for (const [k, v] of Object.entries(o)) if (!k.includes(">")) r[k] = clean(v);
    return r;
  }
  return o;
};
fs.writeFileSync(process.argv[1], JSON.stringify(clean(p), null, 2) + "\n");
' "$work/package/package.json"

(
  cd "$work/package"
  npm install --package-lock-only --ignore-scripts --no-audit --no-fund --silent
)

deps_hash=$(nix shell nixpkgs#prefetch-npm-deps -c sh -c \
  "prefetch-npm-deps '$work/package/package-lock.json'")

cp "$work/package/package.json" "$data_dir/package.json"
cp "$work/package/package-lock.json" "$data_dir/package-lock.json"

T3_DEPS_HASH="$deps_hash" node -e '
const fs = require("fs");
const [file, patchesJson] = process.argv.slice(1);
const deps = process.env.T3_DEPS_HASH;
let s = fs.readFileSync(file, "utf8");
for (const [block, p] of Object.entries(JSON.parse(patchesJson))) {
  // each channel owns two blocks: the desktop AppImage build and the cli
  // npm build — patch both (keys absent from a block simply do not match)
  for (const kind of ["desktop", "cli"]) {
    const anchor = `t3code-${kind}-${block}`;
    const start = s.indexOf(anchor);
    if (start < 0) throw new Error(`block not found: ${anchor}`);
    const end = s.indexOf("\n    };", start);
    let seg = s.slice(start, end);
    for (const [key, val] of Object.entries(p))
      seg = seg.replace(new RegExp(`(${key} = )"[^"]*";`), `$1"${val}";`);
    s = s.slice(0, start) + seg + s.slice(end);
  }
}
// both cli blocks share one vendored lockfile — keep their hashes in lockstep
s = s.replace(/depsHash = "[^"]*";/g, `depsHash = "${deps}";`);
fs.writeFileSync(file, s);
' "$nix_file" "$(node -e '
const merged = {};
for (const j of process.argv.slice(1)) Object.assign(merged, JSON.parse(j));
console.log(JSON.stringify(merged));
' "${patch_json[@]}")"

echo "t3code.nix + vendored lockfile updated — now rebuild:"
echo "  nh os switch"
