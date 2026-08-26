# opencode2 — OpenCode 2, beta channel, self-packaged.
#
# Upstream's repo-level nix/ dir only covers v1: it builds packages/opencode
# from the monorepo with bun + per-platform node_modules FODs that their CI
# generates (nix/scripts/canonicalize-node-modules.ts). OpenCode 2 has no nix
# packaging at all — during the beta it ships exclusively through npm as
# @opencode-ai/cli, whose postinstall merely selects a prebuilt platform
# binary from an @opencode-ai/cli-<platform> optional dependency (same shape
# as esbuild/bun). So instead of porting the monorepo build, we mirror what
# upstream actually distributes — same approach as our t3code packaging:
#
#   opencode2 = prebuilt bun binary from @opencode-ai/cli-linux-x64
#
# Channel is pinned by ./update.sh to npm dist-tag `beta` (the official
# OpenCode 2 install channel per opencode.ai/v2/docs — NOT `dev`).
#
# Update ritual:
#   overlays/opencode2/update.sh   # pin latest beta + refresh hashes.json
#   sudo nixos-rebuild switch --flake ~/nixos-config#nixos-btw
final: prev:
{
  opencode2 =
    let
      inherit (final.lib.importJSON ./hashes.json) version hash;
    in
    final.stdenvNoCC.mkDerivation {
      pname = "opencode2";
      inherit version;

      # npm tarball layout: package/bin/opencode2 — a self-contained bun
      # binary; runs unpatched on NixOS.
      src = final.fetchurl {
        url = "https://registry.npmjs.org/@opencode-ai/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
        inherit hash;
      };

      nativeBuildInputs = [ final.makeBinaryWrapper ];

      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall

        install -Dm755 bin/opencode2 $out/bin/opencode2
        wrapProgram $out/bin/opencode2 \
          --prefix PATH : ${final.lib.makeBinPath [ final.ripgrep ]}

        runHook postInstall
      '';

      meta = with final.lib; {
        description = "OpenCode 2 (beta) — the open source coding agent, next generation";
        homepage = "https://opencode.ai/v2/docs/";
        license = licenses.mit;
        mainProgram = "opencode2";
        platforms = [ "x86_64-linux" ];
        sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      };
    };
}
