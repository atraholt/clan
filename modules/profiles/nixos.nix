{
  self,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
    inputs.home-manager.nixosModules.home-manager
    inputs.catppuccin.nixosModules.catppuccin
    inputs.srvos.nixosModules.common
    #inputs.srvos.nixosModules.mixins-nix-experimental
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.srvos.nixosModules.mixins-systemd-boot
    #inputs.srvos.nixosModules.mixins-telegraf
  ];
  srvos.flake = self;
  boot = {
    initrd.systemd.enable = true;
    kernelPackages = pkgs.pkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "0";
        configurationLimit = 5;
        memtest86.enable = true;
        netbootxyz.enable = true;
      };
    };
    tmp.useTmpfs = true;
    kernelParams = [
      # Enable zswap
      "zswap.enabled=1"
    ];
    kernelModules = [
      "lz4"
      "lz4_compress"
    ];
    extraModprobeConfig = ''
      options zswap enabled=1 compressor=lz4 zpool=z3fold
    '';
  };
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = pkgs.stdenv.isx86_64;
    cpu.intel.updateMicrocode = pkgs.stdenv.isx86_64;
  };
  security = {
    pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "nofile";
        value = "65536";
      }
      {
        domain = "*";
        type = "hard";
        item = "nofile";
        value = "1048576";
      }
    ];
  };

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.supportedLocales = [ "all" ];
  console = {
    keyMap = "no";
  };
  systemd.services = {
    "serial-getty@ttyS0".enable = lib.mkForce false;
    nix-daemon = {
      environment.TMPDIR = "/var/tmp";
    };
  };

  services = {
    timesyncd.enable = false;
    resolved = {
      enable = true;
      #settings = {
      #  MulticastDNS = false;
      #};
    };
    dbus.implementation = "broker";
    dbus.enable = true;
    userborn.enable = true;
    chrony = {
      enable = true;
      servers = [
        "time.cloudflare.com"
      ];
    };
    logind.settings.Login.killUserProcesses = true;
  };
  zramSwap = {
    enable = true;
    algorithm = "zstd lz4 (type=huge)";
    memoryPercent = 100;
    priority = 100;
  };
  catppuccin = {
    enable = true;
    flavor = "mocha";
    sddm.enable = true;
  };
  fonts = {
    packages = with pkgs; [
      udev-gothic-nf
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [
          "UDEV Gothic NF"
          "Hack"
          "Noto Sans Mono"
        ];
      };
    };
  };
}
