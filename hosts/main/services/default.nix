{
  imports = [
    ./memos.nix
  ];

  # Kept available for occasional printers; no separate module is needed.
  services.printing.enable = true;
}
