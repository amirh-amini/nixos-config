#!/usr/bin/env bash
# Pin pkgs.opencode2 to the newest OpenCode 2 build on a chosen channel.
#
#   ./update.sh          # beta (default — the official OpenCode 2 channel)
#   ./update.sh dev      # bleeding edge, if you ever want it
#
# Version and npm package name both come from OpenCode's update API — the
# same source the in-app /update banner uses, so this script and the banner
# can never disagree. The API names the current package, which absorbs npm
# scope moves: the CLI migrated @opencode-ai/* -> @opencode/* on 2026-09-07
# and this script kept silently reporting "latest" on the frozen old scope.
#
# Rewrites hashes.json (version, hash, tarball url) next to this script.
# Afterwards:  nh os build
set -euo pipefail
cd "$(dirname "$0")"

channel="${1:-beta}"

# Prints "<version>\n<package>". Update API first; npm dist-tags of the
# current scope as a fallback in case the API endpoint is down.
resolve() {
  local meta
  if meta=$(curl -fsSL "https://opencode.ai/update/api/$channel/cli/npm" 2>/dev/null); then
    node -e '
      const m = JSON.parse(process.argv[1]);
      const pkg = m.metadata && m.metadata.package;
      if (!m.version || !pkg) {
        console.error("update api response missing version/package");
        process.exit(1);
      }
      console.log(m.version);
      console.log(pkg);
    ' "$meta"
    return
  fi
  echo "warning: update API unreachable, falling back to npm dist-tags for @opencode/cli" >&2
  curl -fsSL "https://registry.npmjs.org/-/package/@opencode%2fcli/dist-tags" |
    node -e 'let d="";process.stdin.on("data",c=>d+=c).on("end",()=>{const t=JSON.parse(d);const v=t[process.argv[1]];if(!v){console.error(`dist-tag "${process.argv[1]}" not found`);process.exit(1)}console.log(v);console.log("@opencode/cli")})' "$channel"
}

resolution=$(resolve)
version=$(sed -n '1p' <<<"$resolution")
pkg=$(sed -n '2p' <<<"$resolution")

current=$(node -e 'console.log(require("./hashes.json").version)')
if [[ "$version" == "$current" ]]; then
  echo "opencode2 already on latest $channel: $version"
  exit 0
fi

echo "opencode2 $channel: $current -> $version"
plat="${pkg}-linux-x64"
url="https://registry.npmjs.org/$plat/-/${plat#@*/}-$version.tgz"
hash=$(nix store prefetch-file --json "$url" |
  node -e 'let d="";process.stdin.on("data",c=>d+=c).on("end",()=>console.log(JSON.parse(d).hash))')

node -e 'require("fs").writeFileSync("./hashes.json", JSON.stringify({version:process.argv[1],hash:process.argv[2],url:process.argv[3]},null,2)+"\n")' "$version" "$hash" "$url"
echo "hashes.json updated — now rebuild:"
echo "  nh os build"
