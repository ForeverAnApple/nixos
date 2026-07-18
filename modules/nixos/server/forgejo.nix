{
  flake.modules.nixos.forgejo = {
    services.forgejo = {
      enable = true;
      lfs.enable = true;

      settings = {
        server = {
          DOMAIN = "git.jura.moe";
          ROOT_URL = "https://git.jura.moe/";
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = 3000;
          # host sshd port; forgejo advertises it in ssh clone URLs (built-in SSH stays off)
          SSH_PORT = 22022;
        };
        service.DISABLE_REGISTRATION = true;
      };
    };
  };
}
