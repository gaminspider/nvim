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
			{ "<F2>", function() require('dap').step_over() end, desc = "Step over" },
			{ "<F3>", function() require('dap').step_into() end, desc = "Step into" },
			{ "<F4>", function() require('dap').step_out() end, desc = "Step out" },
			{ "<Leader>b", function() require('dap').set_breakpoint() end, desc = "Toggle breakpoint" },
		},
	},
}
