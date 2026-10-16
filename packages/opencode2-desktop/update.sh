#!/usr/bin/env bash
# Pin pkgs.opencode2-desktop to the newest OpenCode 2 desktop build on a
# chosen channel.
#
#   ./update.sh          # newest of the beta and latest channels (default)
#   ./update.sh beta     # force the beta channel
#   ./update.sh latest   # force the latest (stable) channel
#
# Version, URL, and sha256 all come from OpenCode's update API — the same
# source the desktop in-app updater verifies against (the "opencode"
# distribution serves versioned files at opencode.ai/files/bin/<version>/).
# The API checksum is trusted, so nothing is downloaded here.
# Beta and latest trade the lead over time, so the default resolves both
# and pins whichever version is newer.
#
# Rewrites hashes.json (version, hash, url) next to this script.
# Afterwards:  nh os build
set -euo pipefail
cd "$(dirname "$0")"

channel="${1:-}"
asset="opencode-desktop-linux-x86_64.AppImage"

meta_for() {
  curl -fsSL "https://opencode.ai/update/api/$1/desktop"
}

# Extracts "<version>\n<url>\n<sha256>" for the desktop AppImage artifact.
resolution_for() {
  node -e '
    const m = JSON.parse(process.argv[1]);
    const a = (m.artifacts || []).find((a) => a.distribution === "opencode");
    const f = a && a.metadata && a.metadata.files && a.metadata.files[process.argv[2]];
    if (!a || !a.version || !f || !/^[0-9a-f]{64}$/.test(f.sha256)) {
      console.error("update api response missing expected " + process.argv[2]);
      process.exit(1);
    }
    console.log(a.version);
    console.log(f.url);
    console.log(f.sha256);
  ' "$(meta_for "$1")" "$asset"
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
  resolution=$(resolution_for "$channel")
else
  beta_res=$(resolution_for beta)
  latest_res=$(resolution_for latest)
  newer=$(newest "$(sed -n '1p' <<<"$beta_res")" "$(sed -n '1p' <<<"$latest_res")")
  if [[ "$newer" == "$(sed -n '1p' <<<"$beta_res")" ]]; then
    resolution=$beta_res
  else
    resolution=$latest_res
  fi
fi
track="${channel:-beta+latest}"

version=$(sed -n '1p' <<<"$resolution")
url=$(sed -n '2p' <<<"$resolution")
sha256=$(sed -n '3p' <<<"$resolution")

current=$(node -e 'console.log(require("./hashes.json").version)')
if [[ "$version" == "$current" ]]; then
  echo "opencode2-desktop already on newest $track: $version"
  exit 0
fi

echo "opencode2-desktop $track: $current -> $version"
hash="sha256-$(node -e 'console.log(Buffer.from(process.argv[1], "hex").toString("base64"))' "$sha256")"

node -e 'require("fs").writeFileSync("./hashes.json", JSON.stringify({version:process.argv[1],hash:process.argv[2],url:process.argv[3]},null,2)+"\n")' "$version" "$hash" "$url"
echo "hashes.json updated — now rebuild:"
echo "  nh os build"
