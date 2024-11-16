{ pkgs, config, ... }:
let
  mntPath = "/run/media/nc-backup/HDD";
  syncDir = "${mntPath}/synced";
  resticDir = "${mntPath}/restic";

  nextcloudSyncScript = pkgs.writeText "nc-sync-script.sh" (pkgs.lib.strings.concatLines (
    [
      # monitoring start signal
      "${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 https://hc-ping.com/$(${pkgs.coreutils}/bin/cat ${config.age.secrets.healthchecksIoUuid.path})/bk-nc-backup-sync/start"

      # nextcloud sync
      "mkdir -p ${syncDir}"
      "${pkgs.nextcloud-client}/bin/nextcloudcmd -h -n --path / ${syncDir} https://cloud.shw-bergkapelle.de"

      # monitoring exit signal
      "${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 https://hc-ping.com/$(cat ${config.age.secrets.healthchecksIoUuid.path})/bk-nc-backup-sync/$?"
    ]
  ));
in
{
  users.users.nc-backup = {
    name = "nc-backup";
    group = "nc-backup";
    description = "Nextcloud backup service user";
    isSystemUser = true;
    createHome = true;
    home = "/home/nc-backup";
    uid = 999;
  };
  users.groups.nc-backup.gid = 999;

  /* ------------------------------------------------------------------------------------- */

  /* mount the external harddrive on startup */
  fileSystems."${mntPath}" = {
    device = "/dev/disk/by-uuid/65649b90-f98d-4ebe-b95c-6a6ea36be6c4";
    fsType = "ext4";
  };

  /* ------------------------------------------------------------------------------------- */

  /* nextcloud sync to pull latest file structure */
  systemd = {
    services.nc-backup = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "nc-backup";
        Group = "nc-backup";
        ExecStart = "${pkgs.bash}/bin/bash ${nextcloudSyncScript}";
      };
      /* run the restic backup job afterwards */
      onSuccess = [ "restic-backups-nextcloud.service" ];
      onFailure = [ "restic-backups-nextcloud.service" ];
    };
    timers.nc-backup = {
      wantedBy = [ "timers.target" ];
      partOf = [ "nc-backup.service" ];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };
  };

  /* ------------------------------------------------------------------------------------- */

  /* restic backup to have some history - so we would be able to jump back in time */
  services.restic.backups.nextcloud = {
    user = "nc-backup";
    initialize = true;
    # the password will be "Schlagzeug" - no need to encrypt this as everything is kept on the local harddrive only - but seems like it's not possible to provide no password
    passwordFile = "${pkgs.writeText "restic-password-file" "Schlagzeug"}";
    repository = resticDir;
    paths = [ syncDir ];
    backupPrepareCommand = "${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 https://hc-ping.com/$(cat ${config.age.secrets.healthchecksIoUuid.path})/bk-nc-backup-restic/start";
    pruneOpts = [
      "--keep-hourly 48"
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
      "--keep-yearly 10"
    ];
    extraBackupArgs = [ "--exclude-caches" ];
    timerConfig = null;
  };
  /* monitoring for restic backup */
  systemd.services."restic-backups-nextcloud" = {
    onSuccess = [ "restic-notify-nextcloud@success.service" ];
    onFailure = [ "restic-notify-nextcloud@failure.service" ];
  };
  systemd.services."restic-notify-nextcloud@" =
    let
      script = pkgs.writeText "restic-notify-nextcloud.sh"
        ''
          ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 https://hc-ping.com/$(cat ${config.age.secrets.healthchecksIoUuid.path})/bk-nc-backup-restic/''${MONITOR_EXIT_STATUS}
        '';
    in
    {
      serviceConfig = {
        Type = "oneshot";
        User = "nc-backup";
        ExecStart = "${pkgs.bash}/bin/bash ${script}";
      };
    };
}
