{
  pkgs,
  ...
}:
{
  imports = [
  ];
  home-manager = {
    verbose = true;
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension =
      "backup-"
      + pkgs.lib.readFile "${pkgs.runCommand "timestamp" { } "echo -n `date '+%Y%m%d%H%M%S'` > $out"}";

    sharedModules = [
      {
        programs.home-manager.enable = true;
      }
    ];
  };
}
