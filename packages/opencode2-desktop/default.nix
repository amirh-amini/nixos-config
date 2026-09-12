# Desktop client for OpenCode 2, unpacked from upstream beta AppImages.
# packages/opencode2-desktop/update.sh refreshes version and hash.
final: _: {
  opencode2-desktop =
    let
      inherit (final.lib.importJSON ./hashes.json) version hash url;
      src = final.fetchurl { inherit url hash; };
      # wrapType2 = extract + FHS environment carrying the Electron dependency
      # set (gtk3, nss, nspr, alsa, …) — the libs the raw payload links against
      # and the AppImage only partially bundles.
      fhs = final.appimageTools.wrapType2 {
        inherit src version;
        pname = "opencode2-desktop";
      };
      contents = final.appimageTools.extract {
        inherit src version;
        pname = "opencode2-desktop";
      };
    in
    final.runCommand "opencode2-desktop"
      {
        inherit version;
        nativeBuildInputs = [ final.makeWrapper ];
        meta = with final.lib; {
          description = "OpenCode 2 desktop client (beta channel)";
          license = licenses.mit;
          platforms = [ "x86_64-linux" ];
          mainProgram = "opencode2-desktop";
        };
      }
      ''
        mkdir -p $out/bin $out/share/applications

        makeWrapper ${fhs}/bin/opencode2-desktop $out/bin/opencode2-desktop \
          --set-default ELECTRON_OZONE_PLATFORM_HINT auto \
          --add-flags --no-sandbox

        for icon in ${contents}/usr/share/icons/hicolor/*/apps/ai.opencode.desktop.beta.png; do
          size=$(basename "$(dirname "$(dirname "$icon")")")
          install -Dm644 "$icon" \
            "$out/share/icons/hicolor/$size/apps/opencode2-desktop.png"
        done

        cat > $out/share/applications/opencode2-desktop.desktop <<EOF
        [Desktop Entry]
        Type=Application
        Name=OpenCode Desktop (Beta)
        Comment=The open source coding agent — V2 desktop client
        Exec=opencode2-desktop %U
        TryExec=opencode2-desktop
        Terminal=false
        Icon=opencode2-desktop
        StartupWMClass=ai.opencode.desktop.beta
        MimeType=x-scheme-handler/opencode;
        Categories=Development;
        EOF
      '';
}
