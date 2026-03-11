{ pkgs, ... }:
{
  home-manager.users.audun = {
    imports = [
      ../../modules/vscode.nix
    ];
    home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/audun" else "/home/audun";
    home.stateVersion = "26.05";
  };
}
