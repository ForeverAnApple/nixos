{
  flake.modules.nixos.sshd =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.kitty.terminfo ];

      services.openssh = {
        enable = true;
        # Real sshd lives off :22 — endlessh squats that port as a tarpit.
        # openFirewall = false keeps :22022 closed on public interfaces.
        # Tailnet reaches it via trustedInterfaces=[tailscale0] (set in core/tailscale.nix).
        # LAN reaches it via firewall.interfaces.<lan>.allowedTCPPorts on each host.
        ports = [ 22022 ];
        openFirewall = false;

        hostKeys = [
          {
            path = "/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];

        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          AuthenticationMethods = "publickey";
          PubkeyAuthentication = true;
          PermitEmptyPasswords = false;

          MaxAuthTries = 3;
          MaxSessions = 5;
          LoginGraceTime = 30;

          KexAlgorithms = [
            "sntrup761x25519-sha512@openssh.com"
            "curve25519-sha256"
            "curve25519-sha256@libssh.org"
          ];
          Ciphers = [
            "chacha20-poly1305@openssh.com"
            "aes256-gcm@openssh.com"
            "aes128-gcm@openssh.com"
          ];
          Macs = [
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
          ];

          X11Forwarding = false;
          AllowTcpForwarding = false;
          AllowAgentForwarding = false;
          GatewayPorts = "no";
          PermitTunnel = false;

          ClientAliveInterval = 300;
          ClientAliveCountMax = 2;
          UseDns = false;
        };
      };
    };
}
