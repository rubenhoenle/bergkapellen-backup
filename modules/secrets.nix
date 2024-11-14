{
  age = {
    identityPaths = [ "/home/ruben/.ssh/agenix/bergkapellen-backup/id_ed25519" ];

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
