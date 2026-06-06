{
  # herdr rides with kitty: the kitty module is imported by exactly the
  # workstation hosts, so attaching here scopes herdr to them without
  # separate wiring. Service hosts never get kitty, so never get herdr.
  flake.modules.homeManager.kitty =
    {
      inputs,
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = [ inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default ];

      # Auto-start herdr on a local kitty window or an SSH login, the same two
      # surfaces tmux used to own. HERDR_ENV=1 marks a pane already inside
      # herdr; $TMUX means a manual tmux we shouldn't hijack.
      programs.zsh.initContent = lib.mkAfter ''
        if [[ $- == *i* && -z "$HERDR_ENV" && -z "$TMUX" ]] \
           && [[ -n "$KITTY_WINDOW_ID" || -n "$SSH_CONNECTION" ]] \
           && command -v herdr >/dev/null 2>&1; then
          herdr
        fi
      '';
    };
}
