-- modules/logger.lua
local Logger = {}

local max_lines = 200
local logs = {}

local function safe_write_file(path, content)
  local ok, err = pcall(function()
    local f = io.open(path, "a")
    if f then
      f:write(content)
      f:close()
    end
  end)
  return ok
end

function Logger.log(msg)
  local line = os.date("%Y-%m-%d %H:%M:%S") .. " " .. tostring(msg)
  table.insert(logs, 1, line)
  if #logs > max_lines then table.remove(logs) end

  -- Try to write to love filesystem save (best-effort)
  if love and love.filesystem and love.filesystem.write then
    local ok, existing = pcall(love.filesystem.read, "muTube_debug.log")
    local content = (existing or "") .. line .. "\n"
    pcall(love.filesystem.write, "muTube_debug.log", content)
  end

  -- Also append to /tmp so it's easy to fetch from device
  pcall(safe_write_file, "/tmp/muTube_debug.log", line .. "\n")
end

function Logger.getRecent(n)
  n = n or 10
  local out = {}
  for i = 1, math.min(n, #logs) do out[#out+1] = logs[i] end
  return out
end

return Logger
