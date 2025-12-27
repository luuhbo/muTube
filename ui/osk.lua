-- ui/keyboard.lua
local Theme = require("ui.theme")
local Logger = require("modules.logger")
local Keyboard = {}

Keyboard.active = false
Keyboard.text = ""
Keyboard.cursor = { row = 1, col = 1 }

Keyboard.layout = {
  { "q","w","e","r","t","y","u","i","o","p" },
  { "a","s","d","f","g","h","j","k","l" },
  { "z","x","c","v","b","n","m" },
  { "SPACE", "DEL", "OK" }
}

Keyboard.on_submit = nil
Keyboard.on_cancel = nil

-- Open keyboard
function Keyboard.open(initial_text, on_submit, on_cancel, screenWidth, screenHeight)
  Keyboard.active = true
  Keyboard.text = initial_text or ""
  Keyboard.cursor = { row = 1, col = 1 }
  Keyboard.on_submit = on_submit
  Keyboard.on_cancel = on_cancel

  -- Size dynamically based on screen
  Keyboard.screenWidth = screenWidth or love.graphics.getWidth()
  Keyboard.screenHeight = screenHeight or love.graphics.getHeight()
  local dpi = 1
  if love.window and love.window.getDPIScale then
    dpi = love.window.getDPIScale()
  end
  Logger.log(string.format("[Keyboard] screen %dx%d dpi=%.2f", Keyboard.screenWidth, Keyboard.screenHeight, dpi))
  Keyboard.width = Keyboard.screenWidth * 0.9       -- 90% of width
  Keyboard.height = Keyboard.screenHeight * 0.5     -- 50% of height
  Keyboard.x = (Keyboard.screenWidth - Keyboard.width)/2
  Keyboard.y = Keyboard.screenHeight * 0.25        -- a bit lower than top
end

-- Close keyboard
function Keyboard.close()
  Keyboard.active = false
end

-- Current key under cursor
function Keyboard.currentKey()
  local row = Keyboard.layout[Keyboard.cursor.row]
  return row and row[Keyboard.cursor.col]
end

-- Select current key
function Keyboard.select()
  local key = Keyboard.currentKey()
  if not key then return end

  if key == "SPACE" then
    Keyboard.text = Keyboard.text .. " "
  elseif key == "DEL" then
    Keyboard.text = Keyboard.text:sub(1, -2)
  elseif key == "OK" then
    if Keyboard.on_submit then
      Keyboard.on_submit(Keyboard.text)
    end
    Keyboard.close()
  else
    Keyboard.text = Keyboard.text .. key
  end
end

-- Cancel keyboard
function Keyboard.cancel()
  if Keyboard.on_cancel then
    Keyboard.on_cancel()
  end
  Keyboard.close()
end

-- Move cursor
function Keyboard.move(dir)
  if not Keyboard.active then return end
  local r, c = Keyboard.cursor.row, Keyboard.cursor.col
  if dir == "up" then
    r = math.max(r-1, 1)
    c = math.min(c, #Keyboard.layout[r])
  elseif dir == "down" then
    r = math.min(r+1, #Keyboard.layout)
    c = math.min(c, #Keyboard.layout[r])
  elseif dir == "left" then
    c = math.max(c-1, 1)
  elseif dir == "right" then
    c = math.min(c+1, #Keyboard.layout[r])
  end
  Keyboard.cursor.row, Keyboard.cursor.col = r, c
end

-- Handle input events
function Keyboard.handleEvent(event)
  if not Keyboard.active then return end

  if event == "up" then
    Keyboard.move("up")
  elseif event == "down" then
    Keyboard.move("down")
  elseif event == "left" then
    Keyboard.move("left")
  elseif event == "right" then
    Keyboard.move("right")
  elseif event == "return" then
    Keyboard.select()
  elseif event == "escape" then
    Keyboard.cancel()
  elseif event == "menu" then
    Keyboard.text = Keyboard.text:sub(1, -2)
  end
end

-- Draw keyboard
function Keyboard.draw()
  if not Keyboard.active then return end

  local startX, startY = Keyboard.x, Keyboard.y
  local startX, startY = Keyboard.x, Keyboard.y
  local maxCols = 0
  for _, row in ipairs(Keyboard.layout) do
    if #row > maxCols then maxCols = #row end
  end
  local gap = 10
  local keyH = (Keyboard.height - (#Keyboard.layout+1)*gap)/#Keyboard.layout

  -- Uniform key width based on the widest row
  local keyW = (Keyboard.width - (maxCols+1)*gap)/maxCols

  -- Draw panel background as white (mostly opaque)
  love.graphics.setColor(1, 1, 1, 0.95)
  love.graphics.rectangle("fill", startX-10, startY-50, Keyboard.width+20, Keyboard.height+60, 12, 12)

  -- Draw subtle border around panel
  love.graphics.setColor(0.86, 0.9, 0.94, 0.9)
  love.graphics.rectangle("line", startX-10, startY-50, Keyboard.width+20, Keyboard.height+60, 12, 12)

  -- Draw keys, justified per row (keys span the row width)
-- Inside Keyboard.draw(), replacing your key drawing loop
  for r, row in ipairs(Keyboard.layout) do
      local cols = #row
      local totalRowWidth = cols * keyW + (cols-1) * gap
      local rowStartX = startX + (Keyboard.width - totalRowWidth) / 2
      local y = startY + (r-1)*(keyH+gap)

      for c, key in ipairs(row) do
          local x = rowStartX + (c-1)*(keyW+gap)

          local cornerRadius = keyH * 0.3 -- more rounded

          -- Key background
          love.graphics.setColor(1, 1, 1, 1)
          love.graphics.rectangle("fill", x, y, keyW, keyH, cornerRadius, cornerRadius)

          -- Highlight selected key
          if r == Keyboard.cursor.row and c == Keyboard.cursor.col then
              love.graphics.setColor(0.35, 0.65, 1.0, 0.18)
              love.graphics.rectangle("fill", x, y, keyW, keyH, cornerRadius, cornerRadius)
          end

          -- Key border
          love.graphics.setColor(0.82, 0.87, 0.92, 0.95)
          love.graphics.rectangle("line", x, y, keyW, keyH, cornerRadius, cornerRadius)

          -- Key text (centered)
          local font = love.graphics.getFont()
          local textY = y + (keyH - font:getHeight()) / 2
          Theme.setColor("text_dark")
          love.graphics.printf(key, x, textY, keyW, "center")
      end
  end

end

return Keyboard
