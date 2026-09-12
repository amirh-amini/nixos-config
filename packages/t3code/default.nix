# Desktop packages unpack upstream AppImages; CLI packages install upstream npm
# bundles. packages/t3code/update.sh refreshes stable or nightly metadata.
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
        cp ${./package.json} package.json
        cp ${./package-lock.json} package-lock.json
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
    version = "0.0.40";
    hash = "sha256-i/X9RMt/rQxDGR1U/v35dKgifVBQXsuKvPdjJiCfJko=";
  };

  t3code-desktop-nightly = mkDesktop {
    pname = "t3code-desktop-nightly";
    binName = "t3code-nightly";
    displayName = "T3 Code Nightly";
    version = "0.0.41-nightly.20260912.1599";
    hash = "sha256-+UIR9dgOT3IJZnwAjcMrmUdT+B0C8C8Mibgs/JKhLUg=";
  };

  t3code-cli-stable = mkCli {
    pname = "t3code-cli-stable";
    binName = "t3";
    displayName = "T3 Code CLI";
    version = "0.0.40";
    srcHash = "sha256-UaJMLPWTPGlkzNXysroS0HHKViyAP85G7wo0/gd29Cc=";
    depsHash = "sha256-I4cfChlaSyf3SB9I6FvwI4/h/BJ3LbpVX4O54xsXawk=";
  };

  t3code-cli-nightly = mkCli {
    pname = "t3code-cli-nightly";
    binName = "t3-nightly";
    displayName = "T3 Code Nightly CLI";
    version = "0.0.41-nightly.20260912.1599";
    srcHash = "sha256-xz79lcOJzJFjf3fD5sFat7jZq9CwjXQAUFO0pEIPy/U=";
    # Shares the stable vendored lockfile: the nightly's dependency graph
    # resolves against the same lock. Bump both together when a nightly's
    # runtime demands newer deps.
    depsHash = "sha256-I4cfChlaSyf3SB9I6FvwI4/h/BJ3LbpVX4O54xsXawk=";
  };
}
