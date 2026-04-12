{
  lib,
  pkgs,
  inputs,
  myLib,
  ...
}:

{
  home-manager.users.audun = {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
      ../../modules/btop.nix
      #../../modules/nushell.nix
    ]
    ++
      lib.optional
        (myLib.hasAllTags [
          "gui"
          "nixos"
        ])
        [
          ../../modules/mangohud.nix
          ../../modules/plasma.nix
        ]
    ++
      lib.optional
        (myLib.hasAnyTag [
          "gui"
          "darwin"
        ])
        [
          ../../modules/ghostty.nix
          ../../modules/vesktop.nix
          ../../modules/vivaldi.nix
          ../../modules/vscode.nix
        ];
    catppuccin = {
      enable = true;
      flavor = "mocha";
      bat.enable = true;
      eza.enable = true;
      zellij.enable = true;
      mangohud.enable = false;
      sway.enable = false;
    };
    wayland.windowManager.labwc = {
      enable = true;
      xwayland.enable = true;
    };
    home.packages = with pkgs; [
      labwc # The floating compositor
      foot # Terminal
      dmenu-wayland # App launcher
      swaylock
      swayidle
      waybar # Taskbar/Clock
    ];
    home.shell.enableShellIntegration = true;
    home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/audun" else "/home/audun";
    home.stateVersion = "26.05";
  };
  users.users.audun = {
    shell = pkgs.fish;
  };
}
