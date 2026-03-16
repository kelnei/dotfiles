-- Other dark blue themes worth trying:
--   catppuccin/nvim              (style = "mocha")
--   rebelot/kanagawa.nvim        (style = "wave")
--   EdenEast/nightfox.nvim       (colorscheme "nightfox")

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}
