{
  networking = {
    firewall.enable = true;
    hostName = "bergkapellen-backup";

    defaultGateway = "192.168.178.1";
    nameservers = [ "192.168.178.1" ];

    interfaces.eth0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.178.6";
        prefixLength = 24;
      }];
    };
  };
}
