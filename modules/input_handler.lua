-- input_handler.lua
local InputHandler = {} -- initialize the table first

-- Internal state
local joystick
local state = {
    last_event = nil,
    current_event = nil,
    trigger = false,
}

-- Define all input events
InputHandler.events = {
    LEFT = "left",
    RIGHT = "right",
    UP = "up",
    DOWN = "down",
    ESC = "escape",
    RETURN = "return",
    MENU = "menu",
    SEARCH = "search",
    PREV = "[",
    NEXT = "]",
    BACK = "back",
    SEL = "guide",   -- new
    START = "start",  -- new
}

InputHandler.joystick_mapping = {
    ["dpleft"] = InputHandler.events.LEFT,
    ["dpright"] = InputHandler.events.RIGHT,
    ["dpup"] = InputHandler.events.UP,
    ["dpdown"] = InputHandler.events.DOWN,
    ["y"] = InputHandler.events.SEARCH,
    ["x"] = InputHandler.events.MENU,
    ["a"] = InputHandler.events.RETURN,
    ["b"] = InputHandler.events.ESC,
    ["leftshoulder"] = InputHandler.events.PREV,
    ["rightshoulder"] = InputHandler.events.NEXT,
    ["start"] = InputHandler.events.START,    -- map physical start button
    ["guide"] = InputHandler.events.SEL,      -- map physical select button
}

-- Cooldown settings
local cooldown_duration = 0.2
local last_trigger_time = -cooldown_duration

local combo = {
    back_pressed = false,
    start_pressed = false,
}

-- Check if an input can trigger (cooldown)
local function can_trigger()
    local current_time = love.timer.getTime()
    if current_time - last_trigger_time >= cooldown_duration then
        last_trigger_time = current_time
        return true
    end
    return false
end

-- Trigger an input event
local function trigger(event)
    if can_trigger() then
        state.last_event = state.current_event
        state.current_event = event
        state.trigger = true
        -- print("Triggered: " .. event)
    end
end

-- Initialize joystick/gamepad
function InputHandler.load()
    local joysticks = love.joystick.getJoysticks()
    if #joysticks > 0 then
        joystick = joysticks[1]
    end
end

-- Update input state (polling joystick buttons)
function InputHandler.update(dt)
    if joystick then
        -- Track combo states
        combo.back_pressed = joystick:isGamepadDown("back")
        combo.start_pressed = joystick:isGamepadDown("start")

        -- Check for Quit Combo
        if combo.back_pressed and combo.start_pressed then
            love.event.quit()
        end

        -- Existing polling logic
        for button, event in pairs(InputHandler.joystick_mapping) do
            if joystick:isGamepadDown(button) then
                trigger(event)
            end
        end
    end
end

-- Register a callback for events
function InputHandler.onEvent(callback)
    if state.trigger then
        state.trigger = false
        callback(state.current_event)
    end
end

-- Keyboard input hook
function InputHandler.keypressed(key)
    for _, k in pairs(InputHandler.events) do
        if key == k then
            trigger(key)
        end
    end
end

return InputHandler
