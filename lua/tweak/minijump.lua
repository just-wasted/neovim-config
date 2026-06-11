require('mini.jump').setup({
  mappings = {
    forward = '',
    backward = '',
    forward_till = '',
    backward_till = '',
    repeat_jump = ';',
  },
  delay = {
    highlight = 10,
    idle_stop = 10000000,
  },
})

vim.keymap.set("n", "s", function ()
  local char_first = vim.fn.getchar(-1, {number = false})
  local char_second = vim.fn.getchar(-1, {number = false})
  vim.cmd("normal! m'" )
  MiniJump.jump(char_first .. char_second, false, false, 1)
end)
vim.keymap.set("n", "S", function ()
  local char_first = vim.fn.getchar(-1, {number = false})
  local char_second = vim.fn.getchar(-1, {number = false})
  vim.cmd("normal! m'" )
  MiniJump.jump(char_first .. char_second, true, false, 1)
end)
vim.api.nvim_set_hl(0, "MiniJump", { fg = "#ffffff", bg = "#28827c" })
