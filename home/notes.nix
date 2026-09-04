{
  pkgs,
  ...
}:

{
  # Note-taking applications without dedicated configuration here.
  home.packages = with pkgs; [
    obsidian
    heynote
    logseq
  ];
}
