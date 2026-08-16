# ACME under MagicDNS

All certs issue via Cloudflare DNS-01 from Caddy ([caddy.nix](../modules/nixos/server/caddy.nix)).

MagicDNS owns `jura.moe` inside the tailnet (headscale `base_domain`) and NXDOMAINs every record it doesn't serve — including the SOA probes certmagic uses for zone detection and the TXT lookups of its propagation self-check. Without an override, zone detection walks up to the TLD and renewal fails silently until the cert expires.

Every `tls` block issuing for a `jura.moe` name must pin `resolvers 1.1.1.1`.

[cert-watch.nix](../modules/home/desktop/cert-watch.nix) probes one endpoint per issued cert daily from the desktop and raises a critical notification when a cert is under 21 days from expiry or the endpoint fails TLS.
