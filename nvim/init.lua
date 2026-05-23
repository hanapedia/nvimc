-- Use lazy.nvim from the bundled plugins directory
vim.opt.rtp:prepend("/plugins/lazy.nvim")

-- load essentials
require "user.options"
require "user.keymaps"
require "user.ide-keymaps"

-- Setup lazy.nvim with profiling enabled
require("lazy").setup({
  spec = {
    import = "plugins", -- your plugin directory
  },
  profiling = {
    loader = true,   -- profile plugin loading
    require = true,  -- profile `require()` calls
  },
})
