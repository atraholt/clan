{
  lib,
  pkgs,
  ...
}:
{
  # Global settings for any system
  imports = [
    ../home-manager.nix
  ];
  nix = {
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    optimise.automatic = true;
    gc = lib.mkMerge [
      {
        automatic = true;
      }
      (
        if pkgs.stdenv.isDarwin then
          {
            interval = [
              {
                Weekday = 1;
                Hour = 1;
              }
            ];
          }
        else
          { }
      )
      (lib.mkIf pkgs.stdenv.isLinux { dates = "weekly"; })
      (lib.mkIf pkgs.stdenv.isLinux { randomizedDelaySec = "1800"; })
    ];
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
  users.defaultUserShell = pkgs.zsh;
}
