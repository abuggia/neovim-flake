
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
    buffer_close_icon = "x",
    diagnostics = false,
    diagnostics_update_in_insert = false,
    get_element_icon = function(elem)
      local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(elem.filetype, { default = false })
      return icon, hl
    end
  }
}

vim.keymap.set('n', '<M-,>', '<Cmd>BufferLineCyclePrev<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<M-.>', '<Cmd>BufferLineCycleNext<CR>', { noremap = true, silent = true })

