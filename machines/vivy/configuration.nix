{
  self,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    "${self}/modules/unoptimized.nix"
    "${self}/modules/sunshine.nix"
  ];
  boot = {
    kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;
    kernelParams = [
      "mitigations=off"
      "video=HDMI-A-1:1920x1080@60e"
    ];
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
  networking.networkmanager.wifi.backend = "iwd";
  services = {
    xserver.videoDrivers = [
      "amdgpu"
    ];
    btrfs.autoScrub.enable = true;
    irqbalance.enable = true;
    displayManager.enable = true;
    greetd = {
      enable = true;
      settings = {
        initial_session = {
          command = "${pkgs.labwc}/bin/labwc";
          user = "audun";
        };
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd labwc";
          user = "greeter";
        };
      };
    };
  };
  nix = {
    settings = {
      max-jobs = lib.mkForce 4;
      cores = lib.mkForce 4;
      always-allow-substitutes = lib.mkForce false;
      builders-use-substitutes = lib.mkForce false;
      substitute = lib.mkForce true;
      max-substitution-jobs = lib.mkForce 2;
      system-features = [
        "gccarch-znver4"
        "gcctune-znver4"
      ];
    };
  };
  nixpkgs = {
    config.rocmSupport = true;
    hostPlatform = {
      gcc.tune = "znver4";
      gcc.arch = "znver4";
      system = "x86_64-linux";
    };
    overlays = [
      inputs.nix-cachyos-kernel.overlay
    ];
  };
  powerManagement.cpuFreqGovernor = lib.mkForce "performance";
  programs = {
    wshowkeys.enable = true;
    xwayland.enable = true;
    labwc.enable = true;
    sway = {
      enable = false;
      wrapperFeatures.gtk = true;
      wrapperFeatures.base = true;
      xwayland.enable = true;
      extraPackages = with pkgs; [
        waybar
        swaylock
        swayidle
        foot
        dmenu-wayland
        # xwayland
        # grim            # screenshot utility
        # slurp           # screen area selector
      ];
    };
  };
  security.rtkit.enable = true;
}
