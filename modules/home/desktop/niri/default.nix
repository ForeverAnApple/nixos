{
  flake.modules.homeManager.niri =
    {
      osConfig,
      pkgs,
      lib,
      ...
    }:
    {
      xdg.configFile."niri/config.kdl".source = pkgs.writeTextFile {
        name = "niri-config.kdl";
        text = builtins.readFile ./config.kdl;
        checkPhase = ''
          ${lib.getExe osConfig.programs.niri.package} validate --config "$target"
        '';
      };
    };
}
