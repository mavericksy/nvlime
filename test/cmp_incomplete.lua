-- Regression test: the nvlime cmp source must report isIncomplete, so nvim-cmp
-- queries again on every keystroke (e.g. after typing the colon in "ql:qui").
-- Run: nvim --headless -u NONE -l test/cmp_incomplete.lua   (needs parsley and nvim-cmp in the runtimepath)
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(vim.env.PARSLEY_DIR or vim.fn.expand("~/.local/share/nvim/lazy/parsley"))
vim.opt.rtp:prepend(vim.env.CMP_DIR or vim.fn.expand("~/.local/share/nvim/lazy/nvim-cmp"))
vim.opt.rtp:prepend(root)

-- Stand-ins for the Swank-backed completion functions (fuzzy item: {name, _, _, flags}).
vim.fn["nvlime#cmp#get_simple"] = function(_, cb) cb({ "ql:quickload" }) end
vim.fn["nvlime#cmp#get_fuzzy"] = function(_, cb) cb({ { "ql:quickload", 0, 0, "f" } }) end

local source = require("nvlime.cmp")
local response
source:complete({ offset = 2, context = { cursor_before_line = "(ql:qui" } }, function(r) response = r end)
vim.wait(100, function() return response ~= nil end)

local ok = response ~= nil and response.isIncomplete == true
  and #response.items == 1 and response.items[1].label == "ql:quickload"
print((ok and "ok   " or "FAIL ") .. "completion reports isIncomplete with items")
vim.cmd(ok and "quit" or "cquit 1")
