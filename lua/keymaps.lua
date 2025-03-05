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


-- Function to toggle ticked state: - [ ] <-> - [x]
local function toggle_ticked()
    local mode = vim.api.nvim_get_mode().mode

    if mode == "n" then  -- Normal mode
        local line = vim.api.nvim_get_current_line()
        if line:match("%- %[%s%]") then
            line = line:gsub("%- %[%s%]", "- [x]", 1)
        elseif line:match("%- %[x%]") then
            line = line:gsub("%- %[x%]", "- [ ]", 1)
        end
        vim.api.nvim_set_current_line(line)

    elseif mode == "v" or mode == "V" then  -- Visual mode (line or character)
        local start_line = vim.fn.line("v")
        local end_line = vim.fn.line(".")
        if start_line > end_line then start_line, end_line = end_line, start_line end
        for i = start_line, end_line do
            local line = vim.fn.getline(i)
            if line:match("%- %[%s%]") then
                line = line:gsub("%- %[%s%]", "- [x]", 1)
            elseif line:match("%- %[x%]") then
                line = line:gsub("%- %[x%]", "- [ ]", 1)
            end
            vim.fn.setline(i, line)
        end
    end
end

-- Function to toggle checkbox: "Task" <-> "- [ ] Task" <-> "Task"
local function toggle_checkbox()
    local mode = vim.api.nvim_get_mode().mode

    if mode == "n" then  -- Normal mode
        local line = vim.api.nvim_get_current_line()
        if line:match("^%- %[%s%] ") then
            line = line:gsub("^%- %[%s%] ", "", 1)
        elseif line:match("^%- ") and not line:match("^%- %[[x ]%]") then
            line = line:gsub("^%- ", "- [ ] ", 1)
        elseif not line:match("^%- %[[x ]%]") then
            line = "- [ ] " .. line
        end
        vim.api.nvim_set_current_line(line)

    elseif mode == "v" or mode == "V" then  -- Visual mode (line or character)
        local start_line = vim.fn.line("v")
        local end_line = vim.fn.line(".")
        if start_line > end_line then start_line, end_line = end_line, start_line end
        for i = start_line, end_line do
            local line = vim.fn.getline(i)
            if line:match("^%- %[%s%] ") then
                line = line:gsub("^%- %[%s%] ", "", 1)
            elseif line:match("^%- ") and not line:match("^%- %[[x ]%]") then
                line = line:gsub("^%- ", "- [ ] ", 1)
            elseif not line:match("^%- %[[x ]%]") then
                line = "- [ ] " .. line
            end
            vim.fn.setline(i, line)
        end
    end
end

-- Function to toggle bullet: "Task" <-> "- Task" and "- [ ] Task" <-> "- Task"
local function toggle_bullet()
    local mode = vim.api.nvim_get_mode().mode

    if mode == "n" then  -- Normal mode
        local line = vim.api.nvim_get_current_line()
        if line:match("^%- %[%s?x?%] ") then
            line = line:gsub("^%- %[%s?x?%] ", "- ", 1)
        elseif line:match("^%- ") then
            line = line:gsub("^%- ", "", 1)
        else
            line = "- " .. line
        end
        vim.api.nvim_set_current_line(line)

    elseif mode == "v" or mode == "V" then  -- Visual mode (line or character)
        local start_line = vim.fn.line("v")
        local end_line = vim.fn.line(".")
        if start_line > end_line then start_line, end_line = end_line, start_line end
        for i = start_line, end_line do
            local line = vim.fn.getline(i)
            if line:match("^%- %[%s?x?%] ") then
                line = line:gsub("^%- %[%s?x?%] ", "- ", 1)
            elseif line:match("^%- ") then
                line = line:gsub("^%- ", "", 1)
            else
                line = "- " .. line
            end
            vim.fn.setline(i, line)
        end
    end
end

-- Keymaps
vim.keymap.set({"n", "v"}, "<leader>tt", toggle_ticked, { noremap = true, silent = true, desc = "Toggle ticked" })
vim.keymap.set({"n", "v"}, "<leader>tc", toggle_checkbox, { noremap = true, silent = true, desc = "Toggle checkbox" })
vim.keymap.set({"n", "v"}, "<leader>tb", toggle_bullet, { noremap = true, silent = true, desc = "Toggle bullet" })

vim.keymap.set("n", "<leader>rc", ":source $MYVIMRC<CR>", { noremap = true, silent = true, desc = "Reload Vim config" })


