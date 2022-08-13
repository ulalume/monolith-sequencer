package.path = package.path .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?.lua'
package.cpath = package.cpath .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?.so'

local monolith = require "monolith.core".new({ ledColorBits = 9 })

local musicSystem
local soundChanger

local board = {
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 1, -1, 0, 0, 0,
  0, 0, 0, -1, 1, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
}
local cursorX = 0
local cursorY = 0

local function x_m()
  cursorX = math.max(0, cursorX - 1)
end

local function x_p()
  cursorX = math.min(7, cursorX + 1)
end

local function y_m()
  cursorY = math.max(0, cursorY - 1)
end

local function y_p()
  cursorY = math.min(7, cursorY + 1)
end

local cursorMove = { { x_m, x_p, y_m, y_p }, { x_p, x_m, y_p, y_m }, { y_p, y_m, x_m, x_p }, { y_m, y_p, x_p, x_m } }

function love.load()
  if require "util.osname" == "Linux" then
    for i, inp in ipairs(require "config.linux_input_settings") do monolith.input:setUserSetting(i, inp) end
  else
    for i, inp in ipairs(require "config.input_settings") do monolith.input:setUserSetting(i, inp) end
  end

  love.graphics.setDefaultFilter('nearest', 'nearest', 1)
  love.graphics.setLineStyle('rough')

  local devices, musicPathTable, priorityTable = unpack(require "config.music_data")
  musicSystem = require("music.music_system"):new({ true, true, true, true }, devices, musicPathTable, priorityTable)
  soundChanger = require "sound-changer":new(musicSystem)

  musicSystem:playAllPlayer("bgm")
end

function love.update(dt)
  musicSystem:update(dt)
  soundChanger:update(dt)

  for i = 1, 4 do
    if monolith.input:getButtonDown(i, "a") then
      local stone = board[cursorX + cursorY * 8 + 1]
      if stone == -1 then
        stone = 0
      else
        stone = -1
      end
      board[cursorX + cursorY * 8 + 1] = stone
    end
    if monolith.input:getButtonDown(i, "b") then
      local stone = board[cursorX + cursorY * 8 + 1]
      if stone == 1 then
        stone = 0
      else
        stone = 1
      end
      board[cursorX + cursorY * 8 + 1] = stone
    end
  end

  -- 配置
  --   2P
  -- 4P  3P
  --   1P
  for i = 1, 4 do
    if monolith.input:getButtonDown(i, "left") then
      cursorMove[i][1]()
    elseif monolith.input:getButtonDown(i, "right") then
      cursorMove[i][2]()
    end
    if monolith.input:getButtonDown(i, "up") then
      cursorMove[i][3]()
    elseif monolith.input:getButtonDown(i, "down") then
      cursorMove[i][4]()
    end
  end

  -- 2個ずつ取得
  for i = 1, #board / 2 do
    local v1 = (board[i * 2 - 1] + 1) * 3
    local v2 = (board[i * 2] + 1)
    local v = math.min(math.ceil(((v1 + v2) / 8) * 128), 127)

    soundChanger:setSoundControl(i, v)
  end
  local s = ""
  for i = 1, #soundChanger.changing do
    s = s .. ", " .. soundChanger.changing[i]
  end
end

function love.draw()
  monolith:beginDraw()

  for i = 1, #board do
    local stone = board[i]
    local x = (i - 1) % 8
    local y = (i - 1 - x) / 8
    love.graphics.setColor(1, 1, 1)
    if stone ~= 0 then
      if stone == -1 then
        love.graphics.circle("fill", x * 16 + 8, y * 16 + 8, 6)
      end
      if stone == 1 then
        love.graphics.circle("line", x * 16 + 8, y * 16 + 8, 6)
      end
    end
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("line", x * 16, y * 16, 16, 16)
  end

  love.graphics.setColor(0, 1, 0)
  love.graphics.rectangle("line", cursorX * 16, cursorY * 16, 16, 16)

  monolith:endDraw()

  love.graphics.setColor(1, 1, 1)
  love.graphics.print(tostring(love.timer.getFPS()), 0, 0)
end

function love.quit()
  musicSystem:gc()
end
