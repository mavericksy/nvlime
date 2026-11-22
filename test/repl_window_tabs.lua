-- Regression test: with a REPL window in several tabs, opening the REPL must
-- reuse the window in the current tab instead of opening a redundant split.
-- Run: nvim --headless -u NONE -l test/repl_window_tabs.lua   (needs parsley in the runtimepath)
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(vim.env.PARSLEY_DIR or vim.fn.expand("~/.local/share/nvim/lazy/parsley"))
vim.opt.rtp:prepend(root)
local main = require("nvlime.window.main")

local buf = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_name(buf, "nvlime://repl-test")

local function wins_showing_buf()
  local n = 0
  for _, id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(id) == buf then n = n + 1 end
  end
  return n
end

main.repl:open(buf, true)
local first_tab = vim.api.nvim_get_current_tabpage()
vim.cmd("tabnew")
main.repl:open(buf, true)
vim.api.nvim_set_current_tabpage(first_tab)
main.repl:open(buf, true)

local n = wins_showing_buf()
if n ~= 1 then
  print("FAIL: " .. n .. " windows show the REPL buffer in the first tab, expected 1")
  vim.cmd("cquit 1")
end
print("ok   REPL window reused in the first tab")
vim.cmd("quit")
