-- lua/k8s_schema_picker/init.lua
local M = {}

-- Kubernetes schema versions (you can expand this list)
M.k8s_schemas = {
  ["v1.23"] = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.23.0-standalone-strict/all.json",
  ["v1.24"] = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.24.0-standalone-strict/all.json",
  ["v1.25"] = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.25.0-standalone-strict/all.json",
  ["v1.26"] = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.26.0-standalone-strict/all.json",
  ["v1.27"] = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.27.1-standalone-strict/all.json",
  ["v1.28"] = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.28.0-standalone-strict/all.json",
}

-- Telescope-compatible picker
M.select_schema = function()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Select Kubernetes Schema Version",
    finder = finders.new_table({
      results = vim.tbl_keys(M.k8s_schemas),
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          M.apply_schema(selection[1])  -- selection[1] = version string
        end
      end)
      return true
    end,
  }):find()
end

-- Apply schema to current buffer
M.apply_schema = function(version)
  local schema_url = M.k8s_schemas[version]
  local clients = vim.lsp.get_clients({ bufnr = 0 })

  local yamlls_client = nil
  for _, client in ipairs(clients) do
    if client.name == "yamlls" then
      yamlls_client = client
      break
    end
  end

  if yamlls_client then
    local filename = vim.api.nvim_buf_get_name(0)

    -- Copy existing schemas
    local current_schemas = vim.deepcopy(yamlls_client.config.settings.yaml.schemas or {})

    -- Remove previous Kubernetes schema if any
    for k, v in pairs(current_schemas) do
      if v == "*.yaml" and (k == "kubernetes" or k:match("kubernetes%-json%-schema")) then
        current_schemas[k] = nil
      end
    end

    -- Apply new schema to this file
    current_schemas[schema_url] = filename

    -- Update client config
    yamlls_client.config.settings.yaml.schemas = current_schemas
    yamlls_client.notify("workspace/didChangeConfiguration", {
      settings = yamlls_client.config.settings,
    })

    vim.notify("Applied Kubernetes schema: " .. version, vim.log.levels.INFO)
  else
    vim.notify("YAML LSP (yamlls) is not active for this buffer", vim.log.levels.WARN)
  end
end

return M
