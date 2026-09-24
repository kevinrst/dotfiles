-- load defaults i.e lua_lsp
local nvlsp = require("nvchad.configs.lspconfig")
nvlsp.defaults() 

local util = require("lspconfig.util")

--go
vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.mod", ".git" },
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      staticcheck = true,
      semanticTokens = true,
      analyses = {
        unusedparams = true,
        nilness = true,
        unusedwrite = true,
        ST1000 = false,
      },

    }
  }
})
vim.lsp.enable("gopls")

--rust
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", ".git" },
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      checkOnSave = true, 
      inlayHints = {
        lifetimeElisionHints = {
          enable = true,
          useParameterNames = true,
        },
        parameterHints = true,
        typeHints = true,
      },
      procMacro = {
        enable = true,
      },
      diagnostics = {
        enable = true,
        enableExperimental = true,
      },
    },
  },
})
vim.lsp.enable("rust_analyzer")

--
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.name == "gopls" or client.name == "rust_analyzer" then
      -- Disable formatting if you handle it with null-ls or other formatter
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
      -- Apply NvChad's default on_attach
      nvlsp.on_attach(client, args.buf)
    end
  end,
})
