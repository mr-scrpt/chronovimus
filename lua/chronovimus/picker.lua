local M = {}

function M.show_history_in_picker()
	local history = require("chronovimus.history").get_history()
	if #history == 0 then
		print("History is empty")
		return
	end

	local current_file = vim.api.nvim_buf_get_name(0)
	local default_index = 1
	for i, entry in ipairs(history) do
		if entry == current_file then
			default_index = i
			break
		end
	end

	local items = {}
	for _, path in ipairs(history) do
		table.insert(items, {
			text = path,
			file = path,
			value = path,
		})
	end

	local snacks = require("snacks")
	snacks.picker({
		title = "History",
		items = items,
		format = "file",
		preview = "file",
		on_show = function(picker)
			picker.list:view(default_index)
		end,
		confirm = function(picker, item)
			if item then
				picker:close()
				vim.cmd("edit " .. vim.fn.fnameescape(item.value))
			end
		end,
		win = {
			input = {
				keys = {
					["<CR>"] = { "confirm", mode = { "n", "i" } },
					["<Esc>"] = "close",
					["q"] = "close",
				},
			},
			list = {
				keys = {
					["<CR>"] = "confirm",
					["<Esc>"] = "close",
					["q"] = "close",
				},
			},
		},
	})
end

return M
