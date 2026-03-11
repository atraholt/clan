{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
    inputs.home-manager.nixosModules.home-manager
  ];
  boot = {
    initrd.systemd.enable = true;
    kernelPackages = pkgs.pkgs.linuxPackages_latest;
    loader = {
      timeout = 1;
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
    sudo.enable = false;
    sudo-rs = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = false;
    };
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
  systemd.services.nix-daemon = {
    environment.TMPDIR = "/var/tmp";
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
}
