-- Install debugpy https://github.com/microsoft/debugpy

return {
	"mfussenegger/nvim-dap",
	{
		-- nvim-dap-python automates config for python
		"mfussenegger/nvim-dap-python",
		config = function()
			require('dap-python').setup('python')
		end,
	},
	{ "rcarriga/nvim-dap-ui",
		dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
		opts = {},
		keys = {
			{ "<F5>", function() require('dap').continue() end, desc = "Start/Continue Debugging" },
			{ "<F8>", function() require("dapui").toggle() end, desc = "Toggle Debugger UI" },
		},
	},
}
