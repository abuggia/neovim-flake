
# key map cheat sheet

## tree & buffers

  - `<leader>t` - toggle focus to file nav
  - `<leader>T` - toggle open file nav

### when focussed on nav

      vim.keymap.set('n', '.',     api.node.run.cmd,                      opts('Run Command'))
      vim.keymap.set('n', 'a',     api.fs.create,                         opts('Create'))
      vim.keymap.set('n', 'd',     api.fs.remove,                         opts('Delete'))
      vim.keymap.set('n', 'E',     api.tree.expand_all,                   opts('Expand All'))
      vim.keymap.set('n', 'e',     api.fs.rename_basename,                opts('Rename: Basename'))
      vim.keymap.set('n', 'g?',    api.tree.toggle_help,                  opts('Help'))
      vim.keymap.set('n', 'I',     api.tree.toggle_gitignore_filter,      opts('Toggle Filter: Git Ignore'))
      vim.keymap.set('n', 'r',     api.fs.rename,                         opts('Rename'))
      vim.keymap.set('n', '<C-r>', api.tree.reload,                       opts('Refresh'))
      vim.keymap.set('n', 'W',     api.tree.collapse_all,                 opts('Collapse'))
      vim.keymap.set('n', 'y',     api.fs.copy.filename,                  opts('Copy Name'))
      
    end,

      vim.keymap.set('n', '-',     api.tree.change_root_to_parent,        opts('Up'))
      vim.keymap.set('n', 'O',     in_place,                              opts('Open: In Place'))


vim.keymap.set('n', '<M-h>', '<Cmd>BufferLineCyclePrev<CR>', { noremap = true, silent = true, nowait = true })
vim.keymap.set('n', '<M-l>', '<Cmd>BufferLineCycleNext<CR>', { noremap = true, silent = true, nowait = true })
vim.keymap.set('n', '<leader>w', function() bufdelete.bufdelete(0, true) end, { noremap = true, silent = true, nowait = true })



      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })



vim.keymap.set('n', '<leader>f', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>g', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
