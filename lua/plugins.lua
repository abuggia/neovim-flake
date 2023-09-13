
local tree = require('nvim-tree.api')

local lazy = require("bufferline.lazy")
local bl = lazy.require('bufferline.commands')
local bl_state = lazy.require('bufferline.state')

local M = {
  last_bl_element = nil
}

function M.toggle_nav()
  if M.last_bl_element then
    bl.go_to(M.last_bl_element)
    M.last_bl_element = nil
  else
    curr = bl.get_current_element_index(bl_state)
    if curr then
      M.last_bl_element = curr
      print("got last buf: ", M.last_bl_element)
    end

    tree.tree.focus()
  end
end

function M.open()
  M.last_bl_element = nil
  tree.node.open.edit()
end

function M.in_place()
  M.last_bl_element = nil
  tree.node.open.replace_tree_buffer()  
end


-- nvim-tree
------------
require('nvim-tree').setup({
    on_attach = function(bufnr)
      local api = require "nvim-tree.api"

      -- default mappings
      api.config.mappings.default_on_attach(bufnr)

      local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      vim.keymap.set('n', '<leader>t', M.toggle_nav, { noremap = true, silent = true, nowait = true })
      vim.keymap.set('n', '<BS>',  api.node.navigate.parent_close,        opts('Close Directory'))
      vim.keymap.set('n', '<CR>',  M.open,                                opts('Open'))
      vim.keymap.set('n', 'O',     M.in_place,                            opts('Open: In Place'))
      vim.keymap.set('n', '<Tab>', api.node.open.preview,                 opts('Open Preview'))
      vim.keymap.set('n', '.',     api.node.run.cmd,                      opts('Run Command'))
      vim.keymap.set('n', '-',     api.tree.change_root_to_parent,        opts('Up'))
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

    filters = { custom = { "^.git$" } }
})



-- Bufferline
------------
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

vim.keymap.set('n', '<M-h>', '<Cmd>BufferLineCyclePrev<CR>', { noremap = true, silent = true, nowait = true })
vim.keymap.set('n', '<M-l>', '<Cmd>BufferLineCycleNext<CR>', { noremap = true, silent = true, nowait = true })

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


