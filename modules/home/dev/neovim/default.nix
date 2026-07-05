{
  flake.modules.homeManager.neovim =
    { pkgs, ... }:
    {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
        withPython3 = false;
        withRuby = false;
        withNodeJs = false;

        plugins = with pkgs.vimPlugins; [
          catppuccin-nvim
          { plugin = blink-cmp; optional = true; }
          {
            plugin = nvim-treesitter.withPlugins (p: [
              p.vim
              p.lua
              p.vimdoc
              p.html
              p.css
              p.javascript
              p.typescript
              p.tsx
              p.c
              p.cpp
              p.rust
              p.zig
              p.nix
              p.toml
              p.markdown
              p.markdown_inline
            ]);
            optional = true;
          }
          { plugin = fzf-lua; optional = true; }
          { plugin = conform-nvim; optional = true; }
          { plugin = gitsigns-nvim; optional = true; }
          { plugin = crates-nvim; optional = true; }
          { plugin = snacks-nvim; optional = true; }
          { plugin = render-markdown-nvim; optional = true; }
          { plugin = plenary-nvim; optional = true; }
          { plugin = claude-code-nvim; optional = true; }
          { plugin = opencode-nvim; optional = true; }
        ];

        extraPackages = with pkgs; [
          lua-language-server
          vscode-langservers-extracted
          typescript-language-server
          stylua
          nixfmt
          prettier
          ripgrep
          fd
          fzf
        ];
      };

      xdg.configFile."nvim" = {
        source = ./config;
        recursive = true;
      };
    };
}
