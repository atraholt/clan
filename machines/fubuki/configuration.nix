{
  self,
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
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    "${self}/modules/unoptimized.nix"
    "${self}/modules/sunshine.nix"
  ];
  boot = {
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
        # "gccarch-x86-64-v3"
        "gccarch-skylake"
        "gcctune-skylake"
      ];
    };
  };
  services = {
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
    config.cudaSupport = true;
    hostPlatform = {
      #gcc.arch = "x86-64-v3";
      gcc.tune = "skylake";
      gcc.arch = "skylake";
      system = "x86_64-linux";
    };
    overlays = [
      inputs.nix-cachyos-kernel.overlay
    ];
  };
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        # intel-compute-runtime
        # intel-ocl
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        # libva-vdpau-driver
        libvdpau-va-gl
        nvidia-vaapi-driver
      ];
    };
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;
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
  powerManagement.cpuFreqGovernor = lib.mkForce "powersave"; # RZ09-036/CH560 suicides in performance governor
  environment = {
    systemPackages = (lib.optionals config.programs.steam.enable [ steam-offload ]) ++ [
      pkgs.nvtopPackages.full
      pkgs.clinfo
      pkgs.libva-utils
      pkgs.vdpauinfo
      pkgs.openrazer-daemon
      pkgs.polychromatic
    ];
  };
  networking.networkmanager.wifi.backend = "iwd";
}
