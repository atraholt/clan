{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      nixGamingPkgs = inputs.nix-gaming.packages.${system};
    in
    {
      packages = {
        xivlauncher-rb = pkgs.callPackage ./pkgs/xivlauncher-rb {
          inherit (nixGamingPkgs) wine-tkg dxvk-w64;
        };
      };
    };
}
