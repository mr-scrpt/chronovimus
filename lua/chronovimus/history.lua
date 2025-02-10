-- history.lua
local M = {}

-- Таблица, хранящая историю для каждого окна
local windows_history = {}

-- Возвращает (и создаёт, если не существует) состояние истории для указанного окна
local function get_state(winid)
	local state = windows_history[winid]
	if not state then
		state = {
			main_history = {},
			current_index = 0,
			branch_cycle = nil,
			cycle_index = nil,
			is_navigating = false,
		}
		windows_history[winid] = state
	end
	return state
end

-- Удаляет дубликаты из основной истории для окна
local function remove_duplicates_main(state, file)
	for i = #state.main_history, 1, -1 do
		if state.main_history[i] == file then
			table.remove(state.main_history, i)
			if i <= state.current_index then
				state.current_index = state.current_index - 1
			end
		end
	end
end

-- Удаляет дубликаты из ветки (branch) для окна
local function remove_duplicates_branch(state, file)
	if not state.branch_cycle then
		return false
	end
	for i = #state.branch_cycle, 1, -1 do
		if state.branch_cycle[i] == file then
			table.remove(state.branch_cycle, i)
			if i < state.cycle_index then
				state.cycle_index = state.cycle_index - 1
			elseif i == state.cycle_index then
				return true
			end
		end
	end
	return false
end

-- Фиксирует файл в истории для данного состояния окна
local function record_file_for_state(state, file)
	if state.is_navigating then
		return
	end

	if state.current_index == #state.main_history then
		if state.main_history[#state.main_history] == file then
			return
		end
		remove_duplicates_main(state, file)
		table.insert(state.main_history, file)
		state.current_index = #state.main_history
		state.branch_cycle = nil
		state.cycle_index = nil
	else
		if not state.branch_cycle then
			local branch_point = state.main_history[state.current_index]
			local future = {}
			for i = state.current_index + 1, #state.main_history do
				table.insert(future, state.main_history[i])
			end
			state.branch_cycle = {}
			table.insert(state.branch_cycle, file)
			table.insert(state.branch_cycle, branch_point)
			for _, f in ipairs(future) do
				table.insert(state.branch_cycle, f)
			end
			state.cycle_index = 1
		else
			if remove_duplicates_branch(state, file) then
				return
			end
			table.insert(state.branch_cycle, state.cycle_index, file)
		end
	end
end

-- Обёртка для записи файла, использующая текущий идентификатор окна
local function record_file(file)
	local winid = vim.api.nvim_get_current_win()
	local state = get_state(winid)
	record_file_for_state(state, file)
end

-- Настраивает автокоманду для записи истории при открытии буфера в окне
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

-- Навигация "назад" по истории для текущего окна
function M.navigate_back()
	local winid = vim.api.nvim_get_current_win()
	local state = get_state(winid)

	if state.branch_cycle then
		state.cycle_index = state.cycle_index + 1
		if state.cycle_index > #state.branch_cycle then
			state.cycle_index = 1
		end
		state.is_navigating = true
		vim.api.nvim_command("edit " .. vim.fn.fnameescape(state.branch_cycle[state.cycle_index]))
		state.is_navigating = false
	else
		if state.current_index > 1 then
			state.current_index = state.current_index - 1
			state.is_navigating = true
			vim.api.nvim_command("edit " .. vim.fn.fnameescape(state.main_history[state.current_index]))
			state.is_navigating = false
		end
	end
end

-- Навигация "вперёд" по истории для текущего окна
function M.navigate_forward()
	local winid = vim.api.nvim_get_current_win()
	local state = get_state(winid)

	if state.branch_cycle then
		state.cycle_index = state.cycle_index - 1
		if state.cycle_index < 1 then
			state.cycle_index = #state.branch_cycle
		end
		state.is_navigating = true
		vim.api.nvim_command("edit " .. vim.fn.fnameescape(state.branch_cycle[state.cycle_index]))
		state.is_navigating = false
	else
		if state.current_index < #state.main_history then
			state.current_index = state.current_index + 1
			state.is_navigating = true
			vim.api.nvim_command("edit " .. vim.fn.fnameescape(state.main_history[state.current_index]))
			state.is_navigating = false
		end
	end
end

-- Вывод отладочной информации по истории для текущего окна
function M.debug_history()
	local winid = vim.api.nvim_get_current_win()
	local state = get_state(winid)
	print("Main history (current_index=" .. state.current_index .. "):")
	for i, file in ipairs(state.main_history) do
		print(i, file, i == state.current_index and "*" or "")
	end
	if state.branch_cycle then
		print("Branch (cycle_index=" .. state.cycle_index .. "):")
		for i, file in ipairs(state.branch_cycle) do
			print(i, file, i == state.cycle_index and "*" or "")
		end
	end
end

-- Возвращает историю (основную или ветку, если она активна) для текущего окна
function M.get_history()
	local winid = vim.api.nvim_get_current_win()
	local state = get_state(winid)
	local result = {}
	if state.branch_cycle then
		for _, file in ipairs(state.branch_cycle) do
			table.insert(result, file)
		end
	else
		for _, file in ipairs(state.main_history) do
			table.insert(result, file)
		end
	end
	return result
end

return M
