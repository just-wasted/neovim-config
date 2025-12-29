-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
vim.keymap.del("n", "gO")

vim.keymap.set("n", "<leader>o", "o<Esc>", { desc = "Empty line below" })
vim.keymap.set("n", "<leader>O", "O<Esc>", { desc = "Empty line above" })
vim.keymap.set("n", "<leader>n", ":Neotree<CR>", { desc = "[N]eotree" })
vim.keymap.set("n", "<leader>T", ":tabnew<CR>", { desc = "New [T]ab" })
vim.keymap.set("n", "<leader>st", ":TodoQuickFix<CR>", { desc = "[T]odo-comments in [Q]ickfix List" })
vim.keymap.set("n", "<leader>tc", ":TSContext toggle<CR>", { desc = "Function [C]ontext" })
-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>qq", vim.diagnostic.setqflist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>qc", ":cclose<CR>", { desc = "[C]lose Quickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "j", function()
	return vim.v.count > 0 and "j" or "gj"
end, { expr = true })

vim.keymap.set("n", "k", function()
	return vim.v.count > 0 and "k" or "gk"
end, { expr = true })

vim.keymap.set("n", "<leader>u", ":UndotreeToggle<CR>", { desc = "Undotree" })
vim.keymap.set("n", "gb", ":bNext<CR>", { desc = "[G]o to next [B]uffer" })

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show [E]rror Message" })
