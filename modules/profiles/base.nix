{
  lib,
  pkgs,
  config,
  ...
}:
let
  machineName = config.clan.core.machineName;
  machineTags = config.clan.core.inventory.machines.${machineName}.tags or [ ];

  myLib = {
    hasTag = tag: builtins.elem tag machineTags;
    hasAnyTag = candidateTags: lib.any (tag: builtins.elem tag machineTags) candidateTags;
    hasAllTags = targetTags: lib.all (tag: builtins.elem tag machineTags) targetTags;
  };
in
{
  # Global settings for any system
  _module.args = {
    inherit myLib;
  };
  imports = [
    ../home-manager.nix
  ];
  nixpkgs = {
    config.allowUnfree = true;
  };
  nix = {
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    optimise.automatic = true;
    gc = {
      automatic = true;
    }
    // (lib.optionalAttrs pkgs.stdenv.isLinux {
      dates = "weekly";
      randomizedDelaySec = "1800";
    });
    settings = {
      max-jobs = 1;
      cores = 1;
      download-buffer-size = 500000000; # 500 MB
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
      builders-use-substitutes = lib.mkDefault true;
      always-allow-substitutes = lib.mkDefault false;
      substitute = lib.mkDefault true;
      max-substitution-jobs = lib.mkDefault 2;
      show-trace = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # nix things
    dix # diffs
    nix-output-monitor # pretty builds
    # terminal tools
    bat
    ripgrep-all
    witr
  ];

  users.users.audun = {
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBC7JOKqvy7mI8KfMfrOVUgpBrMvnpMeQd9QmgPI9P2eyhbqikYe0zkP98Lvc6MIDk1oH3JVrdS51PGQ99Ts0DxI= homelab@secretive.kubira.local"
    ];
  };
}
