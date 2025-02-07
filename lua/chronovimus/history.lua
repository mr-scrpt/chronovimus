local M = {}

-- Основная история – последовательность файлов, открытых «линейно»
local main_history = {}
local current_index = 0

-- При ветвлении (открытие нового файла не с конца истории)
-- используется branch_cycle – массив файлов для циклической навигации
local branch_cycle = nil -- если не nil, то мы в режиме ветвления
local cycle_index = nil -- текущая позиция в branch_cycle

-- Флаг, чтобы не записывать переходы, вызванные самим перемещением по истории
local is_navigating = false

-----------------------------------------------------
-- Вспомогательные функции для удаления дублей из списка
-----------------------------------------------------
local function remove_duplicates_main(file)
  -- Удаляем все вхождения файла из main_history (если таковые имеются)
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
  -- Удаляем все вхождения файла из branch_cycle.
  -- Если файл совпадает с текущим элементом ветки – считаем, что запись уже актуальна.
  for i = #branch_cycle, 1, -1 do
    if branch_cycle[i] == file then
      table.remove(branch_cycle, i)
      if i < cycle_index then
        cycle_index = cycle_index - 1
      elseif i == cycle_index then
        -- Уже на текущей позиции – нечего менять
        return true
      end
    end
  end
  return false
end

-----------------------------------------------------
-- Функция записи нового файла в историю
-----------------------------------------------------
local function record_file(file)
  if is_navigating then
    return
  end

  -- Если мы находимся в конце основной истории (режим нормального открытия)
  if current_index == #main_history then
    -- Если файл совпадает с последним записанным – не добавляем
    if main_history[#main_history] == file then
      return
    end
    -- Удаляем предыдущие вхождения этого файла (чтобы избежать дублей)
    remove_duplicates_main(file)
    table.insert(main_history, file)
    current_index = #main_history
    -- При нормальном переходе сбрасываем ветку (branch_cycle)
    branch_cycle = nil
    cycle_index = nil
  else
    -- Мы не на конце истории – переходим в режим ветвления
    if not branch_cycle then
      -- Создаём ветку, копируя оставшуюся часть истории
      local branch_point = main_history[current_index]
      local future = {}
      for i = current_index + 1, #main_history do
        table.insert(future, main_history[i])
      end
      branch_cycle = {}
      -- Первый элемент – новый файл
      table.insert(branch_cycle, file)
      -- Затем точка ветвления (из основной истории)
      table.insert(branch_cycle, branch_point)
      -- И оставшаяся часть основной истории
      for _, f in ipairs(future) do
        table.insert(branch_cycle, f)
      end
      cycle_index = 1
    else
      -- Если уже в режиме ветвления, сначала удаляем дублированные вхождения
      if remove_duplicates_branch(file) then
        return
      end
      -- Затем вставляем новый файл перед текущим элементом ветки
      table.insert(branch_cycle, cycle_index, file)
    end
  end
end

-----------------------------------------------------
-- Автокоманда – запись файла при BufWinEnter
-----------------------------------------------------
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

-----------------------------------------------------
-- Функции навигации назад и вперёд
-----------------------------------------------------
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

-----------------------------------------------------
-- Функция для отладки – вывод истории
-----------------------------------------------------
function M.debug_history()
  print("Основная история (current_index=" .. current_index .. "):")
  for i, file in ipairs(main_history) do
    print(i, file, i == current_index and "*" or "")
  end
  if branch_cycle then
    print("Ветвление (cycle_index=" .. cycle_index .. "):")
    for i, file in ipairs(branch_cycle) do
      print(i, file, i == cycle_index and "*" or "")
    end
  end
end

return M
