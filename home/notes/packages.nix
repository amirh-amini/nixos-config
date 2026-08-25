{
  pkgs,
  ...
}:

{
  # PKM apps without their own module — config-less.
  # Logseq rides electron 39 (EOL, flagged insecure by nixpkgs); whitelisted
  # in system/base.nix because upstream ships the same runtime.
  home.packages = with pkgs; [
    logseq
  ];
}
