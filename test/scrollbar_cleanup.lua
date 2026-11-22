-- Regression test: floating-window scrollbars must close with their parent.
-- Run: nvim --headless -u NONE -l test/scrollbar_cleanup.lua   (needs parsley in the runtimepath)
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(vim.env.PARSLEY_DIR or vim.fn.expand("~/.local/share/nvim/lazy/parsley"))
vim.opt.rtp:prepend(root)
local window = require("nvlime.window")

local function scrollbars()
  local n = 0
  for _, id in ipairs(vim.api.nvim_list_wins()) do
    if pcall(vim.api.nvim_win_get_var, id, "nvlime_scrollbar") then n = n + 1 end
  end
  return n
end

local function new_buf()
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = {}
  for i = 1, 100 do lines[i] = "line " .. i end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modified = false
  return buf
end

local opts = { relative = "editor", row = 2, col = 5, width = 30, height = 10 }
local failed = false
local function check(name, setup)
  setup()
  vim.wait(100)
  if scrollbars() ~= 0 then
    failed = true
    print("FAIL " .. name .. ": " .. scrollbars() .. " scrollbar window(s) left")
  else
    print("ok   " .. name)
  end
end

check("nvim_win_close", function()
  local id = window["open-float"](new_buf(), opts, false, false)
  vim.wait(100)
  vim.api.nvim_win_close(id, true)
end)
check("close before deferred scrollbar", function()
  local id = window["open-float"](new_buf(), opts, false, false)
  vim.api.nvim_win_close(id, true)
end)
check("close-float", function()
  local id = window["open-float"](new_buf(), opts, false, true)
  vim.wait(100)
  window["close-float"](id)
end)
check("buffer deleted", function()
  local buf = new_buf()
  window["open-float"](buf, opts, false, false)
  vim.wait(100)
  vim.api.nvim_buf_delete(buf, { force = true })
end)

vim.cmd(failed and "cquit 1" or "quit")
