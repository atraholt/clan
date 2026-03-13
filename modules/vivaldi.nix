{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.vivaldi ];
  programs.chromium = {
    enable = true;
    package = pkgs.vivaldi;
    nativeMessagingHosts = [
      pkgs.kdePackages.plasma-browser-integration
    ];
  };
  catppuccin.vivaldi.enable = true;
}
