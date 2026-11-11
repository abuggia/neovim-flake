-- Without a native clipboard tool (a Linux VM, an SSH session), copy through the
-- terminal with OSC 52. iTerm2 accepts OSC 52 writes but never answers reads, and
-- with clipboard=unnamedplus every put reads the clipboard, so each `p` would stall
-- for 10 s. Put the last copy instead; paste from macOS with Cmd-V.
if vim.fn.has("mac") == 1 or os.getenv("DISPLAY") or os.getenv("WAYLAND_DISPLAY") then
  return
end

local osc52 = require("vim.ui.clipboard.osc52")
local last = { { "" }, "v" }

local function copy(reg)
  local send = osc52.copy(reg)
  return function(lines, regtype)
    last = { lines, regtype }
    send(lines)
  end
end

local function paste()
  return last
end

vim.g.clipboard = {
  name = "osc52-copy",
  copy = { ["+"] = copy("+"), ["*"] = copy("*") },
  paste = { ["+"] = paste, ["*"] = paste },
}
