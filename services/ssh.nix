{
  /* Endless SSH honeypot */
  services.endlessh = {
    enable = true;
    port = 22;
    openFirewall = true;
  };

  /* actual OpenSSH daemon */
  services.openssh = {
    enable = true;
    ports = [ 69 ];
    openFirewall = true;

    /* allow root login for remote deploy aka. rebuild-switch  */
    settings.AllowUsers = [ "root" "ruben" ];
    settings.PermitRootLogin = "yes";

    /* require public key authentication for better security */
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
}
