{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.nix-index-database.darwinModules.nix-index
    inputs.home-manager.darwinModules.home-manager
    ../nix-casks.nix
  ];
  environment.systemPackages = with pkgs; [
    android-tools
    appcleaner
    moonlight-qt
    rectangle
    the-unarchiver
    alt-tab
  ];
  fonts.packages = [
    "font-sauce-code-pro-nerd-font"
    "font-udev-gothic-nf"
    pkgs.nerd-fonts.fira-code
  ];
}
