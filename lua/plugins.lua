
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
local function enable_lsp(server, config)
  vim.lsp.config(server, vim.tbl_deep_extend("force", {
    capabilities = capabilities,
  }, config or {}))
  vim.lsp.enable(server)
end

enable_lsp("svelte", {
  on_attach = function(client, _)
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.js", "*.ts" },
      callback = function(ctx)
        if client.name == "svelte" then
          client:notify("$/onDidChangeTsOrJsFile", { uri = vim.uri_from_fname(ctx.match) })
        end
      end,
    })
  end,
})

enable_lsp("tailwindcss")
enable_lsp("terraformls")
enable_lsp("tflint")
enable_lsp("clangd", {
  init_options = {
      -- cmake can generate `compile_commands.json` but it goes in the build dir
      compilationDatabasePath = 'build'
  }
})

-- Set up a group for LSP-related autocommands
local lsp_augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })


-- Autocommand to run upon LSP client attachment
vim.api.nvim_create_autocmd("LspAttach", {
    group = lsp_augroup,
    callback = function(args)
        vim.keymap.set('n','gd',vim.lsp.buf.definition,{buffer=args.buf;});

        local client = vim.lsp.get_client_by_id(args.data.client_id)
        -- Ensure the attached client supports formatting
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_formatting) then
            -- Set up format on save (optional but recommended)
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = args.buf,
                callback = function()
                    vim.lsp.buf.format { async = false }
                end,
            })
        end
    end,
})

-- Rust (rustaceanvim)
vim.g.rustaceanvim = {
  server = {
    capabilities = capabilities,
    on_attach = function(_, bufnr)
      vim.keymap.set("n", "<C-space>", vim.lsp.buf.hover, { buffer = bufnr })
      vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, { buffer = bufnr })
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
      vim.keymap.set("n", "rn", vim.lsp.buf.rename, { buffer = bufnr })
    end,
  },
}

require("fidget").setup()

-- Treesitter
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end

    pcall(vim.treesitter.start, args.buf)
  end,
})

require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
  },
  move = {
    set_jumps = true,
  },
})

local ts_select = require("nvim-treesitter-textobjects.select")
local ts_move = require("nvim-treesitter-textobjects.move")

local select_keymaps = {
  ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
  ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
  ["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
  ["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },
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
}

for lhs, mapping in pairs(select_keymaps) do
  vim.keymap.set({ "x", "o" }, lhs, function()
    ts_select.select_textobject(mapping.query, mapping.query_group or "textobjects")
  end, { desc = mapping.desc })
end

local function set_ts_move(mode, lhs, query, query_group, desc)
  vim.keymap.set({ "n", "x", "o" }, lhs, function()
    ts_move[mode](query, query_group or "textobjects")
  end, { desc = desc })
end

set_ts_move("goto_next_start", "]f", "@call.outer", nil, "Next function call start")
set_ts_move("goto_next_start", "]m", "@function.outer", nil, "Next method/function def start")
set_ts_move("goto_next_start", "]c", "@class.outer", nil, "Next class start")
set_ts_move("goto_next_start", "]i", "@conditional.outer", nil, "Next conditional start")
set_ts_move("goto_next_start", "]l", "@loop.outer", nil, "Next loop start")
set_ts_move("goto_next_start", "]s", "@scope", "locals", "Next scope")
set_ts_move("goto_next_start", "]z", "@fold", "folds", "Next fold")
set_ts_move("goto_next_end", "]F", "@call.outer", nil, "Next function call end")
set_ts_move("goto_next_end", "]M", "@function.outer", nil, "Next method/function def end")
set_ts_move("goto_next_end", "]C", "@class.outer", nil, "Next class end")
set_ts_move("goto_next_end", "]I", "@conditional.outer", nil, "Next conditional end")
set_ts_move("goto_next_end", "]L", "@loop.outer", nil, "Next loop end")
set_ts_move("goto_previous_start", "[f", "@call.outer", nil, "Prev function call start")
set_ts_move("goto_previous_start", "[m", "@function.outer", nil, "Prev method/function def start")
set_ts_move("goto_previous_start", "[c", "@class.outer", nil, "Prev class start")
set_ts_move("goto_previous_start", "[i", "@conditional.outer", nil, "Prev conditional start")
set_ts_move("goto_previous_start", "[l", "@loop.outer", nil, "Prev loop start")
set_ts_move("goto_previous_end", "[F", "@call.outer", nil, "Prev function call end")
set_ts_move("goto_previous_end", "[M", "@function.outer", nil, "Prev method/function def end")
set_ts_move("goto_previous_end", "[C", "@class.outer", nil, "Prev class end")
set_ts_move("goto_previous_end", "[I", "@conditional.outer", nil, "Prev conditional end")
set_ts_move("goto_previous_end", "[L", "@loop.outer", nil, "Prev loop end")

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
