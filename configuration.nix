{ pkgs, ... }:
{
  imports = [
    ./modules
    ./services
  ];

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  swapDevices = [{ device = "/swapfile"; size = 2048; }];

  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    git
    btop
  ];





  system.stateVersion = "23.05";
}
