{ pkgs, ... }:
{
  launchd.daemons.nix-daemon = {
    serviceConfig.Nice = -10;
  };
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.enable = true;
  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    maxJobs = 2;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    package = pkgs.darwin.linux-builder-x86_64;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 40 * 1024;
          memorySize = 8 * 1024;
        };
        cores = 2;
      };
      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    };
  };
}
