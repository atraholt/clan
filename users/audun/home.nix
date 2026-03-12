{
  pkgs,
  inputs,
  ...
}:
{
  home-manager.users.audun = {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
      ../../modules/vscode.nix
    ];
    catppuccin = {
      enable = true;
      flavor = "mocha";
    };
    home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/audun" else "/home/audun";
    home.stateVersion = "26.05";
  };

}
