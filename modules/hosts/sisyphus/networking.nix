# Declarative NetworkManager profile for the WAN NIC.
#
# Without this, NM boots into "assumed/external" mode on enp1s0 because
# initrd's systemd-networkd has already configured the address by the
# time stage 2 starts. In that mode NM never runs its own DHCP client,
# so it never renews the lease. The kernel-set valid_lft (= DHCP lease
# lifetime, 86400s on Vultr) silently counts down and the kernel removes
# the v4 address when it hits zero. The fallback "Wired connection 1"
# profile (autoconnect-priority = -999) doesn't auto-activate because
# the link stays UP, so NM sees no deactivation event. Net result:
# host loses IPv4 ~24h after boot and stays that way.
#
# Giving NM a real on-disk profile with priority > -999 forces it to
# activate THIS profile at boot, which means NM owns DHCP from second
# zero and renews the lease at T/2 on schedule.
#
# Upstream context: RH bug #1829461 ("initramfs systemd-networkd v245
# DHCP lease lost results in NetworkManager disabling IPv4 at boot"),
# closed CANTFIX with the same workaround.
{
  flake.modules.nixos."hosts/sisyphus" = {
    networking.networkmanager.ensureProfiles.profiles.enp1s0 = {
      connection = {
        id = "enp1s0";
        type = "ethernet";
        interface-name = "enp1s0";
        autoconnect = true;
        autoconnect-priority = 100;
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };
  };
}
