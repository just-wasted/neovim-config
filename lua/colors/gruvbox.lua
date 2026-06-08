vim.g.gruvbox_material_background = "medium"
vim.g.gruvbox_material_foreground = "soft"
vim.g.gruvbox_material_float_style = "blend"
vim.g.gruvbox_material_diagnostic_text_highlight = 1

vim.cmd.colorscheme("gruvbox-material")

vim.api.nvim_set_hl(0, "PmenuMatch", { fg = "#6b94a7"} )
vim.api.nvim_set_hl(0, "Pmenu", { bg = "#383838"} )
vim.api.nvim_set_hl(0, "PmenuExtra", { bg = "#383838"} )
vim.api.nvim_set_hl(0, "PmenuKind", { bg = "#383838"} )
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#52504F"} )
vim.api.nvim_set_hl(0, "PmenuKindSel", { bg = "#52504F"} )
vim.api.nvim_set_hl(0, "PmenuExtraSel", { bg = "#52504F"} )
