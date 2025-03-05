-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Turn this off while we give oil.nvim a go
--vim.keymap.set('n', '<leader>x', ':Ex<Enter>', { desc = 'Run network dir listing (:Ex)' })

local function oilFromConfigRoot()
  local myvimrc = os.getenv("MYVIMRC")
  assert(myvimrc, "MYVIMRC is not set in the environment!")
  local config_dir = vim.fn.fnamemodify(myvimrc, ":h")
  return function()
    vim.cmd("Oil " .. config_dir)
  end
end

vim.keymap.set('n', '<leader>x', ':Oil<enter>', { desc = 'run :Oil' })
vim.keymap.set('n', '<leader>z', oilFromConfigRoot(), { desc = 'run :Oil from config directory' })

-- Toggle diagnostics
local diagnostics_active = true

function toggle_diag()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.enable()
    print("Diagnostics enabled")
  else
    vim.diagnostic.disable()
    print("Diagnostics disabled")
  end
end

vim.keymap.set('n', '<leader>td', toggle_diag, { desc = 'Toggle diagnostics' })


local warnings_hidden = false

-- Toggle diagnostic warnings
function toggle_warnings()
  warnings_hidden = not warnings_hidden
  if warnings_hidden then
    -- Hide warnings by setting their severity to nil
    vim.diagnostic.config({
      severity_sort = true,
      virtual_text = {
        severity = { min = vim.diagnostic.severity.ERROR },
      },
      signs = {
        severity = { min = vim.diagnostic.severity.ERROR },
      },
      underline = {
        severity = { min = vim.diagnostic.severity.ERROR },
      },
      float = {
        severity = { min = vim.diagnostic.severity.ERROR },
      },
    })
    print("Warnings hidden")
  else
    -- Show all diagnostics
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      float = true,
    })
    print("Warnings shown")
  end
end

vim.keymap.set('n', '<leader>tw', toggle_warnings, { desc = 'Toggle warnings' })

-- This is defined in the zoxide config
--vim.keymap.set('n', '<leader>cd', require('telescope').extensions.zoxide.list, { desc = 'zoxide list' })


