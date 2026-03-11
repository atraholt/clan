{
  self,
  config,
  pkgs,
  ...
}:
let
  mangohudForCurrentKernel = pkgs.mangohud.override {
    inherit (config.boot.kernelPackages.nvidia_x11.settings) libXNVCtrl;
  };
in
{
  imports = [

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
      useGameMode = true;
      nvngxPath = "${config.hardware.nvidia.package}/lib/nvidia/wine";
    })
  ];
  hardware.graphics = {
    extraPackages = [ pkgs.mangohud ];
    extraPackages32 = [ pkgs.mangohud ];
  };
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
    package = pkgs.sunshine.override { cudaSupport = true; };
    applications = {
      apps = [
        {
          name = "1080p Desktop";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
        }
      ];
    };
  };
}
