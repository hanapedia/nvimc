return {
  -- Core dependencies
  { dir = "/plugins/popup.nvim", lazy = false },
  { dir = "/plugins/plenary.nvim", lazy = false },

  -- Autopairs
  {
    dir = "/plugins/nvim-autopairs",
    config = function()
      require("user.autopairs")
    end,
  },

  -- Commenting
  {
    dir = "/plugins/Comment.nvim",
    config = function()
      require("user.comment")
    end,
  },

  -- Devicons
  { dir = "/plugins/nvim-web-devicons" },

  -- Buffer closing
  { dir = "/plugins/vim-bbye" },

  -- colorscheme
  {
    dir = "/plugins/mynord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme mynord")
    end,
  },

  -- Completion
  { dir = "/plugins/nvim-cmp", config = function() require("user.cmp") end },
  { dir = "/plugins/cmp-buffer" },
  { dir = "/plugins/cmp-path" },
  { dir = "/plugins/cmp-cmdline" },
  { dir = "/plugins/cmp_luasnip" },
  { dir = "/plugins/cmp-nvim-lsp" },
  { dir = "/plugins/cmp-nvim-lua" },

  -- Snippets
  { dir = "/plugins/LuaSnip" },
  { dir = "/plugins/friendly-snippets" },

  -- LSP
  {
    dir = "/plugins/nvim-lspconfig",
    config = function()
      require("user.lsp")
    end,
  },

  -- trouble.nvim
  {
    dir = "/plugins/trouble.nvim",
    dependencies = { dir = "/plugins/nvim-web-devicons" },
    config = function()
      require("user.trouble")
    end,
  },

  -- Telescope
  {
    dir = "/plugins/telescope.nvim",
    dependencies = { dir = "/plugins/plenary.nvim" },
    config = function()
      require("user.telescope")
    end,
  },

  { dir = "/plugins/nvim-ts-context-commentstring" },
  {
    dir = "/plugins/nvim-treesitter-context",
    config = function()
      require("user.treesitter")
    end,
  },

  -- Git signs
  {
    dir = "/plugins/gitsigns.nvim",
    config = function()
      require("user.gitsigns")
    end,
  },

  -- UI
  {
    dir = "/plugins/lualine.nvim",
    config = function()
      require("user.lualine")
    end,
  },
  {
    dir = "/plugins/nvim-tree.lua",
    lazy = false,
    config = function()
      require("user.nvim-tree")
    end,
  },
  {
    dir = "/plugins/bufferline.nvim",
    config = function()
      require("user.bufferline")
    end,
  },
  {
    dir = "/plugins/claudecode.nvim",
    dependencies = { dir = "/plugins/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
}
