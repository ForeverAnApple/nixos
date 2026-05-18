{
  flake.modules.nixos.sglang =
    { inputs, lib, pkgs, ... }:
    let
      cudaPkgs = import inputs.nixpkgs {
        system = pkgs.stdenv.hostPlatform.system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
          problems.handlers.flashinfer.broken = "warn";
        };
      };

      # SGLang/vLLM are still much happier on Python 3.12 than 3.13.
      python = pkgs.python312;
      sglangVersion = "0.5.9";
      cudaToolkit = cudaPkgs.cudaPackages.cudatoolkit;

      mkSglangTool =
        name: command:
        pkgs.writeShellApplication {
          inherit name;
          text = ''
            # Point build systems at the full joined CUDA toolkit, not just nvcc.
            # nvcc alone does not provide cuda_runtime.h on NixOS.
            export CUDA_HOME=${cudaToolkit}
            export CUDA_PATH=${cudaToolkit}
            export CUDAToolkit_ROOT=${cudaToolkit}
            export PATH=${cudaToolkit}/bin:$PATH
            export CPATH=${cudaToolkit}/include:''${CPATH:+:$CPATH}
            export LIBRARY_PATH=${cudaToolkit}/lib:${cudaToolkit}/lib/stubs:''${LIBRARY_PATH:+:$LIBRARY_PATH}
            export LD_LIBRARY_PATH=${lib.makeLibraryPath [ pkgs.stdenv.cc.cc ]}:${cudaToolkit}/lib:''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
            export UV_PYTHON_DOWNLOADS=never

            exec ${pkgs.uv}/bin/uv tool run \
              --python ${python}/bin/python3 \
              --with vllm \
              --from sglang==${sglangVersion} \
              ${command} "$@"
          '';
        };
    in
    {
      environment.systemPackages = [
        (mkSglangTool "sglang" "sglang")
        (mkSglangTool "killall_sglang" "killall_sglang")
      ];
    };
}
