{
  networking = {
    firewall.enable = false;

    interfaces.eth0 = {
      useDHCP = true;
      ipv4.addresses = [{
        address = "192.168.178.6";
        prefixLength = 24;
      }];
    };
  };
}
