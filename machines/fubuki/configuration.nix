{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  steam-offload = lib.hiPrio (
    pkgs.runCommand "steam-override" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      mkdir -p $out/bin
      makeWrapper ${config.programs.steam.package}/bin/steam $out/bin/steam \
        --set __NV_PRIME_RENDER_OFFLOAD 1 \
        --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
        --set __GLX_VENDOR_LIBRARY_NAME nvidia \
        --set __VK_LAYER_NV_optimus NVIDIA_only
    ''
  );
  nixpkgs-unoptimized = import inputs.nixpkgs {
    system = "x86_64-linux";
    config = config.nixpkgs.config;
  };
  nixpkgs-unoptimized-i686 = import inputs.nixpkgs {
    system = "i686-linux";
  };
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];
  boot = {
    kernelModules = [ "ntsync" ];
    blacklistedKernelModules = [ "uvcvideo" ];
    kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
    kernelParams = [
      "nvidia.NVreg_TemporaryFilePath=/var/tmp"
      "mitigations=off"
    ];
    extraModprobeConfig = ''
      		options nvidia NVreg_UsePageAttributeTable=1 \
      			NVreg_InitializeSystemMemoryAllocations=0 \
      			NVreg_DynamicPowerManagement=0x02
      	'';
    kernel.sysctl = {
      "vm.swappiness" = 100;
      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_bytes" = 268435456;
      "vm.page-cluster" = 1;
      "vm.dirty_background_bytes" = 67108864;
      "vm.dirty_writeback_centisecs" = 1500;
      "kernel.nmi_watchdog" = 0;
      "kernel.unprivileged_userns_clone" = 1;
      "kernel.printk" = "3 3 3 3";
      "kernel.kptr_restrict" = 2;
      "kernel.kexec_load_disabled" = 1;
      "net.core.netdev_max_backlog" = 4096;
      "fs.file-max" = 2097152;
    };
  };
  nix = {
    settings = {
      max-jobs = lib.mkForce 2;
      cores = lib.mkForce 2;
      always-allow-substitutes = lib.mkForce false;
      builders-use-substitutes = lib.mkForce false;
      substitute = lib.mkForce true;
      max-substitution-jobs = lib.mkForce 2;
      system-features = [
        "gccarch-x86-64-v3"
      ];
    };
  };
  services = {
    power-profiles-daemon.enable = lib.mkForce false;
    tlp = {
      enable = true;
      pd.enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 90;
      };
    };
    udev.extraRules = ''
      # Allow all users to access ntsync.
      KERNEL=="ntsync", MODE="0644"
    '';
    xserver.videoDrivers = [
      "modesetting"
      "nvidia"
    ];
    btrfs.autoScrub.enable = true;
    irqbalance.enable = true;
  };
  nixpkgs = {
    config.allowUnfree = true;
    config.nvidia.acceptLicense = true;
    hostPlatform = {
      gcc.arch = "x86-64-v3";
      #gcc.tune = "skylake";
      system = "x86_64-linux";
    };
    overlays =
      let
        useUnoptimized-x64 =
          super: pkgs:
          lib.lists.foldr (
            a: b:
            (lib.attrsets.setAttrByPath [ a ] (lib.attrsets.getAttrFromPath [ a ] nixpkgs-unoptimized.pkgs))
            // b
          ) { } pkgs;
        useUnoptimized-i686 =
          super: pkgs:
          lib.lists.foldr (
            a: b:
            (lib.attrsets.setAttrByPath [ a ] (
              lib.attrsets.getAttrFromPath [ a ] nixpkgs-unoptimized-i686.pkgs
            ))
            // b
          ) { } pkgs;
        useUnoptimized =
          super: pkgs:
          if (super.stdenv.system == "x86_64-linux") then
            (useUnoptimized-x64 super pkgs)
          else
            (useUnoptimized-i686 super pkgs);

      in
      [
        (
          final: super:
          (useUnoptimized super [
            # These are here because they can be very slow to build
            "nodejs"
            "nodejs-slim"
            "electron"
            # Some of these don't exist yet, but will help prevent issues when they do
            #"electron_29"
            #"electron_30"
            #"electron_31"
            #"electron_32"
            #"electron_33"
            #"electron_34"
            #"electron_35"
            #"electron_36"
            #"electron_37"
            #"electron_38"
            #"electron_39"
            "electron-unwrapped"
            #"firefox"
            #"firefox-bin"
            "webkitgtk"
            #"webkitgtk_4_1"
            #"webkitgtk_5_0"
            #"webkitgtk_6_0"
            "llvm"
            "qtwebengine"
            "pyside6"
            "rustc"
            "rustc-wrapper"
            #"clang"
            "ghc"
            #"ryubing"
            # Test failure (checkasm) - 02/05/2025
            #"dav1d"
            # Fails to build due to expecting BPF support that is apparently not available in clang?? - 02/05/2025
            #"systemd"
            # # Fails to build due to aggressive size checks - 02/05/2025
            #"libtpms"
            # Fails a test for unknown reason - 02/05/2025
            #"lib2geom"
            # Fails to compile due to format overflow - 02/05/2025
            #"efivar"
            # Fails a test - 02/04/2025
            #"graphene"
            # Fails to find some managed application when building dotnet - 02/04/2025
            #"ryujinx"
            # Fails to build a dependency, openexr, that is customized so an override doesn't use the cache - 02/04/2025
            #"gst_all_1"
            # Causes a nix parsing stack overflow when using an override for some reason - 5/22/2025
            #"easyeffects"
            # TLS dependency fails to build - 5/22/2025
            #"pandoc"
            # Test failures - 7/8/2025
            "assimp"
            # Build failures - 7/31/2025
            #"v4l-utils"
            # Infinite recursion in call depth for nix configs - 8/12/2025
            #"php"
            # Takes forever to build
            #"ollama"
            # Dependencies have some issues - 10/23/2025
            #"lutris"
            # Fails tests - 11/20/2025
            #"ffmpeg-headless"
            #"ffmpeg"
            # Fails tests 04/01/2026
            # "python3.13-uvloop"
            # Fails build 04/01/2026
            #"xivlauncher"
            # Test fail 16/02/2026
            #"sdl3"
            # Build fail 16/02/2026
            "mesa"
            # Build fail 09/03/2026
            "nix"
          ])
        )
        inputs.nix-cachyos-kernel.overlay
      ];
  };
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-compute-runtime
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        libva-vdpau-driver
        libvdpau-va-gl
        nvidia-vaapi-driver
      ];
    };
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      powerManagement.enable = true;
      powerManagement.finegrained = true;
      open = lib.mkForce true;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = lib.mkDefault "PCI:0:2:0";
        nvidiaBusId = lib.mkDefault "PCI:1:0:0";
      };
      modesetting.enable = true;
      nvidiaPersistenced = true;
      nvidiaSettings = false;
    };
    openrazer = {
      enable = true;
      users = [ "audun" ];
    };
  };
  environment.systemPackages = (lib.optionals config.programs.steam.enable [ steam-offload ]) ++ [
    pkgs.nvtopPackages.full
    pkgs.clinfo
    pkgs.libva-utils
    pkgs.vdpauinfo
    pkgs.openrazer-daemon
    pkgs.polychromatic
  ];
  networking.networkmanager.wifi.backend = "iwd";
}
