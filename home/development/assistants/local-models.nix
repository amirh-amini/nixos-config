{ pkgs, ... }:

{
  home.packages = [ pkgs.lmstudio ];

  # TODO: Choose CPU, CUDA, or Vulkan acceleration after testing local models.
  services.ollama.enable = true;
}
