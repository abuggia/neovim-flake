{

  description = "Adam Buggia's Neovim config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs :
    let
      withSystems = nixpkgs.lib.genAttrs flake-utils.lib.defaultSystems;
    in {

      packages = withSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          dependencies = with pkgs; [
              rust-analyzer
              cargo
              rustup
              zk
              nil
              lua-language-server
              nodePackages.svelte-language-server
              nodePackages."@tailwindcss/language-server"
              ruff
              black
              rustfmt
              cargo
              rustc
          ];
          vimrc = ''
            :lua package.path = "${self}/lua/?.lua;" .. package.path
            ''
            + nixpkgs.lib.readFile ./vimrc;
          neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (prev: {
            buildInputs = pkgs.neovim-unwrapped.buildInputs ++ dependencies;
          });
        in
        {
          nvim = pkgs.wrapNeovim neovim-unwrapped {
            viAlias = true;
            vimAlias = true;
            withNodeJs = false;
            withPython3 = false;
            withRuby = false;
            extraMakeWrapperArgs = ''--prefix PATH : "${pkgs.lib.makeBinPath dependencies}"'';
            configure = {
              customRC = vimrc;

              packages.myPlugins = {
                start = with pkgs.vimPlugins;
                [
                  plenary-nvim 
                  telescope-nvim
                  telescope-fzy-native-nvim
                  telescope-frecency-nvim
                  bufferline-nvim
                  bufdelete-nvim
                  nvim-tree-lua
                  nvim-web-devicons
                  catppuccin-nvim
                  markdown-preview-nvim
                  # lsp
                  nvim-lspconfig
                  rust-tools-nvim
                  crates-nvim
                  fidget-nvim
                  vim-nix
                  # tree sitter
                  nvim-treesitter
                  nvim-treesitter-textobjects
                ];
              };
	          };
        };
      });

      defaultPackage = withSystems (system: self.packages.${system}.nvim);

      defaultApp = withSystems (sys: {
        type = "app";
        program = "${self.defaultPackage."${sys}"}/bin/nvim";
      });

      overlay = final: prev: { adam-neovim = prev.pkgs.callPackage ./. { }; };
    };

}
