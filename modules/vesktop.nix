{ ... }:
{
  catppuccin.vesktop.enable = true;
  programs.vesktop = {
    enable = true;
    settings = {
      arRPC = true;
      autoStartMinimized = false;
      customTitleBar = true;
      discordBranch = "stable";
      hardwareAcceleration = true;
      hardwareVideoAcceleration = true;
      minimizeToTray = false;
    };
  };
}
