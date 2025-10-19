{
  flake.modules.homeManager.core = { lib, pkgs, ... }: {
    home.packages = lib.attrValues {
      inherit (pkgs)
        fd
	file
	;
    };
    programs = {
      ripgrep = {
        enable = true;
	arguments = [
	  "--line-number"
	  "--smart-case"
	];
      };
    };
  };
}
