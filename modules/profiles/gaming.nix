{
  self,
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  isNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
in
{
  imports = [
    inputs.nix-gaming.nixosModules.platformOptimizations
    inputs.nix-gaming.nixosModules.pipewireLowLatency
    inputs.nix-gaming.nixosModules.wine
  ];
  programs = {
    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraEnv = {
          MANGOHUD = true;
          # OBS_VKCAPTURE = true;
          PROTON_ENABLE_WAYLAND = 1;
          PROTON_USE_NTSYNC = 1;
        };
        extraArgs = "-console";
      };
      extest.enable = false;
      gamescopeSession.enable = false;
      protontricks.enable = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      platformOptimizations.enable = true;
    };
    gamescope = {
      enable = true;
      capSysNice = false;
    };
    gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          desiredgov = "performance";
          desiredprof = "performance";
          renice = 15;
        };
        # Warning: GPU optimisations have the potential to damage hardware
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
        };

        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };
    wine = {
      enable = true;
      package = inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.wine-tkg;
      binfmt = true;
      ntsync = true;
    };
    # xivlauncher-rb.enable = true;
  };
  environment.systemPackages = with pkgs; [
    #xivlauncher
    #mangohudForCurrentKernel
    mangohud
    nero-umu
    umu-launcher
    faugus-launcher
    (self.packages.${pkgs.stdenv.hostPlatform.system}.xivlauncher-rb.override {
      useGameMode = false;
      #useSteamRun = false;
      nvngxPath = if isNvidia then "${config.hardware.nvidia.package}/lib/nvidia/wine" else "";
    })
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.wineprefix-preparer
  ];
  hardware = {
    graphics = {
      extraPackages = [ pkgs.mangohud ];
      extraPackages32 = [ pkgs.mangohud ];
    };
    steam-hardware.enable = true;
  };
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      lowLatency.enable = true;
    };
    udev.packages = [ pkgs.game-devices-udev-rules ];
  };
}
