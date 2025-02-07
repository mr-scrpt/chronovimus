local M = {}

function M.show_history_in_picker()
	local history = require("chronovimus.history").get_history()
	if #history == 0 then
		print("История пуста")
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

	local snacks = require("snacks")
	snacks.picker({
		title = "History",
		items = history,
		format = function(item)
			return { { item, "Normal" } }
		end,
		preview = "file",
		on_show = function(picker)
			picker.list:view(default_index)
		end,
		confirm = function(picker, item)
			if item then
				picker:close()
				vim.cmd("edit " .. vim.fn.fnameescape(item))
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
-- local M = {}
--
-- function M.show_history_in_telescope()
-- 	local pickers = require("telescope.pickers")
-- 	local finders = require("telescope.finders")
-- 	local actions = require("telescope.actions")
-- 	local action_state = require("telescope.actions.state")
-- 	local conf = require("telescope.config").values
--
-- 	local history = require("chronovimus.history").get_history()
-- 	if #history == 0 then
-- 		print("История пуста")
-- 		return
-- 	end
--
-- 	local current_file = vim.api.nvim_buf_get_name(0) -- Получаем путь активного файла
-- 	local default_index = 1
--
-- 	for i, entry in ipairs(history) do
-- 		if entry == current_file then
-- 			default_index = i
-- 			break
-- 		end
-- 	end
--
-- 	pickers
-- 		.new({}, {
-- 			prompt_title = "History",
-- 			finder = finders.new_table({
-- 				results = history,
-- 				entry_maker = function(entry)
-- 					return {
-- 						value = entry,
-- 						display = entry,
-- 						ordinal = entry,
-- 					}
-- 				end,
-- 			}),
-- 			sorter = conf.generic_sorter({}),
-- 			default_selection_index = default_index, -- Устанавливаем выбранным активный файл
-- 			previewer = conf.file_previewer({}),
-- 			attach_mappings = function(prompt_bufnr, map)
-- 				local function open_selected()
-- 					local selection = action_state.get_selected_entry()
-- 					actions.close(prompt_bufnr)
-- 					vim.cmd("edit " .. vim.fn.fnameescape(selection.value))
-- 				end
-- 				map("i", "<CR>", open_selected)
-- 				map("n", "<CR>", open_selected)
-- 				return true
-- 			end,
-- 		})
-- 		:find()
-- end
--
-- return M
--
