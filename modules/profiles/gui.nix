{
  pkgs,
  ...
}:
{
  programs.kdeconnect.enable = true;
  programs.vscode.package = pkgs.vscode;
  services = {
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        autoLogin = {
          relogin = true;
          minimumUid = 1000;
        };
      };
      autoLogin = {
        enable = true;
        user = "audun";
      };
    };
    desktopManager.plasma6.enable = true;
  };
  environment.systemPackages = with pkgs; [
    vivaldi
    libnotify
    wl-clipboard
    vesktop
    ghostty
  ];
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    #aurorae
    plasma-browser-integration
    plasma-workspace-wallpapers
    konsole
    kwin-x11
    #(lib.getBin qttools) # Expose qdbus in PATH
    ark
    elisa
    gwenview
    okular
    kate
    ktexteditor # provides elevated actions for kate
    khelpcenter
    # dolphin
    baloo-widgets # baloo information in Dolphin
    # dolphin-plugins
    # spectacle
    #ffmpegthumbs
    krdp
  ];
}
