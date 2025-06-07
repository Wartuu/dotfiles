require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "html", "css", "javascript", "typescript", "c", "cpp", "rust", "go", "java"
    },
    highlight = {
        enable = true,
    },
    indent = {
        enable = true
    }
})
