{
  age = {
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.healthchecksIoUuid = {
      file = ../secrets/healthchecks-io-uuid.age;
      owner = "nc-backup";
      group = "nc-backup";
      mode = "440";
    };
    /* bk nextcloud backup */
    secrets.nextcloudBackupNetrc = {
      file = ../secrets/bk-nextcloud-backup-netrc.age;
      owner = "nc-backup";
      group = "nc-backup";
      mode = "400";
      path = "/home/nc-backup/.netrc";
    };
  };
}
