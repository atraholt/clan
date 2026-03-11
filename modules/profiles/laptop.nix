{
  lib,
  ...
}:
{
  services.tlp = {
    enable = true;
    pd.enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 90;
    };
  };
  services.power-profiles-daemon.enable = lib.mkForce false;
}
