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
      ../../modules/vesktop.nix
    ];
    catppuccin = {
      enable = true;
      flavor = "mocha";
      bat.enable = true;
      btop.enable = true;
      eza.enable = true;
      ghostty.enable = true;
      mangohud.enable = true;
      zellij.enable = true;
    };
    home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/audun" else "/home/audun";
    home.stateVersion = "26.05";
  };

}
