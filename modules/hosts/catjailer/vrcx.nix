{
  flake.modules.nixos."hosts/catjailer" = _: {
    nixpkgs.overlays = [
      (_final: prev: {
        vrcx = prev.vrcx.overrideAttrs (old: {
          # Upstream takes the single-instance lock only after the .NET backend
          # and SQLite are up, and app.quit() can't unwind them: duplicates live
          # forever holding the DB write lock. Take the lock before the backend exists.
          postPatch = (old.postPatch or "") + ''
            substituteInPlace src-electron/main.js \
              --replace-fail \
                "app.setPath('userData', userDataPath);" \
                "app.setPath('userData', userDataPath); if (!app.requestSingleInstanceLock()) app.exit(0);"
          '';
        });
      })
    ];
  };
}
