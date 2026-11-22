-- Regression test: a completion item whose flags field is not a string must not
-- raise an error. Swank can send an empty list there for package-qualified input.
-- Run: nvim --headless -u NONE -l test/cmp_flags.lua   (needs parsley and nvim-cmp in the runtimepath)
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(vim.env.PARSLEY_DIR or vim.fn.expand("~/.local/share/nvim/lazy/parsley"))
vim.opt.rtp:prepend(vim.env.CMP_DIR or vim.fn.expand("~/.local/share/nvim/lazy/nvim-cmp"))
vim.opt.rtp:prepend(root)

vim.fn["nvlime#cmp#get_simple"] = function(_, cb) cb({ "ql:quickload" }) end
vim.fn["nvlime#cmp#get_fuzzy"] = function(_, cb)
  cb({ { "ql:quickload", 0, 0, {} }, { "ql:*x*", 0, 0, 0 }, { "ql:ok", 0, 0, "f" } })
end

local response
local ok, err = pcall(function()
  require("nvlime.cmp"):complete({ offset = 1, context = { cursor_before_line = "ql:" } },
    function(r) response = r end)
  vim.wait(100, function() return response ~= nil end)
end)
local items = response and (response.items or response) or {}
local pass = ok and #items == 3 and items[3].kind == require("cmp.types.lsp").CompletionItemKind.Function
print((pass and "ok   " or ("FAIL " .. tostring(err))) .. " non-string flags handled")
vim.cmd(pass and "quit" or "cquit 1")
