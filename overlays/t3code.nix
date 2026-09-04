# t3code — T3 Code desktop app + server, stable and nightly channels.
#
# Mirrors upstream's own packaging choices:
#   desktop ← official release AppImage, extracted & wrapped (the same
#             recipe their AUR t3code-bin / t3code-nightly-bin follow)
#   cli     ← official npm bundle: prebuilt dist/, SLSA-provenance CI
#
# Channels follow upstream's tag convention:
#   stable  = latest non-prerelease tag   (e.g. v0.0.33)
#   nightly = latest v*-nightly.* tag     (several per day upstream)
#
# Update ritual: overlays/t3code/update.sh [stable|nightly], then rebuild.
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
      registerSchemeHandler ? false,
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
      depsHash,
    }:
    final.buildNpmPackage {
      inherit pname version;
      src = final.fetchurl {
        url = "https://registry.npmjs.org/t3/-/t3-${version}.tgz";
        hash = srcHash;
      };
      # dist/ ships prebuilt — npm only supplies the runtime dependency tree.
      dontNpmBuild = true;

      # Upstream's published package.json contains monorepo override
      # artifacts (keys like "pkg>pkg") that strict npm rejects, so we
      # vendor a cleaned manifest + generated lockfile. Regenerate both
      # when bumping a channel.
      postPatch = ''
        cp ${./t3code/package.json} package.json
        cp ${./t3code/package-lock.json} package-lock.json
      '';

      npmDepsHash = depsHash;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/${pname} $out/bin
        cp -r . $out/lib/${pname}/
        makeWrapper ${nodejs}/bin/node $out/bin/${binName} \
          --add-flags "$out/lib/${pname}/dist/bin.mjs"
        runHook postInstall
      '';

      meta = with final.lib; {
        description = "${displayName} — T3 Code server/CLI";
        license = licenses.mit;
        platforms = [ "x86_64-linux" ];
        mainProgram = binName;
      };
    };
in
{
  t3code-desktop-stable = mkDesktop {
    pname = "t3code-desktop-stable";
    binName = "t3code";
    displayName = "T3 Code";
    version = "0.0.38";
    hash = "sha256-HxzNkisu+v/VBEewKO4NbiUlUCkFCHz4rj/kHv6+NG8=";
    registerSchemeHandler = true;
  };

  t3code-desktop-nightly = mkDesktop {
    pname = "t3code-desktop-nightly";
    binName = "t3code-nightly";
    displayName = "T3 Code Nightly";
    version = "0.0.39-nightly.20260904.1276";
    hash = "sha256-D8fpMsepbJbsuivtZzaEvPPIc1tVb6VUSBECJQcMnAs=";
  };

  t3code-cli-stable = mkCli {
    pname = "t3code-cli-stable";
    binName = "t3";
    displayName = "T3 Code CLI";
    version = "0.0.38";
    srcHash = "sha256-YLpXJXb8wGQllH59P71ve0+KoNQw/hxcTCTLVW4HQY8=";
    depsHash = "sha256-OWlr0T16fghimqU881mdDbqIlEAvUEMcyXTt4MlBHlw=";
  };

  t3code-cli-nightly = mkCli {
    pname = "t3code-cli-nightly";
    binName = "t3-nightly";
    displayName = "T3 Code Nightly CLI";
    version = "0.0.39-nightly.20260904.1276";
    srcHash = "sha256-7WDxtvK8eyfqq3wzOZY6iwrP7Cg8VGa21MRbDJcFMXk=";
    # Shares the stable vendored lockfile: the nightly's dependency graph
    # resolves against the same lock. Bump both together when a nightly's
    # runtime demands newer deps.
    depsHash = "sha256-OWlr0T16fghimqU881mdDbqIlEAvUEMcyXTt4MlBHlw=";
  };
}
