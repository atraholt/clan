{
  pkgs,
  inputs,
  ...
}:
{
  home-manager.users.audun = {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
      ../../modules/btop.nix
      ../../modules/ghostty.nix
      ../../modules/mangohud.nix
      #../../modules/nushell.nix
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
    };
    home.shell.enableShellIntegration = true;
    home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/audun" else "/home/audun";
    home.stateVersion = "26.05";
  };
  users.users.audun = {
    shell = pkgs.fish;
  };
}
