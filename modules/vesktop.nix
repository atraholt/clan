{ ... }:
{
  home-manager.users.audun.catppuccin.vesktop.enable = true;
  programs.vesktop = {
    enable = true;
    settings = {
      arRPC = true;
      autoStartMinimized = false;
      discordBranch = "stable";
      hardwareAcceleration = true;
      hardwareVideoAcceleration = true;
      minimizeToTray = false;
    };
  };
}
