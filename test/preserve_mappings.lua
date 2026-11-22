-- Regression test: when no floating window exists, Nvlime's global <C-n> map must
-- run the user's original <C-n> mapping instead of a plain feedkeys fallback.
-- Run: nvim --headless -u NONE -l test/preserve_mappings.lua   (needs parsley in the runtimepath)
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(vim.env.PARSLEY_DIR or vim.fn.expand("~/.local/share/nvim/lazy/parsley"))
vim.opt.rtp:prepend(root)

local failed = false
local function check(name, ok)
  print((ok and "ok   " or "FAIL ") .. name)
  if not ok then failed = true end
end

-- original mappings, defined before Nvlime adds its buffer-local ones
vim.keymap.set("n", "<C-n>", function() vim.g.orig_cn = (vim.g.orig_cn or 0) + 1 end)
vim.keymap.set("n", "<C-p>", ":let g:orig_cp = 1<CR>", { silent = true })

local globals = require("nvlime.keymaps.globals")
globals.add(false, false)

local function press(keys)
  vim.api.nvim_feedkeys(vim.keycode(keys), "mx", false)
end

press("<C-n>")
check("Lua-callback mapping replayed", vim.g.orig_cn == 1)
press("<C-p>")
check("rhs-string mapping replayed", vim.g.orig_cp == 1)

vim.cmd(failed and "cquit 1" or "quit")
