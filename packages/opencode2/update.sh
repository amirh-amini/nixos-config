#!/usr/bin/env bash
# Pin pkgs.opencode2 to the newest OpenCode 2 build on a chosen channel.
#
#   ./update.sh          # newest of the beta and latest channels (default)
#   ./update.sh beta     # force the beta channel
#   ./update.sh latest   # force the latest (stable) channel
#   ./update.sh dev      # bleeding edge, branch-head builds (no desktop)
#
# Version and npm package name both come from OpenCode's update API — the
# same source the in-app /update banner uses, so this script and the banner
# can never disagree. The API names the current package, which absorbs npm
# scope moves: the CLI migrated @opencode-ai/* -> @opencode/* on 2026-09-07
# and this script kept silently reporting "latest" on the frozen old scope.
# Beta and latest trade the lead over time, so the default resolves both
# and pins whichever version is newer.
#
# Rewrites hashes.json (version, hash, tarball url) next to this script.
# Afterwards:  nh os build
set -euo pipefail
cd "$(dirname "$0")"

channel="${1:-}"

# Prints "<version>\n<package>" for one channel.
resolve() {
  local meta
  meta=$(curl -fsSL "https://opencode.ai/update/api/$1/cli/npm")
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
}

# Prints the newer of two versions. A prerelease (e.g. 0.0.0-dev-19530)
# loses to any release, and 2.x beats 0.x regardless of the build number.
newest() {
  node -e '
    const [a, b] = process.argv.slice(1);
    const key = (v) => {
      const m = v.match(/^(\d+)\.(\d+)\.(\d+)(.*)$/);
      return m ? [+m[1], +m[2], +m[3], m[4] === "" ? 1 : 0] : [0, 0, 0, 0];
    };
    const ka = key(a), kb = key(b);
    console.log(ka < kb ? b : a);
  ' "$1" "$2"
}

if [[ -n "$channel" ]]; then
  resolution=$(resolve "$channel")
else
  beta_res=$(resolve beta)
  latest_res=$(resolve latest)
  newer=$(newest "$(sed -n '1p' <<<"$beta_res")" "$(sed -n '1p' <<<"$latest_res")")
  if [[ "$newer" == "$(sed -n '1p' <<<"$beta_res")" ]]; then
    resolution=$beta_res
  else
    resolution=$latest_res
  fi
fi
track="${channel:-beta+latest}"

version=$(sed -n '1p' <<<"$resolution")
pkg=$(sed -n '2p' <<<"$resolution")

current=$(node -e 'console.log(require("./hashes.json").version)')
if [[ "$version" == "$current" ]]; then
  echo "opencode2 already on newest $track: $version"
  exit 0
fi

echo "opencode2 $track: $current -> $version"
plat="${pkg}-linux-x64"
url="https://registry.npmjs.org/$plat/-/${plat#@*/}-$version.tgz"
hash=$(nix store prefetch-file --json "$url" |
  node -e 'let d="";process.stdin.on("data",c=>d+=c).on("end",()=>console.log(JSON.parse(d).hash))')

node -e 'require("fs").writeFileSync("./hashes.json", JSON.stringify({version:process.argv[1],hash:process.argv[2],url:process.argv[3]},null,2)+"\n")' "$version" "$hash" "$url"
echo "hashes.json updated — now rebuild:"
echo "  nh os build"
