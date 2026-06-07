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
      # herdr; it rides SSH via sendEnv (see ssh.nix) so sshing from a herdr
      # pane into another workstation gets a raw shell instead of nesting
      # herdr. $TMUX means a manual tmux we shouldn't hijack.
      #
      # herdr sizes one shared runtime to the last-active client and has no
      # per-client size option, so a narrow client (phone) reflows every wide
      # client on the same session. Route narrow clients to their own session.
      programs.zsh.initContent = lib.mkAfter ''
        if [[ $- == *i* && -z "$HERDR_ENV" && -z "$TMUX" ]] \
           && [[ -n "$KITTY_WINDOW_ID" || -n "$SSH_CONNECTION" ]] \
           && command -v herdr >/dev/null 2>&1; then
          if (( ''${COLUMNS:-$(tput cols 2>/dev/null || echo 999)} < 100 )); then
            HERDR_SESSION=mobile herdr
          else
            herdr
          fi
        fi
      '';

      # Prefix-less nav that clears niri (Super) and kitty (Ctrl+Shift): Alt
      # for tabs, Ctrl+Alt for workspaces. Arrays keep the ctrl+b defaults
      # next to the direct chords. macOS maps left Option to Alt (kitty.nix).
      xdg.configFile."herdr/config.toml".text = ''
        [keys]
        next_tab = ["prefix+n", "alt+]"]
        previous_tab = ["prefix+p", "alt+["]
        switch_tab = ["prefix+1..9", "alt+1..9"]
        next_workspace = "ctrl+alt+]"
        previous_workspace = "ctrl+alt+["
        switch_workspace = ["prefix+shift+1..9", "ctrl+alt+1..9"]
      '';
    };
}
