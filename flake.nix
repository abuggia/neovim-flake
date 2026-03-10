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
              terraform-ls
              tflint
              ruff
              black
              rustfmt
              cargo
              rustc
              clang-tools
          ];
          vimrc = ''
            :lua package.path = "${self}/lua/?.lua;" .. package.path
            ''
            + nixpkgs.lib.readFile ./vimrc;
          neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (prev: {
            buildInputs = pkgs.neovim-unwrapped.buildInputs ++ dependencies;
          });
          # `nurl https://github.com/jghauser/follow-md-links.nvim 2>/dev/null`
          follow-md-links = pkgs.vimUtils.buildVimPlugin {
            name = "follow-md-links";
            src = pkgs.fetchFromGitHub {
              owner = "jghauser";
              repo = "follow-md-links.nvim";
              rev = "cf081a0a8e93dd188241a570b9a700b6a546ad1c";
              hash = "sha256-ElgYrD+5FItPftpjDTdKAQR37XBkU8mZXs7EmAwEKJ4=";
            };
            postPatch = ''
              substituteInPlace lua/follow-md-links.lua \
                --replace-fail 'local ts_utils = require("nvim-treesitter.ts_utils")' 'local function ts_utils()
                  return require("nvim-treesitter.ts_utils")
                end' \
                --replace-fail 'ts_utils.get_node_at_cursor()' 'ts_utils().get_node_at_cursor()' \
                --replace-fail 'ts_utils.get_next_node(node_at_cursor)' 'ts_utils().get_next_node(node_at_cursor)' \
                --replace-fail 'ts_utils.get_named_children(node_at_cursor)' 'ts_utils().get_named_children(node_at_cursor)'
            '';
            dependencies = [ pkgs.vimPlugins.nvim-treesitter ];
          };
          nvim = pkgs.wrapNeovim neovim-unwrapped {
            viAlias = true;
            vimAlias = true;
            withNodeJs = true;
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
                  follow-md-links
                  # lsp
                  # https://github.com/hrsh7th/nvim-cmp#setup
                  nvim-lspconfig
                  cmp-nvim-lsp
                  cmp-buffer
                  cmp-path
                  cmp-cmdline
                  nvim-cmp
                  dressing-nvim
                  lspkind-nvim
                  rustaceanvim
                  crates-nvim
                  fidget-nvim
                  vim-nix
                  # tree sitter
                  nvim-treesitter.withAllGrammars
                  nvim-treesitter-textobjects
                  copilot-lua
                  copilot-cmp
                  vim-just
                ];
              };
	          };
          };
        in
        {
          inherit nvim;
          default = nvim;
        });

      apps = withSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/nvim";
        };
      });

      overlays = {
        default = final: prev: { adam-neovim = prev.pkgs.callPackage ./. { }; };
      };
    };

}
