local history = require("chronovimus.history")
local commands = require("chronovimus.commands")

local M = {}

function M.setup(opts)
  opts = opts or {}
  history.setup(opts)
  commands.setup()
end

return M
