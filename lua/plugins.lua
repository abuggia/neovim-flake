
require('follow-md-links')

local tree = require('nvim-tree.api')
local bufdelete = require('bufdelete')

local lazy = require("bufferline.lazy")
local bl = lazy.require('bufferline.commands')

local last_bl_element = nil

local function toggle_nav_focus()
  if last_bl_element then
    bl.go_to(last_bl_element)
    last_bl_element = nil
  else
    curr = bl.get_current_element_index(lazy.require('bufferline.state'))
    if curr then
      last_bl_element = curr
    end
    tree.tree.focus()
  end
end

local function open_file()
  last_bl_element = nil
  tree.node.open.edit()
end

function in_place()
  last_bl_element = nil
  tree.node.open.replace_tree_buffer()  
end

-- nvim-tree
------------
require('nvim-tree').setup({
    on_attach = function(bufnr)
      local api = require "nvim-tree.api"

      -- default mappings
      -- api.config.mappings.default_on_attach(bufnr)

      local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      vim.keymap.set('n', '<leader>t', toggle_nav_focus, { noremap = true, silent = true, nowait = true })
      vim.keymap.set('n', '<leader>T', '<CMD>NvimTreeToggle<CR>', { noremap = true, silent = true, nowait = true })
      vim.keymap.set('n', '<BS>',  api.node.navigate.parent_close,        opts('Close Directory'))
      vim.keymap.set('n', '<CR>',  open_file,                             opts('Open'))
      vim.keymap.set('n', 'O',     in_place,                              opts('Open: In Place'))
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
vim.keymap.set('n', '<M-w>', function() bufdelete.bufdelete(0, true) end, { noremap = true, silent = true, nowait = true })

-- autocomplete
local cmp = require("cmp")
local lspkind = require("lspkind")
cmp.setup({
  completion = {
    completeopt = "menu,menuone,preview,noselect",
  },
  sources = cmp.config.sources({
 -- { name = "buffer" },
    { name = "path" },
    { name = "nvim_lsp" },
  }),
  mapping = cmp.mapping.preset.insert({
    ["<M-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
    ["<M-j>"] = cmp.mapping.select_next_item(), -- next suggestion
    ["<M-b>"] = cmp.mapping.scroll_docs(-4),
    ["<M-f>"] = cmp.mapping.scroll_docs(4),
    ["<M-Space>"] = cmp.mapping.complete(), -- show completion suggestions
    ["<M-e>"] = cmp.mapping.abort(), -- close completion window
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
  }),
  formatting = {
    format = lspkind.cmp_format({
      maxwidth = 50,
      ellipsis_char = "...",
    }),
  },
})

-- LSPs
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")

lspconfig.svelte.setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.js", "*.ts" },
      callback = function(ctx)
        if client.name == "svelte" then
          client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
        end
      end,
    })
  end,
})

lspconfig.tailwindcss.setup({
  capabilities = capabilities,
})

lspconfig.terraformls.setup({
  capabilities = capabilities,
})

lspconfig.tflint.setup({
  capabilities = capabilities,
})

-- Rust
local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      vim.keymap.set("n", "<leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
      -- todo: does this belong somewhere else?
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
      vim.keymap.set("n", "rn", vim.lsp.buf.rename, { buffer = bufnr })
    end,
  },
})

require("fidget").setup()

-- Treesitter
require('nvim-treesitter.configs').setup({
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting=false,
  },
  ident = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-space>",
      node_incremental = "<C-space>",
      scope_incremental = false,
      node_decremental = "<bs>",
    },
  },
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
        ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
        ["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
        ["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },

        -- works for javascript/typescript files (custom capture I created in after/queries/ecma/textobjects.scm)
        ["a:"] = { query = "@property.outer", desc = "Select outer part of an object property" },
        ["i:"] = { query = "@property.inner", desc = "Select inner part of an object property" },
        ["l:"] = { query = "@property.lhs", desc = "Select left part of an object property" },
        ["r:"] = { query = "@property.rhs", desc = "Select right part of an object property" },

        ["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
        ["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },

        ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
        ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

        ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
        ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },

        ["af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
        ["if"] = { query = "@call.inner", desc = "Select inner part of a function call" },

        ["am"] = { query = "@function.outer", desc = "Select outer part of a method/function definition" },
        ["im"] = { query = "@function.inner", desc = "Select inner part of a method/function definition" },

        ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]f"] = { query = "@call.outer", desc = "Next function call start" },
        ["]m"] = { query = "@function.outer", desc = "Next method/function def start" },
        ["]c"] = { query = "@class.outer", desc = "Next class start" },
        ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
        ["]l"] = { query = "@loop.outer", desc = "Next loop start" },

        -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
        -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
        ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
        ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
      },
      goto_next_end = {
        ["]F"] = { query = "@call.outer", desc = "Next function call end" },
        ["]M"] = { query = "@function.outer", desc = "Next method/function def end" },
        ["]C"] = { query = "@class.outer", desc = "Next class end" },
        ["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
        ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
      },
      goto_previous_start = {
        ["[f"] = { query = "@call.outer", desc = "Prev function call start" },
        ["[m"] = { query = "@function.outer", desc = "Prev method/function def start" },
        ["[c"] = { query = "@class.outer", desc = "Prev class start" },
        ["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
        ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
      },
      goto_previous_end = {
        ["[F"] = { query = "@call.outer", desc = "Prev function call end" },
        ["[M"] = { query = "@function.outer", desc = "Prev method/function def end" },
        ["[C"] = { query = "@class.outer", desc = "Prev class end" },
        ["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
        ["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
      },
    },
  },
})

-- Copilot
require('copilot').setup({
  filetypes = {
    sh = function ()
      if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
        return false
      end
      return true
    end,
  },
})

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


