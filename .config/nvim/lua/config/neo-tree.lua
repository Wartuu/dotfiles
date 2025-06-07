require("neo-tree").setup({
    filesystem = {
        filtered_items = {
            visible = true,
            hide_dotfiles = false,
        }
    }
})

vim.keymap.set('n', '<C-b>', ':Neotree<CR>', {})