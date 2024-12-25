local M = {}

M.check = function()
	vim.health.start("cheatsh report")

	if vim.fn.executable("curl") == 0 then
		vim.health.error("curl is not installed")
	end

	vim.health.ok("curl found on path")

	local result = vim.system({ "curl", "https://cheat.sh/" }, { text = true }):wait()
	if result.code ~= 0 then
		vim.health.error("Failed to fetch from cheat.sh")
	else
		vim.health.ok("cheat.sh is accessible")
	end

	vim.health.finish()
end

return M
