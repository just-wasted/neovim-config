require("tokyonight").setup({
  on_colors = function(colors)
    colors.green = "#A3C86D"
  end
})

vim.cmd.colorscheme("tokyonight-moon")
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#434d86", bold = false })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#434d86", bold = false })
vim.api.nvim_set_hl(0, "Search", { fg = "#fc832d", bg = "#515463" })
vim.cmd.highlight("MiniIndentScopeSymbol guifg=#6181a1")

-- vim: ts=2 sts=2 sw=2 et
