local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local M = {}

M.show_history_in_telescope = function()
	local history = require("chronovimus").get_history()
	local current_file = vim.api.nvim_buf_get_name(0)

	local index = 1
	for i, file in ipairs(history) do
		if file == current_file then
			index = i
			break
		end
	end

	pickers
		.new({}, {
			prompt_title = "File History",
			finder = finders.new_table({
				results = history,
			}),
			sorter = conf.generic_sorter({}),
			default_selection_index = index, -- Устанавливаем выбранным текущий файл
		})
		:find()
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
