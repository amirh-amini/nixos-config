# Packages the upstream OpenCode 2 Linux binary from the npm beta channel.
# packages/opencode2/update.sh refreshes its version and hashes.
final: _: {
  opencode2 =
    let
      inherit (final.lib.importJSON ./hashes.json) version hash url;
    in
    final.stdenvNoCC.mkDerivation {
      pname = "opencode2";
      inherit version;

      # npm tarball layout: package/bin/opencode2 — a self-contained bun
      # binary; runs unpatched on NixOS. update.sh owns the tarball url —
      # the npm scope has moved before (@opencode-ai/* -> @opencode/*).
      src = final.fetchurl {
        inherit url hash;
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
