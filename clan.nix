{
  inputs,
  self,
  ...
}:
{
  imports = [
    inputs.clan-core.flakeModules.default
  ];
  clan = {
    meta.name = "traholt";
    meta.domain = "tra.holt";
    specialArgs = {
      inherit inputs;
      inherit self;
    };
    modules = {
      "@schallerclan/tailscale" = inputs.nixpkgs.lib.modules.importApply ./clanServices/tailscale.nix {
        inherit self;
      };
    };
    inventory.machines = {
      fubuki = {
        tags = [
          "laptop"
          "gui"
          "tui"
          "gaming"
        ];
      };
      reisalin = {
        tags = [
          "desktop"
          "gui"
          "tui"
          "gaming"
        ];
      };
      kubira = {
        machineClass = "darwin";
        tags = [ "tui" ];
      };
    };

    inventory.instances = {
      #admin = {
      #roles.default.tags = {
      #all = { };
      #};
      #roles.default.settings = {
      #allowedKeys = {
      #unsecure_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEhC67GIeiOnqGf8FAzonAZEMkqugLbHhn1FJOTxu9kv haruna-12-05-2020";
      #nitrokey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAvn8Zv2HZ7UVHtVIhJFxwsx9NeP6zMAmdI3pKwn3F+5AAAADHNzaDphdHJhaG9sdA== ssh:atraholt";
      #};
      #  };
      #};
      sshd = {
        roles.server.machines.fubuki = { };
        roles.server.settings = {
          authorizedKeys = {
            kubira-se = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBC7JOKqvy7mI8KfMfrOVUgpBrMvnpMeQd9QmgPI9P2eyhbqikYe0zkP98Lvc6MIDk1oH3JVrdS51PGQ99Ts0DxI= homelab@secretive.kubira.local";
          };
        };
      };
      root-password = {
        module = {
          name = "users";
          input = "clan-core";
        };
        roles.default.tags = {
          nixos = { };
        };
        roles.default.settings = {
          user = "root";
          prompt = true;
        };
      };
      user-audun = {
        module = {
          name = "users";
          input = "clan-core";
        };
        roles.default.tags.all = { };
        roles.default.settings = {
          user = "audun";
          prompt = true;
          share = true;
          groups = [
            "wheel"
            "networkmanager"
            "video"
            "input"
          ];
        };
        roles.default.extraModules = [ ./users/audun/home.nix ];
      };
      wifi = {
        module.name = "wifi";
        module.input = "clan-core";
        roles.default = {
          tags.all = { };
          settings.networks.home = {
            keyMgmt = "wpa-psk";
            autoConnect = true;
          };
        };
      };
      #yggdrasil = {
      #  roles.default.tags.all = { };
      #};
      internet = {
        roles.default.machines = {
          fubuki.settings.host = "192.168.1.122";
          kubira.settings.host = "192.168.1.163";
          reisalin.settings.host = "192.168.1.10";
        };
      };
      #mycelium = {
      #  roles.peer.tags.all = { };
      #};
      clan-cache = {
        module = {
          name = "trusted-nix-caches";
          input = "clan-core";
        };
        roles.default.tags.all = { };
      };
      base-importer = {
        module.name = "importer";
        roles.default = {
          tags.all = { };
          extraModules = [ "${self}/modules/profiles/base.nix" ];
        };
      };
      darwin-importer = {
        module.name = "importer";
        roles.default = {
          tags.darwin = { };
          extraModules = [ "${self}/modules/profiles/darwin.nix" ];
        };
      };
      desktop-importer = {
        module.name = "importer";
        roles.default = {
          tags.desktop = { };
          extraModules = [ "${self}/modules/profiles/desktop.nix" ];
        };
      };
      gaming-importer = {
        module.name = "importer";
        roles.default = {
          tags.gaming = { };
          extraModules = [ "${self}/modules/profiles/gaming.nix" ];
        };
      };
      gui-importer = {
        module.name = "importer";
        roles.default = {
          tags.gui = { };
          extraModules = [ "${self}/modules/profiles/gui.nix" ];
        };
      };
      laptop-importer = {
        module.name = "importer";
        roles.default = {
          tags.laptop = { };
          extraModules = [ "${self}/modules/profiles/laptop.nix" ];
        };
      };
      nixos-importer = {
        module.name = "importer";
        roles.default = {
          tags.nixos = { };
          extraModules = [ "${self}/modules/profiles/nixos.nix" ];
        };
      };
      server-importer = {
        module.name = "importer";
        roles.default = {
          tags.server = { };
          extraModules = [ "${self}/modules/profiles/server.nix" ];
        };
      };
      tui-importer = {
        module.name = "importer";
        roles.default = {
          tags.tui = { };
          extraModules = [ "${self}/modules/profiles/tui.nix" ];
        };
      };
    };
  };
}
