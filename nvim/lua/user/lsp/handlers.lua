local M = {}

-- 1. Capabilities (cmp integration)
M.capabilities = require("cmp_nvim_lsp").default_capabilities()

-- 2. Minimal on_attach
function M.on_attach(client, bufnr)
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
    vim.api.nvim_clear_autocmds { group = "lsp_document_highlight", buffer = bufnr }

    vim.api.nvim_create_autocmd("CursorHold", {
      buffer = bufnr,
      group = "lsp_document_highlight",
      callback = vim.lsp.buf.document_highlight,
      desc = "Document Highlight",
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
      buffer = bufnr,
      group = "lsp_document_highlight",
      callback = vim.lsp.buf.clear_references,
      desc = "Clear All the References",
    })
  end

  local map = function(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
  end

  map("n", "K", vim.lsp.buf.hover)
  --[[ map("n", "gd", vim.lsp.buf.definition) ]]
  --[[ map("n", "gr", vim.lsp.buf.references) ]]
  map("n", "<leader>rn", vim.lsp.buf.rename)
  map("n", "<C-k>", vim.lsp.buf.signature_help)
  map("n", "<leader>s", function()
    vim.lsp.buf.format({ async = true })
  end)
  map("n", "gk", function()
    vim.diagnostic.goto_prev({ border = "rounded" })
  end)
  map("n", "gj", function()
    vim.diagnostic.goto_next({ border = "rounded" })
  end)
end

vim.diagnostic.config({
  virtual_text = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "",
    },
  },
  update_in_insert = true,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
  },
})

return M
