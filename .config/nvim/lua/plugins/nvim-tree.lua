return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
      view = {
        width = 30,
      },
    })

    -- прозрачный фон для самого дерева
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
        vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })
      end,
    })
    vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
    vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })

    vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })
  end,
}
