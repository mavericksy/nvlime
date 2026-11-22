-- Test: call snippets are off by default and wrap functions in parentheses when
-- g:nvlime_config.cmp.snippets is true.
-- Run: nvim --headless -u NONE -l test/cmp_snippets.lua   (needs parsley and nvim-cmp in the runtimepath)
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(vim.env.PARSLEY_DIR or vim.fn.expand("~/.local/share/nvim/lazy/parsley"))
vim.opt.rtp:prepend(vim.env.CMP_DIR or vim.fn.expand("~/.local/share/nvim/lazy/nvim-cmp"))
vim.opt.rtp:prepend(root)

vim.fn["nvlime#cmp#get_simple"] = function(_, cb) cb({ "car" }) end
vim.fn["nvlime#cmp#get_fuzzy"] = function(_, cb)
  cb({ { "car", 0, 0, "f" }, { "*print-pretty*", 0, 0, "b" } })
end

local function items()
  local response
  require("nvlime.cmp"):complete({ offset = 1, context = { cursor_before_line = "c" } },
    function(r) response = r end)
  vim.wait(100, function() return response ~= nil end)
  return response.items or response
end

local failed = false
local function check(name, ok)
  print((ok and "ok   " or "FAIL ") .. name)
  if not ok then failed = true end
end

local opts = require("nvlime.config")
local plain = items()
check("off by default: no insertText", plain[1].insertText == nil)

opts.cmp.snippets = true
local snip = items()
check("on: function wrapped in parentheses", snip[1].insertText == "(car $0)" and snip[1].insertTextFormat == 2)
check("on: variable left alone", snip[2].insertText == nil)

vim.cmd(failed and "cquit 1" or "quit")
