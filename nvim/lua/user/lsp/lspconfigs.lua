local lsp = require("user.lsp.handlers")

vim.lsp.config("gopls", {
  on_attach = lsp.on_attach,
  capabilities = lsp.capabilities,
  -- Fall back to the file's directory if no go.mod/go.work/.git is found,
  -- so gopls always attaches in the container regardless of project structure.
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(
      vim.fs.root(fname, "go.work") or
      vim.fs.root(fname, "go.mod") or
      vim.fs.root(fname, ".git") or
      vim.fs.dirname(fname)
    )
  end,
})

vim.lsp.config("clangd", {
  on_attach = lsp.on_attach,
  capabilities = lsp.capabilities,
  workspace_required = false,
})

vim.lsp.config("lua_ls", {
  on_attach = lsp.on_attach,
  capabilities = lsp.capabilities,
  workspace_required = false,
})

vim.lsp.config("zls", {
  on_attach = lsp.on_attach,
  capabilities = lsp.capabilities,
  settings = {
    zls = {
      enable_build_on_save = false,
    },
  },
})

vim.lsp.enable({ "gopls", "clangd", "lua_ls", "zls" })
