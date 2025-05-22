require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

require('mini.ai').setup()
require('mini.align').setup()
require('mini.surround').setup({
  mappings = {
    add = 'gsa', -- Add surrounding in Normal and Visual modes
    --e.g. gsaiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    --e.g. gsaa}) - [S]urround [A]dd [A]round [}]Braces [)]Paren
    delete = 'gsd', -- Delete surrounding
    --e.g.    gsd"   - [S]urround [D]elete ["]quotes
    replace = 'gsr', -- Replace surrounding
    --e.g.     gsr)'  - [S]urround [R]eplace [)]Paren by [']quote
    find = 'gsf', -- Find surrounding (to the right)
    find_left = 'gsF', -- Find surrounding (to the left)
    highlight = 'gsh', -- Highlight surrounding
    update_n_lines = 'gsn', -- Update `n_lines`
  },
  n_lines = 500,
})
require('mini.operators').setup()
require('mini.move').setup()
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

