{
  flake.modules.homeManager.core =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      home.shellAliases = {
        cd = "z";
      };
      # Suppress zoxide's "not initialized last" doctor warning. starship and
      # oh-my-zsh both reinstall the precmd hook after zoxide, which triggers
      # the false positive on every cd. Functionality is unaffected.
      home.sessionVariables = {
        _ZO_DOCTOR = "0";
      };
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    };
}
