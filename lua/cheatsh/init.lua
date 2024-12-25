--- CheatSh plugin for Neovim
--- Fetches programming cheatsheets from cheat.sh
---@module 'cheatsh'

local M = {}

local CHEATSH_URL = "https://cheat.sh/"

---@class cheatsh.Config
---@field split string vsplit or split
---@field size number percentage of the screen
local config = {
	split = "vsplit",
	size = 50,
}

local state = {
	win = nil,
}

---@param query string The search query
---@return string,number encoded_query The encoded query
local function encode_query(query)
	return query:gsub(" ", "+"):gsub("[^%w%+]", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
end

---@param url string The URL to fetch
---@return table|nil content The fetched content
local function fetch_content(url)
	local output = vim.system({ "curl", "-s", url }):wait()

	if not output or output.code ~= 0 then
		local error_msg = output and output.stderr or "Network Error"
		vim.notify(string.format("Failed to fetch cheatsheet: %s", error_msg), vim.log.levels.ERROR)
		return
	end

	return output
end

---@param size number Desired size as percentage
---@param split_type string "vsplit" or "split"
local function adjust_window_size(size, split_type)
	local total_width = vim.o.columns
	local total_height = vim.o.lines

	if split_type == "vsplit" then
		local width = math.floor(total_width * (size / 100))
		vim.cmd("vertical resize " .. width)
	else
		local height = math.floor(total_height * (size / 100))
		vim.cmd("resize " .. height)
	end
end

---@param query string The search query
---@return number? buf Buffer number or nil if creation failed
local function create_output_buffer(query)
	local buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_name(buf, "CheatSh: " .. query)
	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "cheatsh"

	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })

	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = buf,
		callback = function()
			state.win = nil
		end,
	})

	return buf
end

---@param opts cheatsh.Config The configuration options
M.setup = function(opts)
	if opts then
		vim.validate({
			split = { opts.split, "string", true },
			size = { opts.size, "number", true },
		})
	end

	config = vim.tbl_extend("force", config, opts or {})
end

---@param query string The search query
function M.fetch(query)
	local encoded_query = encode_query(query)
	local url = CHEATSH_URL .. encoded_query

	local output = fetch_content(url)
	if not output then
		return
	end

	vim.cmd(config.split)
	local term_buf = create_output_buffer(query)
	if not term_buf then
		return
	end

	vim.api.nvim_win_set_buf(0, term_buf)

	if state.win then
		vim.api.nvim_win_close(state.win, true)
	end

	local term_chan = vim.api.nvim_open_term(term_buf, {})
	state.win = vim.api.nvim_get_current_win()

	adjust_window_size(config.size, config.split)

	vim.api.nvim_chan_send(term_chan, output.stdout)
end

return M
