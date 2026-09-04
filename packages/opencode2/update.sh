#!/usr/bin/env bash
# Pin pkgs.opencode2 to the newest OpenCode 2 build on a chosen npm channel.
#
#   ./update.sh          # beta (default — the official OpenCode 2 channel)
#   ./update.sh dev      # bleeding edge, if you ever want it
#   ./update.sh next     # whatever the `next` dist-tag points at
#
# Rewrites hashes.json next to this script; nothing else needs touching.
# Afterwards:  sudo nixos-rebuild switch --flake ~/nixos-config#nixos-btw
set -euo pipefail
cd "$(dirname "$0")"

channel="${1:-beta}"
pkg="@opencode-ai/cli"
plat="@opencode-ai/cli-linux-x64"

version=$(curl -fsSL "https://registry.npmjs.org/-/package/$pkg/dist-tags" |
  node -e 'let d="";process.stdin.on("data",c=>d+=c).on("end",()=>{const t=JSON.parse(d);const v=t[process.argv[1]];if(!v){console.error(`dist-tag "${process.argv[1]}" not found`);process.exit(1)}console.log(v)})' "$channel")

current=$(node -e 'console.log(require("./hashes.json").version)')
if [[ "$version" == "$current" ]]; then
  echo "opencode2 already on latest $channel: $version"
  exit 0
fi

echo "opencode2 $channel: $current -> $version"
url="https://registry.npmjs.org/$plat/-/${plat#@opencode-ai/}-$version.tgz"
hash=$(nix store prefetch-file --json "$url" |
  node -e 'let d="";process.stdin.on("data",c=>d+=c).on("end",()=>console.log(JSON.parse(d).hash))')

node -e 'require("fs").writeFileSync("./hashes.json", JSON.stringify({version:process.argv[1],hash:process.argv[2]},null,2)+"\n")' "$version" "$hash"
echo "hashes.json updated — now rebuild:"
echo "  sudo nixos-rebuild switch --flake ~/nixos-config#nixos-btw"
