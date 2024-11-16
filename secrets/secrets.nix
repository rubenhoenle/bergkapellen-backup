let
  millenium-falcon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFIaaFUiWgUeqsfoWdruHbBWkrJE5LPxrLq69CCnM24";
  raspi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl4/yR4VgF9lBuVajiNuu6t9ZFXzm7ITabO3CdYGE2M";
in
{
  /* bk nextcloud backup */
  "bk-nextcloud-backup-netrc.age".publicKeys = [ millenium-falcon raspi ];

  /* uuid for healthchecks.io cronjob monitoring */
  "healthchecks-io-uuid.age".publicKeys = [ millenium-falcon raspi ];
}
