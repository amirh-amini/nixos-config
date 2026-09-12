#!/usr/bin/env bash
# Pin pkgs.opencode2-desktop to the newest OpenCode 2 desktop build on a
# chosen channel.
#
#   ./update.sh          # beta (default — the official OpenCode 2 channel)
#
# Version, URL, and sha256 all come from OpenCode's update API — the same
# source the desktop in-app updater verifies against (the "opencode"
# distribution serves versioned files at opencode.ai/files/bin/<version>/).
# The API checksum is trusted, so nothing is downloaded here.
#
# Rewrites hashes.json (version, hash, url) next to this script.
# Afterwards:  nh os build
set -euo pipefail
cd "$(dirname "$0")"

channel="${1:-beta}"
asset="opencode-desktop-linux-x86_64.AppImage"

meta=$(curl -fsSL "https://opencode.ai/update/api/$channel/desktop")

resolution=$(node -e '
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
' "$meta" "$asset")

version=$(sed -n '1p' <<<"$resolution")
url=$(sed -n '2p' <<<"$resolution")
sha256=$(sed -n '3p' <<<"$resolution")

current=$(node -e 'console.log(require("./hashes.json").version)')
if [[ "$version" == "$current" ]]; then
  echo "opencode2-desktop already on latest $channel: $version"
  exit 0
fi

echo "opencode2-desktop $channel: $current -> $version"
hash="sha256-$(node -e 'console.log(Buffer.from(process.argv[1], "hex").toString("base64"))' "$sha256")"

node -e 'require("fs").writeFileSync("./hashes.json", JSON.stringify({version:process.argv[1],hash:process.argv[2],url:process.argv[3]},null,2)+"\n")' "$version" "$hash" "$url"
echo "hashes.json updated — now rebuild:"
echo "  nh os build"
