# Desktop packages unpack upstream AppImages; CLI packages lay out the npm
# launcher tarball plus the self-contained linux-x64 platform bundle — no
# npm dependency resolution needed (the bundle ships its own node_modules).
# packages/t3code/update.sh refreshes stable or nightly metadata.
final: prev:
let
  nodejs = prev.nodejs_24; # satisfies engines: ^22.16 || ^23.11 || >=24.10

  mkDesktop =
    {
      pname,
      binName,
      displayName,
      version,
      hash,
    }:
    let
      src = final.fetchurl {
        url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
        inherit hash;
      };
      # wrapType2 = extract + FHS environment carrying the Electron dependency
      # set (gtk3, nss, nspr, alsa, …) — the libs the raw payload links against.
      fhs = final.appimageTools.wrapType2 { inherit pname version src; };
      contents = final.appimageTools.extract { inherit pname version src; };
    in
    final.runCommand pname
      {
        inherit version;
        nativeBuildInputs = [ final.makeWrapper ];
        meta = with final.lib; {
          description = "${displayName} — agent harness control surface";
          license = licenses.mit;
          platforms = [ "x86_64-linux" ];
          mainProgram = binName;
        };
      }
      ''
                mkdir -p $out/bin $out/share/applications \
                  $out/share/icons/hicolor/512x512/apps

                makeWrapper ${fhs}/bin/${pname} $out/bin/${binName} \
                  --set-default ELECTRON_OZONE_PLATFORM_HINT auto

                for icon in ${contents}/usr/share/icons/hicolor/*/apps/t3code.png; do
                  size=$(basename "$(dirname "$(dirname "$icon")")")
                  install -Dm644 "$icon" \
                    "$out/share/icons/hicolor/$size/apps/${binName}.png"
                done

                cat > $out/share/applications/${pname}.desktop <<EOF
        [Desktop Entry]
        Type=Application
        Name=${displayName}
        Comment=Agent harness control surface for local coding agents
        Exec=${binName} %U
        TryExec=${binName}
        Terminal=false
        Icon=${binName}
        StartupWMClass=t3code
        Categories=Development;
        EOF
      '';

  mkCli =
    {
      pname,
      binName,
      displayName,
      version,
      srcHash,
      bundleHash,
    }:
    let
      # The npm tarball is a thin launcher (bin/t3.js, dist/bin.mjs) that
      # require.resolve()s the platform bundle and spawns its prebuilt
      # executable. npm cannot install the bundle deterministically (its
      # bundled deps pin libc variants that npm's platform check rejects),
      # so both pieces are laid out by hand instead of via npm.
      src = final.fetchurl {
        url = "https://registry.npmjs.org/t3/-/t3-${version}.tgz";
        hash = srcHash;
      };
      bundle = final.fetchurl {
        url = "https://registry.npmjs.org/@t3code/t3-linux-x64/-/t3-linux-x64-${version}.tgz";
        hash = bundleHash;
      };
    in
    final.stdenv.mkDerivation {
      inherit pname version;
      dontUnpack = true;
      # Upstream ships prebuilt, patched binaries (the `t3` executable is a
      # bun-style single-file build; the bundle also embeds prebuilt native
      # modules). Nix's fixupPhase corrupts them — shrink-rpath's patchelf
      # rewrite breaks the executable (SIGILL) — so leave them byte-identical
      # to the tarball.
      dontPatchELF = true;
      dontStrip = true;
      nativeBuildInputs = [ final.makeWrapper ];
      # node is on PATH so patchShebangs can rewrite the launcher's shebang;
      # the wrapper embeds it as the runtime interpreter either way.
      buildInputs = [ nodejs ];
      meta = with final.lib; {
        description = "${displayName} — T3 Code server/CLI";
        license = licenses.mit;
        platforms = [ "x86_64-linux" ];
        mainProgram = binName;
      };
      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/${pname}/node_modules/@t3code/t3-linux-x64 \
          $out/bin
        tar xzf ${src} -C $out/lib/${pname} --strip-components=1
        tar xzf ${bundle} \
          -C $out/lib/${pname}/node_modules/@t3code/t3-linux-x64 \
          --strip-components=1
        makeWrapper ${nodejs}/bin/node $out/bin/${binName} \
          --add-flags "$out/lib/${pname}/dist/bin.mjs"
        runHook postInstall
      '';
    };
in
{
  t3code-desktop-stable = mkDesktop {
    pname = "t3code-desktop-stable";
    binName = "t3code";
    displayName = "T3 Code";
    version = "0.1.0";
    hash = "sha256-442cX7UTsezgpwi5BtM4O1tH7RmVdbOaMeQauINOt0Q=";
  };

  t3code-desktop-nightly = mkDesktop {
    pname = "t3code-desktop-nightly";
    binName = "t3code-nightly";
    displayName = "T3 Code Nightly";
    version = "0.1.1-nightly.20261016.3190";
    hash = "sha256-fY19awbx0Tm2h+vFpehnGt0PeKHcUl8BH3rntZImafg=";
  };

  t3code-cli-stable = mkCli {
    pname = "t3code-cli-stable";
    binName = "t3";
    displayName = "T3 Code CLI";
    version = "0.1.0";
    srcHash = "sha256-8L++UeGJz4drr5dSu0FklfSHsU74V9IY0s3gFNDRKUE=";
    bundleHash = "sha256-IcRU3DOoOiwOnrpak3L7W4Ao2VhGM5Wi1RVpwTEfCXE=";
  };

  t3code-cli-nightly = mkCli {
    pname = "t3code-cli-nightly";
    binName = "t3-nightly";
    displayName = "T3 Code Nightly CLI";
    version = "0.1.1-nightly.20261016.3190";
    srcHash = "sha256-ETDSYtdBtVmIeMz5U8845FFPft5ScyXw94dwnUYxR8I=";
    bundleHash = "sha256-7XuI0zgVk+kUMJlySYjPY+P7G5mqiIACFbogMB6/Veo=";
  };
}
