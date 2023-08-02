
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

