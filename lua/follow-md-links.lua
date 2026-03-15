local fn = vim.fn
local cmd = vim.cmd
local loop = vim.loop
local query = require("vim.treesitter.query")
local treesitter = require("vim.treesitter")

local M = {}

local os_name = loop.os_uname().sysname
local is_windows = os_name == "Windows"
local is_macos = os_name == "Darwin"
local is_linux = os_name == "Linux"

local function get_reference_link_destination(link_label)
  local language_tree = treesitter.get_parser(0)
  local syntax_tree = language_tree:parse()
  local root = syntax_tree[1]:root()
  local parse_query = query.parse("markdown", [[
    (link_reference_definition
      (link_label) @label (#eq? @label "]] .. link_label .. [[")
      (link_destination) @link_destination)
  ]])

  for _, captures, _ in parse_query:iter_matches(root, 0) do
    local node_text = treesitter.get_node_text(captures[2], 0)
    return string.gsub(node_text, "[<>]", "")
  end
end

local function get_cursor_node()
  local ok, node = pcall(treesitter.get_node, { bufnr = 0, ignore_injections = false })
  if not ok then
    return nil
  end

  while node do
    local node_type = node:type()
    if node_type == "link_destination"
      or node_type == "link_text"
      or node_type == "link_reference_definition"
      or node_type == "inline_link"
      or node_type == "full_reference_link"
      or node_type == "link_label"
    then
      return node
    end

    node = node:parent()
  end
end

local function get_link_destination()
  local node_at_cursor = get_cursor_node()
  if not node_at_cursor then
    return
  end

  if node_at_cursor:type() == "link_destination" then
    return vim.split(treesitter.get_node_text(node_at_cursor, 0), "\n")[1]
  elseif node_at_cursor:type() == "link_text" then
    local next_node = node_at_cursor:next_named_sibling()
    if not next_node then
      return
    end

    if next_node:type() == "link_destination" then
      return vim.split(treesitter.get_node_text(next_node, 0), "\n")[1]
    elseif next_node:type() == "link_label" then
      local link_label = vim.split(treesitter.get_node_text(next_node, 0), "\n")[1]
      return get_reference_link_destination(link_label)
    end
  elseif node_at_cursor:type() == "link_reference_definition" or node_at_cursor:type() == "inline_link" then
    for _, node in ipairs(node_at_cursor:named_children()) do
      if node:type() == "link_destination" then
        return vim.split(treesitter.get_node_text(node, 0), "\n")[1]
      end
    end
  elseif node_at_cursor:type() == "full_reference_link" then
    for _, node in ipairs(node_at_cursor:named_children()) do
      if node:type() == "link_label" then
        local link_label = vim.split(treesitter.get_node_text(node, 0), "\n")[1]
        return get_reference_link_destination(link_label)
      end
    end
  elseif node_at_cursor:type() == "link_label" then
    local link_label = vim.split(treesitter.get_node_text(node_at_cursor, 0), "\n")[1]
    return get_reference_link_destination(link_label)
  end
end

local function resolve_link(link)
  local link_type
  if link:sub(1, 1) == [[/]] then
    link_type = "local"
    return link, link_type
  elseif link:sub(1, 1) == [[~]] then
    link_type = "local"
    return os.getenv("HOME") .. [[/]] .. link:sub(2), link_type
  elseif link:sub(1, 8) == [[https://]] or link:sub(1, 7) == [[http://]] then
    link_type = "web"
    return link, link_type
  else
    link_type = "local"
    return fn.expand("%:p:h") .. [[/]] .. link, link_type
  end
end

local function follow_local_link(link)
  local resolved_link = link
  local fd = loop.fs_open(resolved_link, "r", 438)
  if not fd then
    fd = loop.fs_open(resolved_link .. ".md", "r", 438)
    if fd then
      resolved_link = resolved_link .. ".md"
    end
  end

  if fd then
    local stat = loop.fs_fstat(fd)
    if stat and stat.type == "file" and loop.fs_access(resolved_link, "R") then
      cmd(string.format("%s %s", "e", fn.fnameescape(resolved_link)))
    end
    loop.fs_close(fd)
  end
end

function M.follow_link()
  local link_destination = get_link_destination()

  if link_destination then
    local resolved_link, link_type = resolve_link(link_destination)
    if link_type == "local" then
      follow_local_link(resolved_link)
    elseif link_type == "web" then
      if is_linux then
        vim.fn.system("xdg-open " .. vim.fn.shellescape(resolved_link))
      elseif is_macos then
        vim.fn.system("open " .. vim.fn.shellescape(resolved_link))
      elseif is_windows then
        vim.fn.system('cmd.exe /c start "" ' .. vim.fn.shellescape(resolved_link))
      end
    end
  end
end

return M
