vim.api.nvim_create_user_command("CheatSh", function(opts)
	local cheatsh = require("cheatsh")
	cheatsh.fetch(opts.args)
end, {
	nargs = 1,
	desc = "Fetch cheatsheet from cheat.sh",
})
