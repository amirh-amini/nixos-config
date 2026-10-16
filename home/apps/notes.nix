{
  pkgs,
  ...
}:
{
  # TODO: Decide whether any stable Obsidian or Logseq preferences are worth
  # declaring; their mutable workspace and plugin state should remain app-owned.
  # Note-taking applications without dedicated configuration here.
  home.packages = with pkgs; [
    obsidian
    heynote
    logseq
  ];
}
