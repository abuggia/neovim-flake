
-- nvim-tree
require('nvim-tree').setup({
    on_attach = function(bufnr)
      local api = require "nvim-tree.api"

      -- default mappings
      api.config.mappings.default_on_attach(bufnr)
    end
})

vim.keymap.set('n', '<leader>t', '<Cmd>NvimTreeFocus<CR>', { noremap = true, silent = true, nowait = true })
vim.keymap.set('n', '<leader>T', '<Cmd>NvimTreeToggle<CR>', { noremap = true, silent = true, nowait = true })

-- Rust
local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
})

require("fidget").setup()

-- Treesitter
require('nvim-treesitter.configs').setup {
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting=false,
  },
  ident = { enable = true }
}

-- Telescope
require('telescope').setup {
  file_ignore_patterns = {
    "*.bak", ".git/", "node_modules", ".zk/", "Caches/", "Backups/"
  },
  extensions = {
    fzy_native = {
      override_generic_sorter = true,
      override_file_sorter = true
    }
  }
}
require('telescope').load_extension 'fzy_native'

vim.keymap.set('n', '<leader>f', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>g', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })


-- Bufferline
local bufferline = require('bufferline')
bufferline.setup {
  options = {
    always_show_bufferline = false,
    buffer_close_icon = "x",
    diagnostics = false,
    diagnostics_update_in_insert = false,
    get_element_icon = function(elem)
      local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(elem.filetype, { default = false })
      return icon, hl
    end
  }
}

vim.keymap.set('n', '<M-,>', '<Cmd>BufferLineCyclePrev<CR>', { noremap = true, silent = true, nowait = true })
vim.keymap.set('n', '<M-.>', '<Cmd>BufferLineCycleNext<CR>', { noremap = true, silent = true, nowait = true })

