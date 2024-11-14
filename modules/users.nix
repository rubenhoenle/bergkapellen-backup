let
  ssh-key = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN17O8nYCSqrUUboEl5fHFN5suqsAgDboPM/6ORrnqVaAAAABHNzaDo= ruben@millenium-falcon";
in
{
  users.mutableUsers = true;
  users.groups = {
    ruben = {
      gid = 1000;
      name = "ruben";
    };
  };
  users.users = {
    ruben = {
      uid = 1000;
      home = "/home/ruben";
      isNormalUser = true;
      name = "ruben";
      group = "ruben";
      extraGroups = [ "wheel" ];
    };
  };
  users.users.root.openssh.authorizedKeys.keys = [ ssh-key ];
  users.users.ruben.openssh.authorizedKeys.keys = [ ssh-key ];
}
