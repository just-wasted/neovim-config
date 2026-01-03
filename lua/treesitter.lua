return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		branch = "main",
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")

			-- Track buffers currently waiting for parser installation
			local pending_buffers = {}

			-- Helper to start treesitter with retry for async parser installation
			local function start_with_retry(buf, lang, attempts)
				attempts = attempts or 10

				-- Use "buffer:language" as key to handle buffer number reuse
				local pending_key = buf .. ":" .. lang

				if not vim.api.nvim_buf_is_valid(buf) then
					pending_buffers[pending_key] = nil -- Cleanup
					return
				end

				-- Prevent duplicate retry loops for the same buffer+language
				if pending_buffers[pending_key] then
					return
				end

				local ok = pcall(vim.treesitter.start, buf, lang)
				if ok and vim.api.nvim_buf_is_valid(buf) then
					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					pending_buffers[pending_key] = nil -- Success - clear tracking
				elseif attempts > 0 then
					pending_buffers[pending_key] = true -- Mark as pending
					vim.defer_fn(function()
						-- Don't clear pending_key here - let recursive call handle it
						start_with_retry(buf, lang, attempts - 1)
					end, 500)
				else
					pending_buffers[pending_key] = nil -- Max retries reached - clear tracking
				end
			end

			-- Install core parsers after lazy.nvim finishes loading all plugins
			vim.api.nvim_create_autocmd("User", {
				pattern = "LazyDone",
				once = true,
				callback = function()
					ts.install({
						"bash",
						"c",
						"cmake",
						"comment",
						"cpp",
						"css",
						"diff",
						"git_config",
						"git_rebase",
						"gitcommit",
						"gitignore",
						"gitignore",
						"html",
						"ini",
						"javascript",
						"json",
						"lua",
						"luadoc",
						"make",
						"markdown",
						"markdown_inline",
						"python",
						"query",
						"regex",
						"rust",
						"tmux",
						"toml",
						"vim",
						"vimdoc",
						"xml",
						"yaml",
						"zig",
						"zsh",
					}, {
						max_jobs = 8,
					})
				end,
			})

			local group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true })

			local ignore_filetypes = {
				"checkhealth",
				"lazy",
				"mason",
				"fidget",
				"TelescopeResults",
				"TelescopePrompt",
				"blink-cmp-menu",
				"neo-tree",
				"gitsigns-blame",
				"undotree",
				"qf",
			}

			-- Auto-install parsers and enable highlighting on FileType
			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				desc = "Enable treesitter highlighting and indentation",
				callback = function(event)
					if vim.tbl_contains(ignore_filetypes, event.match) then
						return
					end

					local lang = vim.treesitter.language.get_lang(event.match) or event.match
					local buf = event.buf

					-- Try to start treesitter, with retry if parser is being installed
					start_with_retry(buf, lang)

					-- Auto-install missing parsers (nvim-treesitter handles async internally)
					ts.install({ lang })
				end,
			})

			-- Clean up pending retries when buffer is deleted
			vim.api.nvim_create_autocmd("BufDelete", {
				group = group,
				callback = function(event)
					for key in pairs(pending_buffers) do
						if key:match("^" .. event.buf .. ":") then
							pending_buffers[key] = nil
						end
					end
				end,
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		event = "VeryLazy",

		branch = "main",

		keys = {
			{
				"[f",
				function()
					require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
				end,
				desc = "prev function",
				mode = { "n", "x", "o" },
			},
			{
				"]f",
				function()
					require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
				end,
				desc = "next function",
				mode = { "n", "x", "o" },
			},
			{
				"[F",
				function()
					require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
				end,
				desc = "prev function end",
				mode = { "n", "x", "o" },
			},
			{
				"]F",
				function()
					require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
				end,
				desc = "next function end",
				mode = { "n", "x", "o" },
			},
			{
				"[a",
				function()
					require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.outer", "textobjects")
				end,
				desc = "prev argument",
				mode = { "n", "x", "o" },
			},
			{
				"]a",
				function()
					require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.outer", "textobjects")
				end,
				desc = "next argument",
				mode = { "n", "x", "o" },
			},
			{
				"[A",
				function()
					require("nvim-treesitter-textobjects.move").goto_previous_end("@parameter.outer", "textobjects")
				end,
				desc = "prev argument end",
				mode = { "n", "x", "o" },
			},
			{
				"]A",
				function()
					require("nvim-treesitter-textobjects.move").goto_next_end("@parameter.outer", "textobjects")
				end,
				desc = "next argument end",
				mode = { "n", "x", "o" },
			},
			{
				"[s",
				function()
					require("nvim-treesitter-textobjects.move").goto_previous_start("@block.outer", "textobjects")
				end,
				desc = "prev block",
				mode = { "n", "x", "o" },
			},
			{
				"]s",
				function()
					require("nvim-treesitter-textobjects.move").goto_next_start("@block.outer", "textobjects")
				end,
				desc = "next block",
				mode = { "n", "x", "o" },
			},
			{
				"[S",
				function()
					require("nvim-treesitter-textobjects.move").goto_previous_end("@block.outer", "textobjects")
				end,
				desc = "prev block",
				mode = { "n", "x", "o" },
			},
			{
				"]S",
				function()
					require("nvim-treesitter-textobjects.move").goto_next_end("@block.outer", "textobjects")
				end,
				desc = "next block",
				mode = { "n", "x", "o" },
			},
			{
				"gap",
				function()
					require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
				end,
				desc = "swap prev argument",
			},
			{
				"gan",
				function()
					require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
				end,
				desc = "swap next argument",
			},
		},

		opts = {
			move = {
				enable = true,
				set_jumps = true,
			},
			swap = {
				enable = true,
			},
		},
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			enable = false,
			max_lines = 4,
			multiline_threshold = 2,
		},
	},
}
-- vim: ts=2 sts=2 sw=2 et
