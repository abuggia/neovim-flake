{

  description = "Adam Buggia's Neovim config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs :
    let
      withSystems = nixpkgs.lib.genAttrs flake-utils.lib.defaultSystems;
      vimrc = nixpkgs.lib.readFile ./vimrc;
      luaPackagePath = '':lua package.path = "${self}/lua/?.lua;" .. package.path'';
      requireInit = '':lua require("init")'';
    in {

      packages = withSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          join = pkgs.lib.concatStringsSep "\n";
        in
        {
          nvim = pkgs.wrapNeovim pkgs.neovim-unwrapped {
            viAlias = true;
            vimAlias = true;
            withNodeJs = false;
            withPython3 = false;
            withRuby = false;
            configure = {
              customRC = join [vimrc luaPackagePath requireInit];

              packages.myPlugins = {
                start = with pkgs.vimPlugins;
                [
                  plenary-nvim
                  rust-tools-nvim
                  crates-nvim
                  vim-nix
                  nvim-treesitter
                  nvim-treesitter-textobjects
                  telescope-nvim
                  telescope-fzy-native-nvim
                  telescope-frecency-nvim
                  markdown-preview-nvim
                  catppuccin-nvim
                  nvim-web-devicons
                  bufferline-nvim
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
