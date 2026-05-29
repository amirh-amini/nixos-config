{ pkgs, lib, ... }:
let
  # Bubblewrap-based sandbox runner shared by `safe-install` and `sbx`.
  #
  #  - empty tmpfs HOME  => ~/.ssh, ~/.aws, tokens, agent sockets are invisible
  #                         to whatever runs inside (a malicious post-install
  #                         script finds no secrets to steal).
  #  - only the current working directory is writable; /nix is read-only.
  #  - /run is NOT mounted, so the gpg/ssh agent sockets under /run/user are
  #    unreachable from inside.
  #  - persistent uv/pip caches are bound back in so installs stay fast.
  #  - network is ON by default (installs must fetch). SC_NONET=1 cuts it
  #    entirely (used by `sbx`, for running code you don't trust yet).
  sandboxScript = ''
    if [ "$#" -eq 0 ]; then
      echo "usage: $(basename "$0") <command> [args...]" >&2
      exit 2
    fi

    netargs=()
    if [ "''${SC_NONET:-0}" = "1" ]; then
      netargs=(--unshare-net)
    fi

    cache_base="''${XDG_CACHE_HOME:-$HOME/.cache}"
    mkdir -p "$cache_base/uv" "$cache_base/pip"

    exec bwrap \
      --ro-bind /nix /nix \
      --ro-bind /etc /etc \
      --ro-bind-try /bin /bin \
      --ro-bind-try /lib64 /lib64 \
      --ro-bind-try /lib /lib \
      --ro-bind-try /run/current-system /run/current-system \
      --proc /proc \
      --dev /dev \
      --tmpfs /tmp \
      --tmpfs /home \
      --dir "$HOME" \
      --dir "$HOME/.cache" \
      --bind "$cache_base/uv" "$HOME/.cache/uv" \
      --bind "$cache_base/pip" "$HOME/.cache/pip" \
      --bind "$PWD" "$PWD" \
      --chdir "$PWD" \
      --setenv HOME "$HOME" \
      --unsetenv SSH_AUTH_SOCK \
      --unshare-user-try \
      --unshare-ipc \
      --unshare-pid \
      --unshare-uts \
      --die-with-parent \
      "''${netargs[@]}" \
      "$@"
  '';

  safe-install = pkgs.writeShellApplication {
    name = "safe-install";
    runtimeInputs = [ pkgs.bubblewrap pkgs.coreutils ];
    text = sandboxScript;
  };

  sbx = pkgs.writeShellApplication {
    name = "sbx";
    runtimeInputs = [ safe-install ];
    text = ''
      export SC_NONET=1
      exec safe-install "$@"
    '';
  };
in
{
  home.packages = [ safe-install sbx ];

  # Auto-route Python install commands through the sandbox so a malicious
  # build/post-install script runs with no access to your secrets.
  #   - disable for the current shell: export SC_SANDBOX_INSTALLS=0
  #   - bypass once:                    command uv add <pkg>
  programs.zsh.initContent = lib.mkAfter ''
    : "''${SC_SANDBOX_INSTALLS:=1}"

    uv() {
      if [[ "$SC_SANDBOX_INSTALLS" == "1" ]]; then
        case "''${1:-}" in
          add|sync|lock|pip) safe-install uv "$@"; return $? ;;
        esac
      fi
      command uv "$@"
    }

    uvx() {
      if [[ "$SC_SANDBOX_INSTALLS" == "1" ]]; then
        safe-install uvx "$@"; return $?
      fi
      command uvx "$@"
    }

    pipx() {
      if [[ "$SC_SANDBOX_INSTALLS" == "1" && "''${1:-}" == "install" ]]; then
        safe-install pipx "$@"; return $?
      fi
      command pipx "$@"
    }
  '';
}