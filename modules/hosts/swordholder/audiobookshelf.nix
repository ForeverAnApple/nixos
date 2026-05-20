{
  # Library lives under /THICC/THICC/Torrents/Audiobooks. The parent dirs
  # on the ZFS pool were created in the pre-NixOS era and carry an orphan
  # gid 1000 (TrueNAS-era "users"); declaring it here under a distinct name
  # lets audiobookshelf join it for the traverse path without renaming
  # millions of inodes on the pool.
  flake.modules.nixos."hosts/swordholder" = {
    users.groups.legacy-users.gid = 1000;
    users.users.audiobookshelf.extraGroups = [ "legacy-users" ];
    users.users.faa.extraGroups = [ "audiobookshelf" ];
  };
}
