{
  # herdr rides with kitty: the kitty module is imported by exactly the
  # workstation hosts, so attaching here scopes herdr to them without
  # separate wiring. Service hosts never get kitty, so never get herdr.
  flake.modules.homeManager.kitty =
    {
      inputs,
      pkgs,
      lib,
      config,
      ...
    }:
    {
      home.packages = [ inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default ];

      # Auto-start herdr on a local kitty window or an SSH login, the same two
      # surfaces tmux used to own. HERDR_ENV=1 marks a pane already inside
      # herdr; it rides SSH via sendEnv (see ssh.nix) so sshing from a herdr
      # pane into another workstation gets a raw shell instead of nesting
      # herdr. $TMUX means a manual tmux we shouldn't hijack;
      # $HERDR_NO_AUTOSTART opts a window out (the kitty quick-access dropdown
      # sets it via kitty_override, see kitty.nix).
      #
      # herdr sizes one shared runtime to the last-active client and has no
      # per-client size option, so a narrow client (phone) reflows every wide
      # client on the same session. Route narrow clients to their own session.
      #
      # Only the first local kitty tab starts herdr; later tabs get a plain
      # shell. Gate on a live herdr *client* process, not the server daemon
      # (which persists after every client exits). The client command is bare
      # `herdr`; `herdr server` is the daemon, so drop the server line first.
      # `command grep` bypasses the interactive grep=batgrep alias (zsh.nix).
      programs.zsh.initContent = lib.mkAfter ''
        if [[ $- == *i* && -z "$HERDR_ENV" && -z "$TMUX" && -z "$HERDR_NO_AUTOSTART" ]] \
           && [[ -n "$KITTY_WINDOW_ID" || -n "$SSH_CONNECTION" ]] \
           && command -v herdr >/dev/null 2>&1; then
          if [[ -n "$KITTY_WINDOW_ID" ]] \
             && ps -axo command= 2>/dev/null | command grep -v ' server' | command grep -Eq '^(\S*/)?[h]erdr( |$)'; then
            :
          elif (( ''${COLUMNS:-$(tput cols 2>/dev/null || echo 999)} < 100 )); then
            HERDR_SESSION=mobile herdr
          else
            herdr
          fi
        fi
      '';

      # config.toml is left unmanaged on purpose. herdr's settings TUI persists
      # changes (sound, theme, …) back into it, which fails against a read-only
      # nix-store symlink. Seed a writable copy and re-seed only when this
      # declarative content changes, so per-host runtime edits survive rebuilds.
      #
      # Prefix-less nav that clears niri (Super) and kitty (Ctrl+Shift): Alt
      # for tabs, Alt+Shift for agents, Ctrl+Alt for workspaces. Arrays keep
      # the ctrl+b defaults next to the direct chords. macOS maps left Option
      # to Alt (kitty.nix).
      home.activation.herdrConfig =
        let
          seed = pkgs.writeText "herdr-config.toml" ''
            onboarding = false

            [keys]
            next_tab = ["prefix+n", "alt+]"]
            previous_tab = ["prefix+p", "alt+["]
            switch_tab = ["prefix+1..9", "alt+1..9"]
            next_agent = "alt+shift+]"
            previous_agent = "alt+shift+["
            focus_agent = "alt+shift+1..9"
            next_workspace = "ctrl+alt+]"
            previous_workspace = "ctrl+alt+["
            switch_workspace = ["prefix+shift+1..9", "ctrl+alt+1..9"]

            [experimental]
            kitty_graphics = true
          '';
          dir = "${config.xdg.configHome}/herdr";
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          dst="${dir}/config.toml"
          stamp="${dir}/.config-seed"
          if [ ! -e "$dst" ] || [ "$(cat "$stamp" 2>/dev/null)" != "${seed}" ]; then
            run mkdir -p "${dir}"
            run install -m644 "${seed}" "$dst"
            run sh -c 'printf %s "${seed}" > "'"$stamp"'"'
          fi
        '';
    };
}
