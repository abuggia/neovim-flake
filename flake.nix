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
          dependencies = [
              pkgs.rust-analyzer
              pkgs.cargo
              pkgs.rustup
          ];
          vimrc = ''
            lua << EOF
              package.path = "${self}/lua/?.lua;" .. package.path
              rustsrc_path = "${pkgs.rustPlatform.rustLibSrc}/core/Cargo.toml"
              vim.env.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}"
            EOF
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
                  nvim-tree-lua
                  vim-nix
                  telescope-nvim
                  telescope-fzy-native-nvim
                  telescope-frecency-nvim
                  markdown-preview-nvim
                  catppuccin-nvim
                  nvim-web-devicons
                  bufferline-nvim
                  nvim-lspconfig
                  rust-tools-nvim
                  crates-nvim
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
