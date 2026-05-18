# Sanoid: local ZFS snapshot retention on THICC.
#
# Policy is one template applied recursively to the whole pool. Replication
# (syncoid → off-box target) is not configured yet — this is local-only,
# disk-fail / fat-finger recovery, not off-site disaster recovery.
#
# Retention: 36 hourly + 30 daily + 3 monthly. No yearly — for a media pool,
# a year-old snapshot of a deleted movie isn't worth the metadata overhead.
# Adjust per-dataset by adding a second `services.sanoid.datasets.<name>`
# entry that pins a different template; nested datasets inherit by default.
{
  flake.modules.nixos."hosts/swordholder" =
    { ... }:
    {
      services.sanoid = {
        enable = true;

        templates.media = {
          hourly = 36;
          daily = 30;
          monthly = 3;
          yearly = 0;
          autosnap = true;
          autoprune = true;
        };

        datasets."THICC" = {
          useTemplate = [ "media" ];
          recursive = true;
        };
      };
    };
}
