-- ui/keyboard.lua
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
function Keyboard.open(initial_text, on_submit, on_cancel)
  Keyboard.active = true
  Keyboard.text = initial_text or ""
  Keyboard.cursor = { row = 1, col = 1 }
  Keyboard.on_submit = on_submit
  Keyboard.on_cancel = on_cancel
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
  elseif event == "escape"  then
    Keyboard.cancel()
  end
end

-- Draw keyboard
function Keyboard.draw()
  if not Keyboard.active then return end

  -- Draw background
  love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
  love.graphics.rectangle("fill", 50, 100, 500, 200)

  -- Draw current text
  love.graphics.setColor(1,1,1)
  love.graphics.print("Input: " .. Keyboard.text, 60, 110)

  -- Draw keys
  local startY = 140
  local keyW, keyH = 40, 30
  for r, row in ipairs(Keyboard.layout) do
    for c, key in ipairs(row) do
      local x = 60 + (c-1)*(keyW+5)
      local y = startY + (r-1)*(keyH+5)
      if r == Keyboard.cursor.row and c == Keyboard.cursor.col then
        love.graphics.setColor(0, 1, 0) -- highlight current key
      else
        love.graphics.setColor(1, 1, 1)
      end
      love.graphics.rectangle("line", x, y, keyW, keyH)
      love.graphics.setColor(1,1,1)
      love.graphics.print(key, x+5, y+5)
    end
  end
end

return Keyboard
