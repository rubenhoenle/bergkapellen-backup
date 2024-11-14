let
  millenium-falcon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFIaaFUiWgUeqsfoWdruHbBWkrJE5LPxrLq69CCnM24";
in
{
  /* bk nextcloud backup */
  "bk-nextcloud-backup-netrc.age".publicKeys = [ millenium-falcon ];

  /* uuid for healthchecks.io cronjob monitoring */
  "healthchecks-io-uuid.age".publicKeys = [ millenium-falcon ];
}
