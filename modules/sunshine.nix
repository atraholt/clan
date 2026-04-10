{
  lib,
  config,
  pkgs,
  hardware,
  ...
}:
let
  jsonFormat = pkgs.formats.json { };
  isNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
  isIntelOld = lib.elem [ "intel-vaapi-driver" ] hardware.graphics.extraPackages;
  isIntelNew = lib.elem [ "intel-media-driver" ] hardware.graphics.extraPackages;
  isAMD = hardware.amdgpu.initrd.enable;
  sunshineCuda = pkgs.sunshine.override { cudaSupport = true; };
  sunshinePackage = if isNvidia then sunshineCuda else pkgs.sunshine;
  cfg = config.services.sunshine;
in
{
  options.services.sunshine.hostUUID = lib.mkOption {
    type = lib.types.str;
    example = "550e8400-e29b-41d4-a716-446655440000";
    description = ''
      Host's unique ID stored in `~/.config/sunshine/sunshine_state.json` as `root.uniqueid`.
    '';
  };
  services.sunshine = {
    package = sunshinePackage;
    enable = true;
    autoStart = true;
    openFirewall = true;
    capSysAdmin = true;
    applications = {
      apps = [
        {
          name = "Desktop";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
        }
      ];
    };
    settings = {
      origin_web_ui_allowed = "lan";
      upnp = "off";
      fps = lib.mkDefault "[30, 60]";
      resolutions = lib.mkDefault ''[1920x1080]'';
      min_threads = lib.mkDefault 2;
      hevc_mode = lib.mkDefault 0;
      av1_mode = lib.mkDefault 0;
      audio_sink = lib.mkDefault "auto";
      key_repeat_delay = lib.mkDefault 500;
      key_repeat_frequency = lib.mkDefault 25;
    };
    xdg.configFile."sunshine/sunshine_state.json".source = jsonFormat.generate {
      username = "sunshine";
      salt = "bjcHkzT3e6inxjBG";
      password = "D1DFEDC08E84A46A0C13ED30FD54CDC7C3E6F06AE35BB24021FFF3924CD72F61";
      root = {
        uniqueid = cfg.hostUUID;
        named_devices = [
          {
            name = "kubira";
            cert = ''
              -----BEGIN CERTIFICATE-----
              MIICvzCCAaegAwIBAgIBADANBgkqhkiG9w0BAQsFADAjMSEwHwYDVQQDDBhOVklE
              SUEgR2FtZVN0cmVhbSBDbGllbnQwHhcNMjUwMTE0MTczNjAxWhcNNDUwMTA5MTcz
              NjAxWjAjMSEwHwYDVQQDDBhOVklESUEgR2FtZVN0cmVhbSBDbGllbnQwggEiMA0G
              CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDz2FM9XzTDfI/GhAU/nOW3TRB3UKOp
              4f6Gf82IR7by5pksr01csAVRMX6nQ/48tGPAtYDqm8yCEjdvbjXuMwmXA6kNwICa
              CS2sLOltbKkPLkeTh/6LR6TE2Fizc8zpc2xx7Bm1mInwgvDu6EiU7GuTQg8lzVE3
              3uvI99VkfYUi8IIozM1W40WhPRucb33zqI3pTxdkTVbAXu5ehidmfGyaWZ709fun
              Sa1cIbFLm76f1LvDdC3f6Qt3cCRWBVSPF4N2uUSRbe1w6GddNDA8WNJdT6LHFQMa
              s+gki+V0J5VfRZ23WcBrc0rS+5NgcGkFfi0HgdBBkNOVLIEhLorTaLOFAgMBAAEw
              DQYJKoZIhvcNAQELBQADggEBADWcJAlZZWb/XMSc2U7QMfuX3qiA8CYAmsNrucMr
              5a1Eda54nEHovjNVgtS2BkejUUFJeEnJzAr0nY1eI27IieemHzwjgWwgJMW7zBvX
              CkvuAoyAaju82UFUtMODDJ7kOetyCDT1mouKn2gL689PkToQA5SzHxmcobm0JZV4
              jwOM9pXE9YtEnG3XniUup4Ev+P+U5njrSWIMu68BhzaOHu90vLEG6Bbb7v3aKlcM
              /8hwZQblilTepqyF6wvJeEv2buE63ey1i12DtjmLmjFyG5/IHlvOJRD16mSfeFCT
              wX4sNA+Ky0KAwiv7wHn/GuHjdn6hUlSWB7I88l2w5YV6w/U=
              -----END CERTIFICATE-----
            '';
            uuid = "477079F0-48D4-650B-1799-C6DD2ECD6161";
          }
          {
            name = "g25";
            cert = ''
              -----BEGIN CERTIFICATE-----
              MIICxjCCAa6gAwIBAgIIJR087UNbTQcwDQYJKoZIhvcNAQELBQAwIzEhMB8GA1UE
              AwwYTlZJRElBIEdhbWVTdHJlYW0gQ2xpZW50MB4XDTIzMDYxMTA2MzExNFoXDTQz
              MDYxMTA3MzExNFowIzEhMB8GA1UEAwwYTlZJRElBIEdhbWVTdHJlYW0gQ2xpZW50
              MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0l4FKG6bHszGVdTjFtCV
              XozFpbNZjyoyRvEFVqC5Yp3564YDVPxWp/2flsE+l7cUBPEohvB7nTcJT6GX2Kc0
              1x+Xw1TR/fqDw7llQjNlYhX6jWf3mm0Z0K2lEq/DOjmC1h3ITCRZjpKb3ST3RnpB
              OEVUIYelNJ1M7qMeOGfUcEttiGmJptRhg72UwB6I14INlpqY36asXWIlDR6dZ2DX
              ZovKLyJ0VlahYcs/a9K9KspqDpTScuYd/HWBLoU5iGfkZmrvL721I9e6UN33ZupX
              Iu3+/AuutuU5FOMh4KxmBu/S6O6OT1Nt4rvPtc928o+X8NgFOsG0XaIA28CBPcxb
              NwIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQAujG6TwViZaghx1YXExUQokW3Tk81Z
              tLQpn7GKmak2FKzYrsFtTceXFQuwEMIkz4M98YBiFu8O6xjWUSrIOdtIw7qBLu5L
              TFTlglrMs5tpDN9qD+f5ZaW46GZmqR0MQRo2JMBx33cbeY+VOSKbvvjm5SU5nhVp
              RwoO56KdBB3UX5zp+TcXqj4+DmJ09btJK6KAur/W8B+fJbMNLEauAGssAz2is8V4
              dx6GMvFcFkVN3AD9BOYTPAl6bgbo50bgnYlKjGjXm4eF9CluciyytLYfva/geHoB
              bTipqBgzx/RYP1AVBWQp7ibR68B2t298xHnD6VtiHf6HKL9cpHdQqXIF
              -----END CERTIFICATE-----
            '';
            uuid = "D57E17ED-8A31-050A-E782-EAC438D67C71";
          }
          {
            name = "reisalin";
            cert = ''
              -----BEGIN CERTIFICATE-----
              MIICvzCCAaegAwIBAgIBADANBgkqhkiG9w0BAQsFADAjMSEwHwYDVQQDDBhOVklE
              SUEgR2FtZVN0cmVhbSBDbGllbnQwHhcNMjYwMzE4MTU1NjAxWhcNNDYwMzEzMTU1
              NjAxWjAjMSEwHwYDVQQDDBhOVklESUEgR2FtZVN0cmVhbSBDbGllbnQwggEiMA0G
              CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC5ohnWOP/+3QhNWyVtk7TYsCt9gsYs
              RPdM6mtUVvqLla8Dcz30wbkEDip0qf0VYCcNit1RY6+t7ahRBpPAKeEe2QeSSCRS
              OWNEEUva8uAcFlabGpsJLvk4povhGCFXm/G8Qw88KgEag4ms4TsyYLu22pXy7aZZ
              7RLkyWe6cI4qAdtIFwfkck4nSUsxedzQMCHohfPUIsGZwcp0pX5fRD9QU0/ILJJx
              lEHFG0fNzX+redBcdDU8Z6z37E8DKZiGQvde07A9v+RU88YNSvKPAhZhe6br593+
              mGIWTZR6YvmfGfS41Q5XWZm+Cdzz6pwAFunbIk/Jp4iCnoVCA4nVXvS7AgMBAAEw
              DQYJKoZIhvcNAQELBQADggEBAA4pBek+ekyazQCrMsbr9exKpxQLQLG3DXRnVrxl
              mr3+9AqI84YsTmTXYwnvi+A4klX5MBHmbMr1f4PVmVQk8Vg/z16dNuyeSxetSa/J
              PtFjZ+2NqgyGidVb8Sy+RvXTOPP+PpRvkgBwohCnpH1HDjPlUia1NA7fLiGtJRxw
              4Xs2GdPmTGKBKy1bQBLMJ9est5zx3tGKqZVdXA+H8OG77BiVVH8XBOZE2LJfBCXj
              q57PcN6u9FxmI3xTHa2WZS4SnDPIvpqRC7uBoxBfcX4lELaf2onbtQFqIrSS/z04
              CA/DRgZUJxGFUvZdfdOhpmQ+nL9RUyd+/MenjEWu/SNpQ+o=
              -----END CERTIFICATE-----
            '';
            uuid = "25F9E8C2-A8AB-C605-A11D-21D5D545D1B6";
          }
        ];
      };
    };
  };
  environment = {
    systemPackages = [ sunshinePackage ];
    sessionVariables = lib.mkMerge [
      (lib.mkIf isNvidia {
        LIBVA_DRIVER_NAME = "nvidia";
      })
      (lib.mkIf isIntelOld {
        LIBVA_DRIVER_NAME = "i965";
      })
      (lib.mkIf isIntelNew {
        LIBVA_DRIVER_NAME = "iHD";
      })
      (lib.mkIf isAMD {
        LIBVA_DRIVER_NAME = "radeonsi";
      })
    ];
  };
}
