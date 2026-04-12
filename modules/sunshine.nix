{
  lib,
  config,
  pkgs,
  ...
}:
let
  isNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
  isIntelOld = lib.elem [ "intel-vaapi-driver" ] config.hardware.graphics.extraPackages;
  isIntelNew = lib.elem [ "intel-media-driver" ] config.hardware.graphics.extraPackages;
  isAMD = config.hardware.amdgpu.initrd.enable;
  sunshineCuda = pkgs.sunshine.override { cudaSupport = true; };
  sunshinePackage = if isNvidia then sunshineCuda else pkgs.sunshine;
in
{
  services.sunshine = {
    package = sunshinePackage;
    enable = true;
    autoStart = true;
    openFirewall = true;
    capSysAdmin = true;
    applications = {
      apps = [
        {
          name = "Desktop";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
        }
      ];
    };
    settings = {
      origin_web_ui_allowed = "lan";
      upnp = "off";
      fps = lib.mkDefault "[30, 60]";
      resolutions = lib.mkDefault ''[1920x1080]'';
      min_threads = lib.mkDefault 2;
      hevc_mode = lib.mkDefault 0;
      av1_mode = lib.mkDefault 0;
      audio_sink = lib.mkDefault "auto";
      key_repeat_delay = lib.mkDefault 500;
      key_repeat_frequency = lib.mkDefault 25;
    };
  };
  environment = {
    systemPackages = [ sunshinePackage ];
    sessionVariables = lib.mkMerge [
      (lib.mkIf isNvidia {
        LIBVA_DRIVER_NAME = "nvidia";
      })
      (lib.mkIf isIntelOld {
        LIBVA_DRIVER_NAME = "i965";
      })
      (lib.mkIf isIntelNew {
        LIBVA_DRIVER_NAME = "iHD";
      })
      (lib.mkIf isAMD {
        LIBVA_DRIVER_NAME = "radeonsi";
      })
    ];
  };
}
