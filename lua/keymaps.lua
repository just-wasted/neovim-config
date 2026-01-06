-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
vim.keymap.del("n", "gO")
vim.keymap.del("n", "<c-w>d")
vim.keymap.del("n", "<c-w><c-d>")

for _, key in ipairs({ "n", "N", "*", "#" }) do
	local rhs = key .. "<Cmd>lua MiniMap.refresh({}, {lines = false, scrollbar = false})<CR>"
	vim.keymap.set("n", key, rhs)
end

vim.keymap.set("n", "gh", ": LspClangdSwitchSourceHeader<CR>", { desc = "Goto [H]eader/ Source" })
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste over selection, preserve register" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

vim.keymap.set("v", "gj", ":join<CR>", { desc = "Join selected lines" })

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "<leader>o", "o<Esc>", { desc = "Empty line below" })
vim.keymap.set("n", "<leader>O", "O<Esc>", { desc = "Empty line above" })
vim.keymap.set("n", "<leader>n", ":Neotree toggle<CR>", { desc = "[N]eotree" })
vim.keymap.set("n", "<leader>T", ":tabnew<CR>", { desc = "New [T]ab" })
vim.keymap.set("n", "<leader>st", ":TodoQuickFix<CR>", { desc = "[T]odo-comments in [Q]ickfix List" })
vim.keymap.set("n", "<leader>tc", ":TSContext toggle<CR>", { desc = "Function [C]ontext" })

--  See `:help hlsearch`
-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>:<CR>")

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

require("gitsigns").setup({
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end, { desc = "next [c]hange" })

		map("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end, { desc = "previous [c]hange" })

		-- Actions
		map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "[S]tage hunk" })
		map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "[R]eset hunk" })

		map("v", "<leader>hs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "[S]tage hunk" })

		map("v", "<leader>hr", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "[R]eset hunk" })

		map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "[S]tage buffer" })
		map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "[R]eset buffer" })
		map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "[P]review hunk" })
		map("n", "<leader>hi", gitsigns.preview_hunk_inline, { desc = "[P]review hunk [I]nline" })

		map("n", "<leader>hb", function()
			gitsigns.blame_line({ full = true })
		end, { desc = "[b]lame line" })

		map("n", "<leader>hB", function()
			gitsigns.blame({ full = true })
		end, { desc = "blame [B]uffer" })

		map("n", "<leader>hd", gitsigns.diffthis, { desc = "git [d]iff" })

		map("n", "<leader>hD", function()
			gitsigns.diffthis("~")
		end, { desc = "git [D]iff file" })

		map("n", "<leader>hQ", function()
			gitsigns.setqflist("all")
		end, { desc = "send workspace hunks to [Q]flist" })
		map("n", "<leader>hq", gitsigns.setqflist, { desc = "send buffer hunks to [q]flist" })

		-- Toggles
		map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "[t]oggle line [b]lame" })
		map("n", "<leader>tw", gitsigns.toggle_word_diff, { desc = "[t]oggle [w]ord diff" })

		-- Text object
		map({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "inner hunk" })
	end,
})

-- vim: ts=2 sts=2 sw=2 et
