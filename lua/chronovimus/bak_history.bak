local M = {}

local main_history = {}
local current_index = 0

local branch_cycle = nil
local cycle_index = nil

local is_navigating = false

local function remove_duplicates_main(file)
	for i = #main_history, 1, -1 do
		if main_history[i] == file then
			table.remove(main_history, i)
			if i <= current_index then
				current_index = current_index - 1
			end
		end
	end
end

local function remove_duplicates_branch(file)
	for i = #branch_cycle, 1, -1 do
		if branch_cycle[i] == file then
			table.remove(branch_cycle, i)
			if i < cycle_index then
				cycle_index = cycle_index - 1
			elseif i == cycle_index then
				return true
			end
		end
	end
	return false
end

local function record_file(file)
	if is_navigating then
		return
	end

	if current_index == #main_history then
		if main_history[#main_history] == file then
			return
		end
		remove_duplicates_main(file)
		table.insert(main_history, file)
		current_index = #main_history
		branch_cycle = nil
		cycle_index = nil
	else
		if not branch_cycle then
			local branch_point = main_history[current_index]
			local future = {}
			for i = current_index + 1, #main_history do
				table.insert(future, main_history[i])
			end
			branch_cycle = {}
			table.insert(branch_cycle, file)
			table.insert(branch_cycle, branch_point)
			for _, f in ipairs(future) do
				table.insert(branch_cycle, f)
			end
			cycle_index = 1
		else
			if remove_duplicates_branch(file) then
				return
			end
			table.insert(branch_cycle, cycle_index, file)
		end
	end
end

function M.setup(user_opts)
	local group = vim.api.nvim_create_augroup("HistoryNav", { clear = true })

	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = group,
		callback = function()
			local file = vim.api.nvim_buf_get_name(0)
			if file == "" then
				return
			end
			record_file(file)
		end,
	})
end

function M.navigate_back()
	if branch_cycle then
		cycle_index = cycle_index + 1
		if cycle_index > #branch_cycle then
			cycle_index = 1
		end
		is_navigating = true
		vim.api.nvim_command("edit " .. vim.fn.fnameescape(branch_cycle[cycle_index]))
		is_navigating = false
	else
		if current_index > 1 then
			current_index = current_index - 1
			is_navigating = true
			vim.api.nvim_command("edit " .. vim.fn.fnameescape(main_history[current_index]))
			is_navigating = false
		end
	end
end

function M.navigate_forward()
	if branch_cycle then
		cycle_index = cycle_index - 1
		if cycle_index < 1 then
			cycle_index = #branch_cycle
		end
		is_navigating = true
		vim.api.nvim_command("edit " .. vim.fn.fnameescape(branch_cycle[cycle_index]))
		is_navigating = false
	else
		if current_index < #main_history then
			current_index = current_index + 1
			is_navigating = true
			vim.api.nvim_command("edit " .. vim.fn.fnameescape(main_history[current_index]))
			is_navigating = false
		end
	end
end

function M.debug_history()
	print("Main history (current_index=" .. current_index .. "):")
	for i, file in ipairs(main_history) do
		print(i, file, i == current_index and "*" or "")
	end
	if branch_cycle then
		print("Branch (cycle_index=" .. cycle_index .. "):")
		for i, file in ipairs(branch_cycle) do
			print(i, file, i == cycle_index and "*" or "")
		end
	end
end

function M.get_history()
	local result = {}
	if branch_cycle then
		for _, file in ipairs(branch_cycle) do
			table.insert(result, file)
		end
	else
		for _, file in ipairs(main_history) do
			table.insert(result, file)
		end
	end
	return result
end

return M
