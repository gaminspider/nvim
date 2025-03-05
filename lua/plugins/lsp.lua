-- LSP
--[[
-- FYI, I had some problems installing pyright. The fix was straightforward:
-- cd ~/.local/share/nvim/mason/packages/pyright/node_modules/.bin
-- rm pyright pyright-langserver
-- ln -s ../pyright/index.js pyright
-- ln -s ../pyright/langserver.index.js pyright-langserver
-- https://neovim.discourse.group/t/install-pyright-in-remote-machine-offline-causing-cannot-find-module-dist-pyright-langserver-error/3471
--]]

return {
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},

	{ "Bilal2453/luvit-meta", lazy = true },

	{
		-- main lsp configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			-- automatically install lsps and related tools to stdpath for neovim
			{ "williamboman/mason.nvim", config = true }, -- note: must be loaded before dependants
			"williamboman/mason-lspconfig.nvim",
			"whoissethdaniel/mason-tool-installer.nvim",

			-- useful status updates for lsp.
			-- note: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ "j-hui/fidget.nvim", opts = {} },

			-- allows extra capabilities provided by nvim-cmp
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			vim.api.nvim_create_autocmd("lspattach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "lsp: " .. desc })
					end

					map("gd", require("telescope.builtin").lsp_definitions, "[g]oto [d]efinition")
					map("gr", require("telescope.builtin").lsp_references, "[g]oto [r]eferences")
					map("gi", require("telescope.builtin").lsp_implementations, "[g]oto [i]mplementation")
					map("<leader>d", require("telescope.builtin").lsp_type_definitions, "type [d]efinition")
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[d]ocument [s]ymbols")
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[w]orkspace [s]ymbols"
					)
					map("<leader>rn", vim.lsp.buf.rename, "[r]e[n]ame")
					map("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ction")
					map("gd", vim.lsp.buf.declaration, "[g]oto [d]eclaration")

					if client and client.supports_method(vim.lsp.protocol.methods.textdocument_inlayhint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[t]oggle inlay [h]ints")
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			local servers = {
				clangd = {
						-- If clangd is installed by Mason, typically it is `clangd` or
						-- the full path to Mason's clangd binary:
						-- e.g., "C:\\Users\\simon\\AppData\\Local\\nvim-data\\mason\\bin\\clangd.EXE"
						-- but usually just "clangd" works if it's on PATH or found by Mason.
						"clangd",
						"--log=verbose",
						-- Tells clangd to parse code as if it's using Microsoft’s cl.exe
						"--driver-mode=cl",
						-- Set the target triple to a 64-bit MSVC environment
						"--target=x86_64-pc-windows-msvc",
						-- Example 1: Force your code to be parsed as C++17, ignoring
						-- any 'cc -std=c11' from the compile_commands.json
						"--extra-arg-before=-xc++",
						"--extra-arg-before=-std=c++17",

						-- Example 2: (Alternatively) emulate MSVC's driver if you want / need it:
						-- "--driver-mode=cl",
						-- "--extra-arg-before=/std:c++17",

						-- Point clangd to the directory that holds compile_commands.json
						"--compile-commands-dir=C:/gd/Simon/Development/cpp/pecan"
				},
				-- gopls = {},
				-- pyright = {},
				-- rust_analyzer = {},
				-- ... etc. see `:help lspconfig-all` for a list of all the pre-configured lsps
				--
				-- some languages (like typescript) have entire language plugins that can be useful:
				--    https://github.com/pmizio/typescript-tools.nvim
				--
				-- but for many setups, the lsp (`tsserver`) will work just fine
				-- tsserver = {},
				--

				lua_ls = {
					-- cmd = {...},
					-- filetypes = { ...},
					-- capabilities = {},
					settings = {
						lua = {
							completion = {
								callsnippet = "replace",
							},
							-- you can toggle below to ignore lua_ls's noisy `missing-fields` warnings
							-- diagnostics = { disable = { 'missing-fields' } },
						},
					},
				},
			}

			-- ensure the servers and tools above are installed
			--  to check the current status of installed tools and/or manually install
			--  other tools, you can run
			--    :mason
			--
			--  you can press `g?` for help in this menu.
			require("mason").setup()

			-- you can add other tools here that you want mason to install
			-- for you, so that they are available from within neovim.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- used to format lua code
				--"pyright",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- this handles overriding only values explicitly passed
						-- by the server configuration above. useful when disabling
						-- certain features of an lsp (for example, turning off formatting for tsserver)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	{ -- autocompletion
		"hrsh7th/nvim-cmp",
		event = "insertenter",
		dependencies = {
			-- snippet engine & its associated nvim-cmp source
			{
				"l3mon4d3/luasnip",
				build = (function()
					-- build step is needed for regex support in snippets.
					-- this step is not supported in many windows environments.
					-- remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    see the readme about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					-- {
					--   'rafamadriz/friendly-snippets',
					--   config = function()
					--     require('luasnip.loaders.from_vscode').lazy_load()
					--   end,
					-- },
				},
			},
			"saadparwaiz1/cmp_luasnip",

			-- adds other completion capabilities.
			--  nvim-cmp does not ship with all sources by default. they are split
			--  into multiple repos for maintenance purposes.
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},
		config = function()
			-- see `:help cmp`
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },

				-- for an understanding of why these mappings were
				-- chosen, you will need to read `:help ins-completion`
				--
				-- no, but seriously. please read `:help ins-completion`, it is really good!
				mapping = cmp.mapping.preset.insert({
					-- select the [n]ext item
					["<c-n>"] = cmp.mapping.select_next_item(),
					-- select the [p]revious item
					["<c-p>"] = cmp.mapping.select_prev_item(),

					-- scroll the documentation window [b]ack / [f]orward
					["<c-b>"] = cmp.mapping.scroll_docs(-4),
					["<c-f>"] = cmp.mapping.scroll_docs(4),

					-- accept ([y]es) the completion.
					--  this will auto-import if your lsp supports it.
					--  this will expand snippets if the lsp sent a snippet.
					["<c-y>"] = cmp.mapping.confirm({ select = true }),

					-- if you prefer more traditional completion keymaps,
					-- you can uncomment the following lines
					--['<cr>'] = cmp.mapping.confirm { select = true },
					--['<tab>'] = cmp.mapping.select_next_item(),
					--['<s-tab>'] = cmp.mapping.select_prev_item(),

					-- manually trigger a completion from nvim-cmp.
					--  generally you don't need this, because nvim-cmp will display
					--  completions whenever it has completion options available.
					["<c-space>"] = cmp.mapping.complete({}),

					-- think of <c-l> as moving to the right of your snippet expansion.
					--  so if you have a snippet that's like:
					--  function $name($args)
					--    $body
					--  end
					--
					-- <c-l> will move you to the right of each of the expansion locations.
					-- <c-h> is similar, except moving you backwards.
					["<c-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<c-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),

					-- for more advanced luasnip keymaps (e.g. selecting choice nodes, expansion) see:
					--    https://github.com/l3mon4d3/luasnip?tab=readme-ov-file#keymaps
				}),
				sources = {
					{
						name = "lazydev",
						-- set group index to 0 to skip loading luals completions as lazydev recommends it
						group_index = 0,
					},
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
					{ name = "render-markdow" },
				},
			})
		end,
	},
}
