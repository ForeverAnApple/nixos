{
  flake.modules.nixos."hosts/moonsnatcher" = {
    nixpkgs.overlays = [
      (_final: prev: {
        # Upstream corrected this pnpm hash after the pinned nixpkgs revision.
        typescript-language-server = prev.typescript-language-server.overrideAttrs (old: {
          pnpmDeps = old.pnpmDeps.overrideAttrs {
            outputHash = "sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=";
          };
        });
      })
    ];
  };
}
