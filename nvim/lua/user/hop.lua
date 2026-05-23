-- place this in one of your configuration file(s)
local hop = require('hop')
local hop_setup_opts = {
  -- keys = 'fghjklwertyu',
  -- quit_key = '<Esc>',
  teasing = false,

}
hop.setup(hop_setup_opts)

local directions = require('hop.hint').HintDirection

-- keymaps for extensive f/F and t/T movement
vim.keymap.set({ 'n', 'v' }, 'f', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
end, { remap = true })

vim.keymap.set({ 'n', 'v' }, 'F', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
end, { remap = true })

vim.keymap.set({ 'n', 'v' }, 't', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
end, { remap = true })

vim.keymap.set({ 'n', 'v' }, 'T', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
end, { remap = true })

-- keymaps for one chars search
vim.keymap.set({ 'n', 'v' }, '<leader>j', function()
  hop.hint_char1()
end, { remap = true })

-- keymaps for buffer wide movement
vim.keymap.set({ 'n', 'v' }, 'sw', function()
  hop.hint_words()
end, { remap = true })

vim.keymap.set({ 'n', 'v' }, 'sl', function()
  hop.hint_lines()
end, { remap = true })
