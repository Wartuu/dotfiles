require("mason").setup()

require("mason-lspconfig").setup({
    ensure_installed = {
      "ts_ls",      -- JavaScript/TypeScript
      "html",          -- HTML
      "cssls",         -- CSS
      "jsonls",        -- JSON
      "yamlls",        -- YAML
      "gopls",         -- Go
      "clangd",        -- C/C++
      "rust_analyzer", -- Rust
      "jdtls",         -- Java
      "eslint",        -- Lint JS/TS
      "marksman",      -- Markdown
    },
    automatic_enable = true,
})

