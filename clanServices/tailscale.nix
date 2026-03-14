# https://git.clan.lol/dafitt/schallerclan/src/branch/main/clanServices/tailscale.nix
{ ... }:
{
  _class = "clan.service";
  manifest.name = "tailscale";
  manifest.categories = [ "Network" ];
  manifest.description = "Connect to a tailscale network.";
  manifest.readme = ''
    The service instance name will be the tailscale interface name.

    # Limitations

    - Only one instance of tailscale per machine is possible.

    # Usage

    ```nix
    # clan.nix
    inventory.instances.tailscale = {
      module.name = "@schallerclan/tailscale";
      module.input = "self";

      roles.default.tags = [ "tailscale" ];
      roles.default.machines."myMachine01" = { };
      roles.default.machines."myMachine02" = { };
    };
    ```

    Provide auth keys with the command `clan vars generate --generator tailscale --regenerate [<machine>]`.
  '';

  roles.default = {
    description = "Machines, which should connect to a tailscale network.";
    perInstance =
      { instanceName, ... }:
      {
        nixosModule =
          { config, ... }:
          {
            clan.core.vars.generators.tailscale = {
              prompts.authKey = {
                description = ''
                  Provide a tailscale "auth key" e.g. from <https://admin.tailscale.com/> to connect to a desired network.
                  See <https://tailscale.com/kb/1085/auth-keys#generate-an-auth-key> on how to generate an auth key.
                '';
                type = "line";
                persist = false;
              };

              files.authKey = {
                secret = true;
              };

              script = ''
                cat $prompts/authKey > $out/authKey
              '';
            };

            services.tailscale = {
              enable = true;
              interfaceName = instanceName;
              authKeyFile = config.clan.core.vars.generators.tailscale.files.authKey.path;
            };
          };
      };
  };
}
