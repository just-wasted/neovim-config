--- Startup times for process: Primary (or UI client) ---

times in msec
 clock   self+sourced   self:  sourced script
 clock   elapsed:              other lines

000.000  000.000: --- NVIM STARTING ---
000.072  000.072: event init
000.118  000.046: early init
000.138  000.019: locale set
000.157  000.019: init first window
000.359  000.202: inits 1
000.364  000.005: window checked
000.366  000.002: parsing arguments
000.666  000.025  000.025: require('vim._core.shared')
000.705  000.003  000.003: require('string.buffer')
000.721  000.027  000.024: require('vim.inspect')
000.748  000.023  000.023: require('vim._core.options')
000.750  000.082  000.032: require('vim._core.editor')
000.767  000.017  000.017: require('vim._core.system')
000.768  000.143  000.019: require('vim._init_packages')
000.769  000.261: init lua interpreter
001.203  000.434: nvim_ui_attach
001.357  000.153: nvim_set_client_info
001.358  000.001: --- NVIM STARTED ---

--- Startup times for process: Embedded ---

times in msec
 clock   self+sourced   self:  sourced script
 clock   elapsed:              other lines

000.000  000.000: --- NVIM STARTING ---
000.048  000.048: event init
000.081  000.033: early init
000.095  000.014: locale set
000.108  000.013: init first window
000.284  000.176: inits 1
000.290  000.006: window checked
000.292  000.001: parsing arguments
000.602  000.026  000.026: require('vim._core.shared')
000.643  000.003  000.003: require('string.buffer')
000.658  000.027  000.024: require('vim.inspect')
000.686  000.023  000.023: require('vim._core.options')
000.687  000.083  000.033: require('vim._core.editor')
000.704  000.016  000.016: require('vim._core.system')
000.705  000.141  000.016: require('vim._init_packages')
000.706  000.273: init lua interpreter
000.741  000.036: expanding arguments
000.750  000.008: inits 2
000.907  000.157: init highlight
000.907  000.000: waiting for UI
000.972  000.065: done waiting for UI
000.977  000.005: clear screen
001.055  000.007  000.007: require('vim.keymap')
001.479  000.073  000.073: sourcing nvim_exec2()
001.495  000.003  000.003: require('vim._core.log')
001.739  000.761  000.678: require('vim._core.defaults')
001.740  000.002: init default mappings & autocommands
001.926  000.030  000.030: sourcing /usr/share/nvim/runtime/ftplugin.vim
001.948  000.011  000.011: sourcing /usr/share/nvim/runtime/indent.vim
002.011  000.048  000.048: sourcing /usr/share/nvim/archlinux.lua
002.012  000.056  000.008: sourcing /etc/xdg/nvim/sysinit.vim
002.120  000.013  000.013: require('vim.fs')
002.303  000.181  000.181: require('vim.uri')
002.311  000.215  000.021: require('vim.loader')
002.405  000.016  000.016: require('vim._core.ui2')
002.528  000.118  000.118: require('vim._core.ui2.cmdline')
002.586  000.057  000.057: require('vim._core.ui2.messages')
003.039  000.007  000.007: require('vim.F')
003.137  000.221  000.215: require('vim.diagnostic')
003.206  000.885  000.473: require('settings')
003.245  000.038  000.038: require('diagnostics')
003.535  000.102  000.102: sourcing /usr/share/nvim/runtime/pack/dist/opt/nvim.undotree/plugin/undotree.lua
003.554  000.227  000.125: sourcing nvim_exec2() called at /home/wasted/.config/nvim/init.lua:0
003.673  000.034  000.034: sourcing /usr/share/nvim/runtime/pack/dist/opt/nvim.difftool/plugin/difftool.lua
003.688  000.131  000.098: sourcing nvim_exec2() called at /home/wasted/.config/nvim/init.lua:0
003.828  000.054  000.054: require('vim._async')
003.833  000.145  000.090: require('vim.pack')
005.179  000.024  000.024: require('tokyonight.config')
005.182  000.556  000.531: require('tokyonight')
005.357  000.035  000.035: require('tokyonight.theme')
005.507  000.043  000.043: require('tokyonight.util')
005.509  000.081  000.038: require('tokyonight.colors')
005.694  000.062  000.062: require('tokyonight.hsluv')
005.864  000.040  000.040: require('tokyonight.groups')
007.062  001.797  001.579: sourcing /home/wasted/.local/share/nvim/site/pack/core/opt/tokyonight.nvim/colors/tokyonight-moon.lua
007.073  002.481  000.128: require('colors/tokyonight')
007.771  000.698  000.698: require('mini.icons')
007.929  000.062  000.062: require('mini.statusline')
008.058  000.108  000.108: require('mini.map')
008.098  000.033  000.033: sourcing nvim_exec2() called at /home/wasted/.config/nvim/init.lua:0
008.209  000.025  000.025: require('which-key')
008.266  000.054  000.054: require('which-key.config')
008.651  000.199  000.199: require('nvim-treesitter')
008.722  000.032  000.032: require('nvim-treesitter.async')
008.745  000.022  000.022: require('nvim-treesitter.config')
008.829  000.082  000.082: require('nvim-treesitter.log')
009.261  000.431  000.431: require('nvim-treesitter.parsers')
009.283  000.021  000.021: require('nvim-treesitter.util')
009.290  000.638  000.049: require('nvim-treesitter.install')
009.788  000.495  000.495: require('nvim-treesitter.parsers')
010.031  001.733  000.401: require('treesitter')
010.431  000.250  000.250: require('vim.lsp.protocol')
010.445  000.305  000.055: require('vim.lsp.log')
010.536  000.089  000.089: require('vim.lsp.util')
010.583  000.018  000.018: require('vim.lsp.sync')
010.585  000.048  000.030: require('vim.lsp._changetracking')
010.630  000.019  000.019: require('vim.lsp._transport')
010.633  000.003  000.003: require('vim._core.stringbuffer')
010.647  000.061  000.040: require('vim.lsp.rpc')
010.686  000.614  000.110: require('vim.lsp')
010.766  000.046  000.046: require('vim.lsp.completion')
010.790  000.102  000.056: require('vim.lsp.handlers')
010.843  000.052  000.052: require('mini.notify')
010.962  000.929  000.160: require('tweak/notify')
011.016  000.015  000.015: require('mason-core.path')
011.172  000.012  000.012: require('mason-core.functional.data')
011.190  000.016  000.016: require('mason-core.functional.function')
011.229  000.026  000.026: require('mason-core.functional.list')
011.259  000.017  000.017: require('mason-core.functional.relation')
011.275  000.015  000.015: require('mason-core.functional.logic')
011.290  000.014  000.014: require('mason-core.functional.number')
011.316  000.024  000.024: require('mason-core.functional.string')
011.336  000.018  000.018: require('mason-core.functional.table')
011.351  000.013  000.013: require('mason-core.functional.type')
011.353  000.212  000.058: require('mason-core.functional')
011.370  000.353  000.141: require('mason-core.platform')
011.409  000.038  000.038: require('mason.settings')
011.411  000.428  000.022: require('mason-core.installer.InstallLocation')
011.487  000.040  000.040: require('mason-core.log')
011.488  000.054  000.015: require('mason-core.EventEmitter')
011.520  000.031  000.031: require('mason-registry.sources')
011.553  000.141  000.056: require('mason-registry')
011.554  000.592  000.022: require('mason')
011.611  000.039  000.039: require('mason.api.command')
011.721  000.107  000.107: require('mini.diff')
012.073  000.190  000.190: require('mini.extra')
012.290  000.215  000.215: require('mini.ai')
012.479  000.103  000.103: require('mini.indentscope')
012.648  000.086  000.086: require('mini.hipatterns')
012.711  000.061  000.061: require('vim.iter')
012.779  000.249  000.102: require('tweak/hipatterns')
013.236  000.456  000.456: require('lsp')
013.771  000.534  000.534: require('mini.surround')
015.445  000.179  000.179: require('mini.pick')
015.524  000.031  000.031: require('vim.ui')
015.526  000.289  000.079: require('tweak/minipick')
015.590  000.049  000.049: require('mini.pairs')
015.838  000.311  000.262: require('tweak/minipairs')
016.254  000.033  000.033: require('blink.lib.lazy_require')
016.258  000.120  000.087: require('blink.lib')
016.313  000.041  000.041: require('blink.lib.log')
016.406  000.147  000.105: require('blink.cmp.logger')
016.513  000.067  000.067: require('blink.lib.config')
016.578  000.064  000.064: require('blink.cmp.config.keymap')
016.638  000.034  000.034: require('blink.cmp.config.completion.keyword')
016.675  000.037  000.037: require('blink.cmp.config.completion.trigger')
016.726  000.050  000.050: require('blink.cmp.config.completion.list')
016.762  000.036  000.036: require('blink.cmp.config.completion.accept')
016.812  000.049  000.049: require('blink.cmp.config.completion.menu')
016.867  000.054  000.054: require('blink.cmp.config.completion.documentation')
016.885  000.018  000.018: require('blink.cmp.config.completion.ghost_text')
016.886  000.304  000.027: require('blink.cmp.config.completion')
016.927  000.040  000.040: require('blink.cmp.config.fuzzy')
016.961  000.033  000.033: require('blink.cmp.config.sources')
017.008  000.046  000.046: require('blink.cmp.config.signature')
017.063  000.054  000.054: require('blink.cmp.config.snippets')
017.089  000.025  000.025: require('blink.cmp.config.appearance')
017.350  000.942  000.309: require('blink.cmp.config')
017.438  000.052  000.052: require('blink.lib.native')
017.483  000.044  000.044: require('blink.lib.task')
017.484  000.133  000.037: require('blink.lib.native.managed')
017.537  001.479  000.137: require('blink.cmp')
017.623  000.029  000.029: require('blink.lib._.tbl')
017.681  000.037  000.037: require('blink.lib._.tbl.copy')
017.711  000.028  000.028: require('blink.lib._.tbl.omit')
018.078  000.040  000.040: require('blink.lib._.tbl.pick')
018.505  000.065  000.065: require('blink.lib.nvim')
018.584  000.033  000.033: require('blink.cmp.fuzzy.lua.match')
018.607  000.023  000.023: require('blink.cmp.fuzzy.lua.match_indices')
018.674  000.046  000.046: require('blink.cmp.fuzzy.lua.char')
018.679  000.071  000.025: require('blink.cmp.fuzzy.lua.keyword')
018.687  000.181  000.054: require('blink.cmp.fuzzy.lua')
018.690  000.300  000.055: require('blink.cmp.fuzzy')
018.943  000.252  000.252: require('blink.cmp.fuzzy.rust')
018.986  000.041  000.041: require('blink.cmp.highlights')
019.034  000.031  000.031: require('blink.cmp.types')
019.229  000.032  000.032: require('blink.cmp.keymap.utils')
019.231  000.058  000.026: require('blink.cmp.keymap.fallback')
019.233  000.092  000.034: require('blink.cmp.keymap.apply')
019.284  000.050  000.050: require('blink.cmp.keymap.presets')
019.286  000.182  000.040: require('blink.cmp.keymap')
019.419  000.035  000.035: require('blink.cmp.completion')
019.620  000.158  000.158: require('blink.cmp.completion.trigger.context')
019.680  000.060  000.060: require('blink.cmp.lib.utils')
019.735  000.054  000.054: require('blink.cmp.lib.event_emitter')
019.740  000.320  000.049: require('blink.cmp.completion.trigger')
019.828  000.087  000.087: require('blink.cmp.lib.buffer_events')
020.036  000.176  000.176: require('blink.cmp.completion.list')
020.153  000.096  000.096: require('blink.cmp.lib.cmdline_events')
020.256  000.055  000.055: require('blink.cmp.lib.term_events')
020.362  000.093  000.093: require('blink.cmp.sources.lib')
020.426  000.015  000.015: require('blink.cmp.completion.windows.menu.auto_wrap')
020.466  000.012  000.012: require('blink.cmp.lib.window.utils')
020.468  000.042  000.030: require('blink.cmp.lib.window')
020.492  000.014  000.014: require('blink.cmp.lib.window.cursor_line')
020.515  000.021  000.021: require('blink.cmp.lib.window.scrollbar')
020.532  000.015  000.015: require('blink.cmp.lib.window.scrollbar.win')
020.550  000.016  000.016: require('blink.lib.timer')
020.556  000.189  000.066: require('blink.cmp.completion.windows.menu')
020.572  000.014  000.014: require('blink.cmp.signature')
020.598  000.019  000.019: require('blink.cmp.signature.trigger')
020.661  000.039  000.039: require('blink.cmp.signature.window')
020.732  004.892  001.352: require('tweak.blinkcmp')
020.759  000.026  000.026: require('mini.cursorword')
020.929  000.106  000.106: require('mini.files')
021.002  000.038  000.038: sourcing nvim_exec2() called at /home/wasted/.config/nvim/init.lua:0
021.006  000.002  000.002: sourcing nvim_exec2() called at /home/wasted/.config/nvim/init.lua:0
021.030  000.231  000.085: require('tweak/minifiles')
021.113  000.083  000.083: require('mini.jump2d')
021.154  017.908  002.963: require('plugins')
021.194  000.040  000.040: require('autocmd')
021.195  019.166  000.079: sourcing /home/wasted/.config/nvim/init.lua
021.199  000.195: sourcing vimrc file(s)
021.345  000.009  000.009: sourcing /usr/share/vim/vimfiles/ftdetect/PKGBUILD.vim
021.354  000.005  000.005: sourcing /usr/share/vim/vimfiles/ftdetect/SRCINFO.vim
021.356  000.090  000.076: sourcing nvim_exec2() called at /usr/share/nvim/runtime/filetype.lua:0
021.357  000.113  000.023: sourcing /usr/share/nvim/runtime/filetype.lua
021.453  000.040  000.040: sourcing /usr/share/nvim/runtime/syntax/synload.vim
021.500  000.122  000.081: sourcing /usr/share/nvim/runtime/syntax/syntax.vim
021.717  000.113  000.113: sourcing /home/wasted/.local/share/nvim/site/pack/core/opt/blink.cmp/plugin/blink-cmp.lua
021.883  000.020  000.020: require('vim.treesitter.language')
021.894  000.010  000.010: require('vim.func')
021.909  000.014  000.014: require('vim.treesitter._range')
021.924  000.013  000.013: require('vim.func._memoize')
021.947  000.110  000.053: require('vim.treesitter.query')
021.954  000.146  000.036: require('vim.treesitter.languagetree')
021.958  000.175  000.028: require('vim.treesitter')
022.009  000.250  000.075: sourcing /home/wasted/.local/share/nvim/site/pack/core/opt/nvim-treesitter/plugin/filetypes.lua
022.042  000.025  000.025: sourcing /home/wasted/.local/share/nvim/site/pack/core/opt/nvim-treesitter/plugin/nvim-treesitter.lua
022.060  000.012  000.012: sourcing /home/wasted/.local/share/nvim/site/pack/core/opt/nvim-treesitter/plugin/query_predicates.lua
022.110  000.020  000.020: sourcing /home/wasted/.local/share/nvim/site/pack/core/opt/which-key.nvim/plugin/which-key.lua
022.155  000.021  000.021: sourcing /home/wasted/.local/share/nvim/site/pack/core/opt/nvim-lspconfig/plugin/lspconfig.lua
022.341  000.083  000.083: sourcing /usr/share/nvim/runtime/plugin/gzip.vim
022.566  000.088  000.088: sourcing /usr/share/nvim/runtime/pack/dist/opt/matchit/plugin/matchit.vim
022.586  000.241  000.153: sourcing /usr/share/nvim/runtime/plugin/matchit.vim
022.648  000.058  000.058: sourcing /usr/share/nvim/runtime/plugin/matchparen.vim
022.656  000.004  000.004: sourcing /usr/share/nvim/runtime/plugin/netrwPlugin.vim
022.723  000.063  000.063: sourcing /usr/share/nvim/runtime/plugin/rplugin.vim
022.732  000.004  000.004: sourcing /usr/share/nvim/runtime/plugin/tarPlugin.vim
022.743  000.007  000.007: sourcing /usr/share/nvim/runtime/plugin/tutor.vim
022.752  000.005  000.005: sourcing /usr/share/nvim/runtime/plugin/zipPlugin.vim
022.778  000.021  000.021: sourcing /usr/share/nvim/runtime/plugin/editorconfig.lua
022.800  000.017  000.017: sourcing /usr/share/nvim/runtime/plugin/man.lua
022.841  000.037  000.037: sourcing /usr/share/nvim/runtime/plugin/net.lua
022.888  000.042  000.042: sourcing /usr/share/nvim/runtime/plugin/osc52.lua
022.936  000.044  000.044: sourcing /usr/share/nvim/runtime/plugin/shada.lua
022.985  000.037  000.037: sourcing /usr/share/nvim/runtime/plugin/spellfile.lua
023.021  000.010  000.010: sourcing /usr/share/nvim/runtime/pack/dist/opt/nvim.difftool/plugin/difftool.lua
023.049  000.009  000.009: sourcing /usr/share/nvim/runtime/pack/dist/opt/nvim.undotree/plugin/undotree.lua
023.322  000.253  000.253: sourcing /usr/share/vim/vimfiles/plugin/fzf.vim
023.323  000.515: loading rtp plugins
023.377  000.054: loading packages
023.380  000.003: loading after plugins
023.386  000.006: inits 3
024.619  001.233: reading ShaDa
024.665  000.046: opening buffers
024.680  000.015: BufEnter autocommands
024.681  000.001: editing files in windows
025.522  000.011  000.011: sourcing nvim_exec2() called at FileType Autocommands for "*":0
025.926  000.012  000.012: sourcing nvim_exec2() called at VimEnter Autocommands for "*":0
025.931  000.003  000.003: sourcing nvim_exec2() called at VimEnter Autocommands for "*":0
026.051  001.343: VimEnter autocommands
026.065  000.015: UIEnter autocommands
026.067  000.001: before starting main loop
026.268  000.202: first screen update
026.269  000.001: --- NVIM STARTED ---

