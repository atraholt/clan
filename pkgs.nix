{ ... }:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages = {
        xivlauncher-rb = pkgs.callPackage ./pkgs/xivlauncher-rb { };
      };
    };
}
