{
  flake.modules.nixos.vllm =
    { inputs, pkgs, ... }:
    let
      cudaPkgs = import inputs.nixpkgs {
        system = pkgs.stdenv.hostPlatform.system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
          problems.handlers.flashinfer.broken = "warn";
        };
      };
    in
    {
      environment.systemPackages = [ cudaPkgs.vllm ];
    };
}
