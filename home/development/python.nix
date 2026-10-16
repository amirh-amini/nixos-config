{ pkgs, ... }:
{
  # Project environments own their Python runtimes and libraries.
  # TODO: Add project templates for other language stacks when they are needed;
  # do not install language runtimes globally by default.
  home.packages = [ pkgs.uv ];
  # why just uv? why not noting at all, also why not other things like npm, etc.
  # and okay, for things like rust, js, ts, okay they should be for projects,
  # but i think python is something i use in terminal and for scripting somtimes
}
