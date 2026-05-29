{
  description = "Python dev shell (uv)";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems =
        f: nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: f system);
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.uv
              pkgs.python3
            ];
            shellHook = ''
              echo "🐍 uv $(uv --version)  —  uv venv && uv add <pkg>  (installs are sandboxed)"
            '';
          };
        }
      );
    };
}