{
  config,
  lib,
  inputs,
  ...
}:
let
  nixpkgs-unoptimized = import inputs.nixpkgs {
    system = "x86_64-linux";
    config = config.nixpkgs.config;
  };
  nixpkgs-without-cuda = import inputs.nixpkgs {
    system = "x86_64-linux";
    config = config.nixpkgs.config // {
      cudaSupport = false;
    };
  };
  nixpkgs-without-rocm = import inputs.nixpkgs {
    system = "x86_64-linux";
    config = config.nixpkgs.config // {
      rocmSupport = false;
    };
  };
  useUnoptimized-x64 =
    pkgList:
    lib.lists.foldr (
      name: acc:
      (lib.attrsets.setAttrByPath [ name ] (
        lib.attrsets.getAttrFromPath [ name ] nixpkgs-unoptimized.pkgs
      ))
      // acc
    ) { } pkgList;

  useUnoptimized-i686 =
    pkgList:
    lib.lists.foldr (
      name: acc:
      (lib.attrsets.setAttrByPath [ name ] (
        lib.attrsets.getAttrFromPath [ name ] nixpkgs-unoptimized.pkgs.pkgsi686linux
      ))
      // acc
    ) { } pkgList;
in
{
  nixpkgs.overlays = [
    (
      final: prev:
      if prev.stdenv.system == "x86_64-linux" then
        (useUnoptimized-x64 [
          # 20260403 - continues to fail optimised compilation after retesting
          "mesa"
          "assimp"
          "libtpms"
        ])
      else
        (useUnoptimized-i686 [ ])
    )
  ];
}
