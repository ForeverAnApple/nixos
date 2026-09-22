{
  flake.modules.homeManager.kitty-image-paste =
    { pkgs, ... }:
    let
      # Claude Code's Ctrl+V image path shells out to xclip/wl-paste on the
      # machine it runs on, so over SSH it reads the remote clipboard (or
      # nothing, with no DISPLAY). Its only SSH-surviving image input is an
      # absolute path to a file the remote can open. This ships the Mac
      # clipboard's PNG over the existing ssh and pastes the path it lands at.
      host = "catjailer";
      kitten = pkgs.writeText "paste-remote-image.py" ''
        import os
        import secrets
        import subprocess
        import sys
        import tempfile
        import time

        REMOTE_DIR = "$HOME/.cache/kitty-paste"


        def dump_clipboard_png(dest):
            quoted = dest.replace("\\", "\\\\").replace('"', '\\"')
            script = (
                'set png_data to (the clipboard as «class PNGf»)\n'
                'set fp to open for access POSIX file "' + quoted + '" with write permission\n'
                'write png_data to fp\n'
                'close access fp\n'
            )
            result = subprocess.run(
                ["osascript", "-e", script],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            return result.returncode == 0 and os.path.getsize(dest) > 0


        def upload(host, local):
            name = time.strftime("%Y%m%d-%H%M%S") + "-" + secrets.token_hex(3)
            remote = (
                'd="' + REMOTE_DIR + '"; mkdir -p "$d"; '
                'find "$d" -maxdepth 1 -name "*.png" -mmin +1440 -delete 2>/dev/null; '
                'f="$d/' + name + '.png"; cat > "$f" && printf %s "$f"'
            )
            with open(local, "rb") as handle:
                result = subprocess.run(
                    ["ssh", host, remote],
                    stdin=handle,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                )
            if result.returncode != 0:
                raise RuntimeError(
                    result.stderr.decode(errors="replace").strip() or "ssh exited nonzero"
                )
            path = result.stdout.decode().strip()
            if not path.startswith("/"):
                raise RuntimeError("remote returned no path")
            return path


        def fail(message):
            print(message, file=sys.stderr)
            print("press enter to dismiss", file=sys.stderr)
            try:
                input()
            except EOFError:
                pass
            return None


        def main(args):
            if len(args) < 2:
                return fail("usage: paste-remote-image.py <ssh-host>")
            host = args[1]
            fd, local = tempfile.mkstemp(suffix=".png")
            os.close(fd)
            try:
                if not dump_clipboard_png(local):
                    return fail("clipboard holds no image")
                print("uploading to " + host + " ...")
                try:
                    return upload(host, local)
                except RuntimeError as err:
                    return fail(str(err))
            finally:
                os.unlink(local)


        def handle_result(args, answer, target_window_id, boss):
            if not answer:
                return
            window = boss.window_id_map.get(target_window_id)
            if window is not None:
                window.paste_bytes(answer)
      '';
    in
    {
      xdg.configFile."kitty/paste-remote-image.py".source = kitten;
      programs.kitty.keybindings."cmd+shift+v" = "kitten paste-remote-image.py ${host}";
    };
}
